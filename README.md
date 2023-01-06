# mlops-demo-application-gitops

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
