#!/usr/bin/env bash

set -euo pipefail

PROJECT_ID="${PROJECT_ID:-i27-helpdesk-gcp-dev-lab}"
ZONE="${ZONE:-asia-south1-b}"

VM_NAMES=(
  "i27-helpdesk-dev-jenkins-agent"
  "i27-helpdesk-dev-sonarqube"
  "i27-helpdesk-dev-jenkins-controller"
)

echo
echo "======================================"
echo " Stopping i27 Helpdesk GCP Lab"
echo "======================================"
echo

TO_STOP=()

for VM in "${VM_NAMES[@]}"; do
  STATUS="$(
    gcloud compute instances describe "${VM}" \
      --project="${PROJECT_ID}" \
      --zone="${ZONE}" \
      --format='value(status)'
  )"

  echo "${VM}: ${STATUS}"

  if [[ "${STATUS}" == "RUNNING" ]]; then
    TO_STOP+=("${VM}")
  fi
done

if (( ${#TO_STOP[@]} == 0 )); then
  echo
  echo "All Compute Engine VMs are already stopped."
  exit 0
fi

echo
echo "Stopping:"
printf '  %s\n' "${TO_STOP[@]}"

gcloud compute instances stop "${TO_STOP[@]}" \
  --project="${PROJECT_ID}" \
  --zone="${ZONE}" \
  --quiet

echo
echo "Waiting for TERMINATED state..."

DEADLINE=$((SECONDS + 240))

while true; do
  ALL_STOPPED=true

  for VM in "${VM_NAMES[@]}"; do
    STATUS="$(
      gcloud compute instances describe "${VM}" \
        --project="${PROJECT_ID}" \
        --zone="${ZONE}" \
        --format='value(status)'
    )"

    printf '%-45s %s\n' "${VM}" "${STATUS}"

    if [[ "${STATUS}" != "TERMINATED" ]]; then
      ALL_STOPPED=false
    fi
  done

  if [[ "${ALL_STOPPED}" == true ]]; then
    break
  fi

  if (( SECONDS >= DEADLINE )); then
    echo "ERROR: Timed out waiting for VM shutdown."
    exit 1
  fi

  echo "---"
  sleep 10
done

echo
echo "All DevOps Compute Engine VMs are stopped."
