#!/usr/bin/env bash
set -euo

NAMESPACE="prometeus"
# Lista todos los tipos de recursos disponibles
RESOURCE_TYPES=$(kubectl api-resources --verbs=list --namespaced -o name)

for TYPE in $RESOURCE_TYPES; do
  echo "Forzando eliminación de recursos tipo: $TYPE"

  # Obtener recursos de este tipo
  RESOURCES=$(kubectl get $TYPE -n $NAMESPACE -o name 2>/dev/null)

  for RESOURCE in $RESOURCES; do
    echo "  Forzando eliminación de $RESOURCE"
    kubectl delete $RESOURCE -n $NAMESPACE --force --grace-period=0 2>/dev/null || true
  done
done