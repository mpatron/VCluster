# Installation du monitoring

~~~bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

kubectl create namespace monitoring

# https://github.com/bitnami/charts/tree/master/bitnami/kube-prometheus/#installing-the-chart
helm install prometheus -n monitoring --set prometheus.service.type=LoadBalancer bitnami/kube-prometheus
export PROMETHEUS_IP=$(kubectl get svc --namespace monitoring prometheus-kube-prometheus-prometheus --template "{{ range (index .status.loadBalancer.ingress 0) }}{{ . }}{{ end }}")
echo "Prometheus URL: http://$PROMETHEUS_IP:9090/"

# https://github.com/bitnami/charts/tree/master/bitnami/grafana/#installing-the-chart
helm install grafana -n monitoring --set service.type=LoadBalancer bitnami/grafana
export GRAFANA_IP=$(kubectl get svc --namespace monitoring grafana -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo http://$GRAFANA_IP:3000
echo "User: admin"
echo "Password: $(kubectl get secret grafana-admin --namespace monitoring -o jsonpath="{.data.GF_SECURITY_ADMIN_PASSWORD}" | base64 --decode)"


helm repo add bitnami https://charts.bitnami.com/bitnami
helm show values bitnami/keycloak
helm install keycloak bitnami/keycloak

export SERVICE_PORT=$(kubectl get --namespace default -o jsonpath="{.spec.ports[0].port}" services keycloak)
export SERVICE_IP=$(kubectl get svc --namespace default keycloak -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "http://${SERVICE_IP}:${SERVICE_PORT}/auth"

echo Username: user
echo Password: $(kubectl get secret --namespace default keycloak -o jsonpath="{.data.admin-password}" | base64 --decode)
~~~
