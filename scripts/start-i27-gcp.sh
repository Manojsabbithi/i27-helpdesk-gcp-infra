#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

PROJECT_ID="${PROJECT_ID:-i27-helpdesk-gcp-dev-lab}"
ZONE="${ZONE:-asia-south1-b}"

VM_NAMES=(
  "i27-helpdesk-dev-jenkins-controller"
  "i27-helpdesk-dev-jenkins-agent"
  "i27-helpdesk-dev-sonarqube"
)

echo
echo "======================================"
echo " Starting i27 Helpdesk GCP Lab"
echo "======================================"

echo
echo "STEP 1 - Refresh administrator CIDR"
"${SCRIPT_DIR}/refresh-admin-cidr.sh"

echo
echo "STEP 2 - Check VM state"

TO_START=()

for VM in "${VM_NAMES[@]}"; do
  STATUS="$(
    gcloud compute instances describe "${VM}" \
      --project="${PROJECT_ID}" \
      --zone="${ZONE}" \
      --format='value(status)'
  )"

  echo "${VM}: ${STATUS}"

  if [[ "${STATUS}" != "RUNNING" ]]; then
    TO_START+=("${VM}")
  fi
done

if (( ${#TO_START[@]} > 0 )); then
  echo
  echo "STEP 3 - Start Compute Engine VMs"

  gcloud compute instances start "${TO_START[@]}" \
    --project="${PROJECT_ID}" \
    --zone="${ZONE}" \
    --quiet
else
  echo
  echo "All VMs already RUNNING."
fi

echo
echo "STEP 4 - Wait for RUNNING state"

DEADLINE=$((SECONDS + 240))

while true; do
  ALL_RUNNING=true

  for VM in "${VM_NAMES[@]}"; do
    STATUS="$(
      gcloud compute instances describe "${VM}" \
        --project="${PROJECT_ID}" \
        --zone="${ZONE}" \
        --format='value(status)'
    )"

    printf '%-45s %s\n' "${VM}" "${STATUS}"

    if [[ "${STATUS}" != "RUNNING" ]]; then
      ALL_RUNNING=false
    fi
  done

  if [[ "${ALL_RUNNING}" == true ]]; then
    break
  fi

  if (( SECONDS >= DEADLINE )); then
    echo "ERROR: Timed out waiting for Compute Engine."
    exit 1
  fi

  echo "---"
  sleep 10
done

echo
echo "STEP 5 - Regenerate Ansible inventory"

"${SCRIPT_DIR}/generate-ansible-inventory.sh" >/dev/null

echo "Inventory refreshed."

echo
echo "STEP 6 - Wait for SSH/Ansible"

cd "${REPO_ROOT}/ansible"

ANSIBLE_READY=false

for ATTEMPT in $(seq 1 12); do
  echo "Ansible connectivity attempt ${ATTEMPT}/12..."

  if ansible devops -m ping >/dev/null 2>&1; then
    ANSIBLE_READY=true
    break
  fi

  sleep 10
done

if [[ "${ANSIBLE_READY}" != true ]]; then
  echo "ERROR: Ansible connectivity did not become ready."
  exit 1
fi

echo "All Ansible hosts reachable."

echo
echo "STEP 7 - Validate Jenkins"

CONTROLLER_IP="$(
  gcloud compute instances describe \
    i27-helpdesk-dev-jenkins-controller \
    --project="${PROJECT_ID}" \
    --zone="${ZONE}" \
    --format='value(networkInterfaces[0].accessConfigs[0].natIP)'
)"

JENKINS_READY=false

for ATTEMPT in $(seq 1 24); do
  CODE="$(
    curl -s \
      --connect-timeout 5 \
      -o /dev/null \
      -w '%{http_code}' \
      "http://${CONTROLLER_IP}:8080/login" || true
  )"

  if [[ "${CODE}" == "200" ]]; then
    JENKINS_READY=true
    break
  fi

  echo "Waiting for Jenkins... HTTP ${CODE:-000}"
  sleep 5
done

if [[ "${JENKINS_READY}" == true ]]; then
  echo "Jenkins OK: http://${CONTROLLER_IP}:8080"
else
  echo "WARNING: Jenkins did not become HTTP 200 within expected time."
fi

echo
echo "STEP 8 - Validate SonarQube"

SONAR_IP="$(
  gcloud compute instances describe \
    i27-helpdesk-dev-sonarqube \
    --project="${PROJECT_ID}" \
    --zone="${ZONE}" \
    --format='value(networkInterfaces[0].accessConfigs[0].natIP)'
)"

SONAR_READY=false

for ATTEMPT in $(seq 1 36); do
  STATUS="$(
    curl -s \
      --connect-timeout 5 \
      "http://${SONAR_IP}:9000/api/system/status" || true
  )"

  if echo "${STATUS}" | grep -q '"status":"UP"'; then
    SONAR_READY=true
    break
  fi

  echo "Waiting for SonarQube..."
  sleep 5
done

if [[ "${SONAR_READY}" == true ]]; then
  echo "SonarQube OK: http://${SONAR_IP}:9000"
else
  echo "WARNING: SonarQube did not reach UP state."
fi

echo
echo "======================================"
echo " GCP Lab Started"
echo "======================================"
echo
echo "Jenkins  : http://${CONTROLLER_IP}:8080"
echo "SonarQube: http://${SONAR_IP}:9000"
echo
echo "Ansible inventory has been refreshed."
