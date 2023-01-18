#!/bin/bash
set -e

BOOTSTRAP_DIR="bootstrap/overlays/default/"
ARGO_NS=mlops-demo-gitops
GRAFANA_PROMETHEUS_OPERATORS_DIR="components/grafana_prometheus/operators/overlays/default/"
GRAFANA_PROMETHEUS_NS=mlops-demo-dev
GRAFANA_PROMETHEUS_SERVICES_DIR="components/grafana_prometheus/services/overlays/default/"

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
    echo "Deploying application components.  Check the status of the sync here:
    "
    route=$(oc get route argocd-server -o=jsonpath='{.spec.host}' -n ${ARGO_NS})

    echo "https://${route}"
}

grafana_prometheus() {
    echo "Applying grafana & prometheus operators to ${GRAFANA_PROMETHEUS_NS}"
    kustomize build ${GRAFANA_PROMETHEUS_OPERATORS_DIR} | oc apply -f -
    
    echo "waiting for a minute"
    sleep 60
    
    echo ""

    echo "Applying grafana & prometheus services to ${GRAFANA_PROMETHEUS_NS}"

    kustomize build ${GRAFANA_PROMETHEUS_SERVICES_DIR} | oc apply -f -

    echo ""
    echo "Grafana Route:
    "
    route=$(oc get route grafana-route -n ${GRAFANA_PROMETHEUS_NS} -o jsonpath='{.spec.host}')
    echo "https://${route}"
}

check_oc_login

main

grafana_prometheus