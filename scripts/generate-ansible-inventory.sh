#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INVENTORY="${REPO_ROOT}/ansible/inventory/generated.ini"

PROJECT_ID="${PROJECT_ID:-i27-helpdesk-gcp-dev-lab}"
ZONE="${ZONE:-asia-south1-b}"

SSH_USER="${SSH_USER:-madhukar}"
SSH_KEY="${SSH_KEY:-${HOME}/.ssh/i27_gcp_ed25519}"

JENKINS_CONTROLLER="i27-helpdesk-dev-jenkins-controller"
JENKINS_AGENT="i27-helpdesk-dev-jenkins-agent"
SONARQUBE="i27-helpdesk-dev-sonarqube"

get_status() {
  gcloud compute instances describe "$1" \
    --project="${PROJECT_ID}" \
    --zone="${ZONE}" \
    --format='value(status)'
}

get_public_ip() {
  gcloud compute instances describe "$1" \
    --project="${PROJECT_ID}" \
    --zone="${ZONE}" \
    --format='value(networkInterfaces[0].accessConfigs[0].natIP)'
}

get_private_ip() {
  gcloud compute instances describe "$1" \
    --project="${PROJECT_ID}" \
    --zone="${ZONE}" \
    --format='value(networkInterfaces[0].networkIP)'
}

for VM in \
  "${JENKINS_CONTROLLER}" \
  "${JENKINS_AGENT}" \
  "${SONARQUBE}"
do
  STATUS="$(get_status "${VM}")"

  if [[ "${STATUS}" != "RUNNING" ]]; then
    echo "ERROR: ${VM} is ${STATUS}, not RUNNING."
    exit 1
  fi
done

JENKINS_CONTROLLER_PUBLIC="$(get_public_ip "${JENKINS_CONTROLLER}")"
JENKINS_CONTROLLER_PRIVATE="$(get_private_ip "${JENKINS_CONTROLLER}")"

JENKINS_AGENT_PUBLIC="$(get_public_ip "${JENKINS_AGENT}")"
JENKINS_AGENT_PRIVATE="$(get_private_ip "${JENKINS_AGENT}")"

SONARQUBE_PUBLIC="$(get_public_ip "${SONARQUBE}")"
SONARQUBE_PRIVATE="$(get_private_ip "${SONARQUBE}")"

for VALUE in \
  "${JENKINS_CONTROLLER_PUBLIC}" \
  "${JENKINS_CONTROLLER_PRIVATE}" \
  "${JENKINS_AGENT_PUBLIC}" \
  "${JENKINS_AGENT_PRIVATE}" \
  "${SONARQUBE_PUBLIC}" \
  "${SONARQUBE_PRIVATE}"
do
  if [[ -z "${VALUE}" ]]; then
    echo "ERROR: Could not discover all required VM IP addresses."
    exit 1
  fi
done

mkdir -p "$(dirname "${INVENTORY}")"

cat > "${INVENTORY}" <<EOT
[jenkins_controller]
jenkins-controller ansible_host=${JENKINS_CONTROLLER_PUBLIC} private_ip=${JENKINS_CONTROLLER_PRIVATE}

[jenkins_agent]
jenkins-agent ansible_host=${JENKINS_AGENT_PUBLIC} private_ip=${JENKINS_AGENT_PRIVATE}

[sonarqube_servers]
sonarqube ansible_host=${SONARQUBE_PUBLIC} private_ip=${SONARQUBE_PRIVATE}

[devops:children]
jenkins_controller
jenkins_agent
sonarqube_servers

[devops:vars]
ansible_user=${SSH_USER}
ansible_ssh_private_key_file=${SSH_KEY}
ansible_python_interpreter=/usr/bin/python3
EOT

chmod 600 "${INVENTORY}"

echo
echo "Generated Ansible inventory:"
echo "  ${INVENTORY}"
echo
cat "${INVENTORY}"
