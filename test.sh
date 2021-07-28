
#!/usr/bin/env bash
set -u

if [ -z "$DIGITALOCEAN_ACCESS_TOKEN" ]
then
    echo "Digital access token variable is not defined"
else
    echo "Digital access token is defined ..."
    doctl auth init
    mkdir ~/.kube
    doctl kubernetes cluster kubeconfig show kenna > ~/.kube/config
    chmod 400 ~/.kube/config
    kubectl get nodes
fi

## Annotate volumeSnapshotclass or process will error out
echo "Annotate VolumeSnapshotClass ...."

kubectl annotate VolumeSnapshotClass do-block-storage k10.kasten.io/is-snapshot-class='true'

## Preflight check
preflight() {
echo "checking for VolumeSnapshotClass ..."
echo ""
echo ""
kubectl get VolumeSnapshotClass
echo " adding the kasten repo ..."
echo ""
echo ""
helm repo add kasten https://charts.kasten.io/
helm repo list
echo "checking default storage class ..."
echo ""
echo ""
kubectl get sc
echo " create kasten namespace"
echo ""
echo ""
kubectl create namespace kasten-io
echo "running pre flight checks ..."
echo ""
echo ""
curl https://docs.kasten.io/tools/k10_primer.sh | bash
}
echo "checking preflight conditions ..."

preflight

install_kasten() {
  echo "Installing kasten ..."
  echo ""
  echo ""
  helm install k10 kasten/k10 --namespace=kasten-io --debug --wait
}

install_mysql() {
  echo "installing mysql ..."
  echo ""
  echo ""
  kubectl create ns mysql
  helm install test-mysql stable/mysql --namespace mysql --debug --wait
}

if [ "$1" = "k10" ]
then
   install_kasten
   install_mysql
else
  echo "kasten will not be installed till you add k10 as positional parameter to your container run"
  echo ""
  echo ""
  echo "example - docker run <imagename> k10"
fi

# Install sample policy
cat <<EOF | kubectl apply -f -
apiVersion: config.kio.kasten.io/v1alpha1
kind: Policy
metadata:
  name: sample-backup-policy
  namespace: kasten-io
spec:
  comment: My sample backup policy
  frequency: '@hourly'
  retention:
    hourly: 24
    daily: 7
  actions:
  - action: backup
  selector:
    matchLabels:
      k10.kasten.io/appNamespace: mysql
EOF
