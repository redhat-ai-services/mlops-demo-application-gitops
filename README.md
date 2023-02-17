# MLOps Demo: Application GitOps

This repo contains resources that are deployed and managed by the application team in a gitops environment. These resources are deployed to the namespaces created by the tenant-gitops repo utilizing the ArgoCD instance created by that repo.

## Creating Sealed Secret for SSH GitHub Authentication

Prerequisites:
- Kubectl CLI
- Install Kubeseal CLI (https://github.com/bitnami-labs/sealed-secrets/releases/download)
- Bootstrapped Openshift Cluster (see https://github.com/rh-intelligent-application-practice/mlops-demo-getting-started)

### Steps

1. Create the Kubernetes Secret with your SSH Private Key and save as _mlops-demo-application-gitops-github-ssh-key-secret.yaml_:

```
kind: Secret
apiVersion: v1
metadata:
  name: mlops-demo-application-gitops-github-ssh-key
  namespace: mlops-demo-pipelines
  annotations:
    tekton.dev/git-0: github.com
data:
  ssh-privatekey: >-
    <ENCODED_PRIVATE_KEY>
type: kubernetes.io/ssh-auth
```

2. Encrypt the Secret Using the Certificate from Step 1: 

```
kubeseal --controller-namespace=sealed-secrets --format=yaml < mlops-demo-application-gitops-github-ssh-key-secret.yaml > mlops-demo-application-gitops-github-ssh-key-sealed-secret.yaml
```

3. Apply the Sealed Secret to Your Cluster:
```
kubectl create -f mlops-demo-application-gitops-github-ssh-key-sealed-secret.yaml
```

4. Verify Creation of the Secret:
```
kubectl get secret mlops-demo-application-gitops-github-ssh-key -o jsonpath="{.data.ssh-privatekey}" | base64 --decode
```

5. The secret is now available in your namespace as specified in Step 2

## Running the Cluster Bootstrap

Execute the bootstrap script to begin the installation process:

```sh
./scripts/bootstrap.sh
```

Additional ArgoCD Application objects will be created and synced in OpenShift GitOps. You can follow the progress of the sync using the ArgoCD URL that the script will provide. This sync operation should complete in a few seconds.
