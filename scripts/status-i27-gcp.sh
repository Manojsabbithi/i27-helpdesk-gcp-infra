#!/usr/bin/env bash

set -uo pipefail

PROJECT_ID="${PROJECT_ID:-i27-helpdesk-gcp-dev-lab}"
ZONE="${ZONE:-asia-south1-b}"

echo
echo "======================================"
echo " i27 Helpdesk GCP Lab Status"
echo "======================================"
echo

gcloud compute instances list \
  --project="${PROJECT_ID}" \
  --filter="labels.project=i27-helpdesk AND labels.environment=dev" \
  --format="table(
    name,
    zone.basename(),
    machineType.basename(),
    status,
    networkInterfaces[0].networkIP:label=PRIVATE_IP,
    networkInterfaces[0].accessConfigs[0].natIP:label=PUBLIC_IP
  )"

echo
echo "========== FIREWALL ADMIN CIDR =========="

for RULE in \
  i27-helpdesk-dev-allow-admin-ssh \
  i27-helpdesk-dev-allow-jenkins-ui \
  i27-helpdesk-dev-allow-sonarqube-ui
do
  gcloud compute firewall-rules describe "${RULE}" \
    --project="${PROJECT_ID}" \
    --format="table(name,sourceRanges)" 2>/dev/null || true
done

get_status() {
  gcloud compute instances describe "$1" \
    --project="${PROJECT_ID}" \
    --zone="${ZONE}" \
    --format='value(status)' 2>/dev/null
}

get_public_ip() {
  gcloud compute instances describe "$1" \
    --project="${PROJECT_ID}" \
    --zone="${ZONE}" \
    --format='value(networkInterfaces[0].accessConfigs[0].natIP)' 2>/dev/null
}

CONTROLLER="i27-helpdesk-dev-jenkins-controller"
SONAR="i27-helpdesk-dev-sonarqube"

echo
echo "========== SERVICES =========="

if [[ "$(get_status "${CONTROLLER}")" == "RUNNING" ]]; then
  IP="$(get_public_ip "${CONTROLLER}")"

  CODE="$(curl -s \
    --connect-timeout 5 \
    -o /dev/null \
    -w '%{http_code}' \
    "http://${IP}:8080/login" || true)"

  echo "Jenkins : http://${IP}:8080/login -> HTTP ${CODE}"
else
  echo "Jenkins : VM stopped"
fi

if [[ "$(get_status "${SONAR}")" == "RUNNING" ]]; then
  IP="$(get_public_ip "${SONAR}")"

  STATUS="$(curl -s \
    --connect-timeout 5 \
    "http://${IP}:9000/api/system/status" || true)"

  echo "SonarQube: http://${IP}:9000 -> ${STATUS:-not reachable}"
else
  echo "SonarQube: VM stopped"
fi

echo
