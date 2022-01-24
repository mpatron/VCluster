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


## Demo Spark

~~~bash
# ...
# Mettre en place NFS en methode 3
# ...
vagrant@node0:~$ helm repo add bitnami https://charts.bitnami.com/bitnami
vagrant@node0:~$ helm repo update
vagrant@node0:~$ helm install spark bitnami/spark --set service.type=LoadBalancer

NAME: spark
LAST DEPLOYED: Mon Jan 24 18:40:44 2022
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
CHART NAME: spark
CHART VERSION: 5.8.4
APP VERSION: 3.2.0

** Please be patient while the chart is being deployed **

1. Get the Spark master WebUI URL by running these commands:

    NOTE: It may take a few minutes for the LoadBalancer IP to be available.
    You can watch the status of by running 'kubectl get --namespace default svc -w spark-master-svc'

  export SERVICE_IP=$(kubectl get --namespace default svc spark-master-svc -o jsonpath="{.status.loadBalancer.ingress[0]['ip', 'hostname'] }")
  echo http://$SERVICE_IP:80

2. Submit an application to the cluster:

  To submit an application to the cluster the spark-submit script must be used. That script can be
  obtained at https://github.com/apache/spark/tree/master/bin. Also you can use kubectl run.

  Run the commands below to obtain the master IP and submit your application.

  export EXAMPLE_JAR=$(kubectl exec -ti --namespace default spark-worker-0 -- find examples/jars/ -name 'spark-example*\.jar' | tr -d '\r')
  export SUBMIT_IP=$(kubectl get --namespace default svc spark-master-svc -o jsonpath="{.status.loadBalancer.ingress[0]['ip', 'hostname'] }")

  kubectl run --namespace default spark-client --rm --tty -i --restart='Never' \
    --image docker.io/bitnami/spark:3.2.0-debian-10-r73 \
    -- spark-submit --master spark://$SUBMIT_IP:7077 \
    --deploy-mode cluster \
    --class org.apache.spark.examples.SparkPi \
    $EXAMPLE_JAR 1000

** IMPORTANT: When submit an application the --master parameter should be set to the service IP, if not, the application will not resolve the master. **
~~~