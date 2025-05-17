NAMESPACE="prometeus"

kubectl get ns "$NAMESPACE" -o json \
  | jq 'del(.spec.finalizers)' \
  | kubectl replace --raw "/api/v1/namespaces/$NAMESPACE/finalize" -f -
