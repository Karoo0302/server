kubectl create namespace monitoring

kubectl apply -f monitoring-yaml/kube-state-metrics/clusterrole.yaml
kubectl apply -f monitoring-yaml/kube-state-metrics/clusterrolebinding.yaml
kubectl apply -f monitoring-yaml/kube-state-metrics/sa.yaml
kubectl apply -f monitoring-yaml/kube-state-metrics/deploy.yaml
kubectl apply -f monitoring-yaml/kube-state-metrics/svc.yaml

kubectl apply -f monitoring-yaml/prometheus/clusterrole.yaml
kubectl apply -f monitoring-yaml/prometheus/node-exporter.yaml
kubectl apply -f monitoring-yaml/prometheus/cm.yaml
kubectl apply -f monitoring-yaml/prometheus/pvc.yaml
kubectl apply -f monitoring-yaml/prometheus/deploy.yaml
kubectl apply -f monitoring-yaml/prometheus/svc.yaml

kubectl apply -f monitoring-yaml/grafana/pvc.yaml
kubectl apply -f monitoring-yaml/grafana/cm.yaml
kubectl apply -f monitoring-yaml/grafana/deploy.yaml
kubectl apply -f monitoring-yaml/grafana/svc.yaml
