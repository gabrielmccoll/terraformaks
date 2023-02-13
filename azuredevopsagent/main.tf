apiVersion: v1
kind: Secret
metadata:
  name: azdevops
data:
  AZP_TOKEN: <base64 encoded pat>
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: azdevops-deployment
  labels:
    app: azdevops-agent
spec:
  replicas: 1
  selector:
    matchLabels:
      app: azdevops-agent
  template:
    metadata:
      labels:
        app: azdevops-agent
    spec:
      containers:
      - name: azdevops-agent
        image: gabrielmccoll/basic_ado_agent_keda
        imagePullPolicy: Never
        env:
          - name: AZP_URL
            value: "https://dev.azure.com/cloudkingdoms"
          - name: AZP_POOL
            value: "gmtest"
          - name: TARGETARCH
            value: "linux-amd64"
          - name: AZP_TOKEN
            valueFrom:
              secretKeyRef:
                name: azdevops
                key: AZP_TOKEN
        volumeMounts:
        - mountPath: /run/podman/podman.sock
          name: docker-volume
      volumes:
      - name: docker-volume
        hostPath:
          path: /run/podman/podman.sock
---
apiVersion: v1
kind: Secret
metadata:
  name: pipeline-auth
data:
  personalAccessToken: <base64 encoded pat>
---
apiVersion: keda.sh/v1alpha1
kind: TriggerAuthentication
metadata:
  name: pipeline-trigger-auth
spec:
  secretTargetRef:
    - parameter: personalAccessToken
      name: pipeline-auth
      key: personalAccessToken
---
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: azure-pipelines-scaledobject
spec:
  scaleTargetRef:
    name: azdevops-deployment
  minReplicaCount: 0
  maxReplicaCount: 5 
  triggers:
  - type: azure-pipelines
    metadata:
      poolID: "13" #Get this from the ORG level not Project
      organizationURLFromEnv: "AZP_URL"
    authenticationRef:
     name: pipeline-trigger-auth