#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

PROJECT_ID="${PROJECT_ID:-i27-helpdesk-gcp-dev-lab}"

TFVARS="${REPO_ROOT}/terraform/environments/dev/dev.auto.tfvars"

FIREWALL_RULES=(
  "i27-helpdesk-dev-allow-admin-ssh"
  "i27-helpdesk-dev-allow-jenkins-ui"
  "i27-helpdesk-dev-allow-sonarqube-ui"
)

echo "Discovering current public IPv4..."

CURRENT_IP="$(curl -4 -fsS --max-time 10 https://api.ipify.org)"

if [[ ! "${CURRENT_IP}" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "ERROR: Could not determine a valid public IPv4."
  exit 1
fi

ADMIN_CIDR="${CURRENT_IP}/32"

echo "Current admin CIDR: ${ADMIN_CIDR}"

for RULE in "${FIREWALL_RULES[@]}"; do
  echo "Updating ${RULE}..."

  gcloud compute firewall-rules update "${RULE}" \
    --project="${PROJECT_ID}" \
    --source-ranges="${ADMIN_CIDR}" \
    --quiet
done

python3 - "${TFVARS}" "${ADMIN_CIDR}" <<'PY'
from pathlib import Path
import re
import sys

path = Path(sys.argv[1])
cidr = sys.argv[2]

text = path.read_text()

new_text, count = re.subn(
    r'(?m)^\s*admin_cidr\s*=\s*"[^"]+"\s*$',
    f'admin_cidr = "{cidr}"',
    text,
    count=1
)

if count != 1:
    raise SystemExit(
        f"ERROR: Could not uniquely update admin_cidr in {path}"
    )

path.write_text(new_text)
print(f"Updated Terraform dev.auto.tfvars: admin_cidr = \"{cidr}\"")
PY

echo
echo "Firewall CIDRs:"
for RULE in "${FIREWALL_RULES[@]}"; do
  gcloud compute firewall-rules describe "${RULE}" \
    --project="${PROJECT_ID}" \
    --format="table(name,sourceRanges)"
done
