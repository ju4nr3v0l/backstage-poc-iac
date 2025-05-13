# variables
SUBS="f8e621ae-b178-4f4b-9089-9bddcf072722"
NODE_RG="MC_RG-poc-iac_CK-poc-iac_eastus"
LB="kubernetes"
FIP="a86c415bd19ec4501b098b646c733500"
RULE="${FIP}-TCP-80"
PROBE="${FIP}-tcp-80"
IP_NAME="nginx-ingress-pip"

az account set --subscription $SUBS

# 1) Eliminar la regla de LB que aún referencia el frontend
az network lb rule delete \
  --resource-group "$NODE_RG" \
  --lb-name "$LB" \
  --name "$RULE" || true

# 2) Eliminar la health probe asociada (si existe)
az network lb probe delete \
  --resource-group "$NODE_RG" \
  --lb-name "$LB" \
  --name "$PROBE" || true

# 3) (re)intentar borrar el frontend-IP config en caso de quedar
az network lb frontend-ip delete \
  --resource-group "$NODE_RG" \
  --lb-name "$LB" \
  --name "$FIP" || true

# 4) Esperar a que la Public IP quede sin asociación
az network public-ip wait \
  --resource-group "$NODE_RG" \
  --name "$IP_NAME" \
  --is-null --query "ipConfiguration.id" \
  --interval 20 --timeout 600

echo "Frontend, regla y probe eliminados; la IP ya está desasociada."
