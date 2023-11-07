cd EFK-yaml

kubectl create namespace logging

kubectl apply -f elasticsearch-pvc.yaml
kubectl apply -f elasticsearch-cm.yaml
kubectl apply -f elasticsearch.yaml
kubectl apply -f fluentd-cm.yaml
kubectl apply -f fluentd.yaml
kubectl apply -f kibana.yaml
