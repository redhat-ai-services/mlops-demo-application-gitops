#!/bin/bash
set -e

BOOTSTRAP_DIR="bootstrap/overlays/default/"
ARGO_NS=mlops-demo-gitops

# check login
check_oc_login(){
  oc cluster-info | head -n1
  oc whoami || exit 1
  echo

  sleep 5
}

main(){
    echo "Applying overlay: ${BOOTSTRAP_DIR}"
    kustomize build ${BOOTSTRAP_DIR} | oc apply -f -

    echo ""
    echo "Deploying tenant instance.  Check the status of the sync here:
    "
    route=$(oc get route argocd-server -o=jsonpath='{.spec.host}' -n ${ARGO_NS})

    echo "https://${route}"
}

check_oc_login

main