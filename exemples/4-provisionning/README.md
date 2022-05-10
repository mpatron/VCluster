# Installation du monitoring

~~~bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

kubectl create namespace monitoring

# https://github.com/bitnami/charts/tree/master/bitnami/kube-prometheus/#installing-the-chart
helm install prometheus -n monitoring --set prometheus.service.type=LoadBalancer bitnami/kube-prometheus
export PROMETHEUS_IP=$(kubectl get svc --namespace monitoring prometheus-kube-prometheus-prometheus --template "{{ range (index .status.loadBalancer.ingress 0) }}{{ . }}{{ end }}")
echo "Prometheus URL: http://$PROMETHEUS_IP:9090/"
~~~~bash
vagrant@node0:~$ helm install prometheus -n monitoring --set prometheus.service.type=LoadBalancer bitnami/kube-prometheus
NAME: prometheus
LAST DEPLOYED: Mon Jan 24 21:35:46 2022
NAMESPACE: monitoring
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
CHART NAME: kube-prometheus
CHART VERSION: 6.6.3
APP VERSION: 0.53.1

** Please be patient while the chart is being deployed **

Watch the Prometheus Operator Deployment status using the command:

    kubectl get deploy -w --namespace monitoring -l app.kubernetes.io/name=kube-prometheus-operator,app.kubernetes.io/instance=prometheus

Watch the Prometheus StatefulSet status using the command:

    kubectl get sts -w --namespace monitoring -l app.kubernetes.io/name=kube-prometheus-prometheus,app.kubernetes.io/instance=prometheus

Prometheus can be accessed via port "9090" on the following DNS name from within your cluster:

    prometheus-kube-prometheus-prometheus.monitoring.svc.cluster.local

To access Prometheus from outside the cluster execute the following commands:

  NOTE: It may take a few minutes for the LoadBalancer IP to be available.
        Watch the status with: 'kubectl get svc --namespace monitoring -w prometheus-kube-prometheus-prometheus'

    export SERVICE_IP=$(kubectl get svc --namespace monitoring prometheus-kube-prometheus-prometheus --template "{{ range (index .status.loadBalancer.ingress 0) }}{
{ . }}{{ end }}")
    echo "Prometheus URL: http://$SERVICE_IP:9090/"

Watch the Alertmanager StatefulSet status using the command:

    kubectl get sts -w --namespace monitoring -l app.kubernetes.io/name=kube-prometheus-alertmanager,app.kubernetes.io/instance=prometheus

Alertmanager can be accessed via port "9093" on the following DNS name from within your cluster:

    prometheus-kube-prometheus-alertmanager.monitoring.svc.cluster.local

To access Alertmanager from outside the cluster execute the following commands:

    echo "Alertmanager URL: http://127.0.0.1:9093/"
    kubectl port-forward --namespace monitoring svc/prometheus-kube-prometheus-alertmanager 9093:9093
~~~~

~~~bash
# https://github.com/bitnami/charts/tree/master/bitnami/grafana/#installing-the-chart
helm install grafana -n monitoring --set service.type=LoadBalancer bitnami/grafana
export GRAFANA_IP=$(kubectl get svc --namespace monitoring grafana -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo http://$GRAFANA_IP:3000
echo "User: admin"
echo "Password: $(kubectl get secret grafana-admin --namespace monitoring -o jsonpath="{.data.GF_SECURITY_ADMIN_PASSWORD}" | base64 --decode)"
~~~

~~~bash
vagrant@node0:~$ helm install grafana -n monitoring --set service.type=LoadBalancer --set persistence.storageClass=nfs-client bitnami/grafana
NAME: grafana
LAST DEPLOYED: Mon Jan 24 21:46:55 2022
NAMESPACE: monitoring
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
CHART NAME: grafana
CHART VERSION: 7.6.4
APP VERSION: 8.3.4

** Please be patient while the chart is being deployed **

1. Get the application URL by running these commands:
     NOTE: It may take a few minutes for the LoadBalancer IP to be available.
           You can watch the status of by running 'kubectl get --namespace monitoring svc -w grafana'
    export SERVICE_IP=$(kubectl get svc --namespace monitoring grafana -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
    echo http://$SERVICE_IP:3000

2. Get the admin credentials:

    echo "User: admin"
    echo "Password: $(kubectl get secret grafana-admin --namespace monitoring -o jsonpath="{.data.GF_SECURITY_ADMIN_PASSWORD}" | base64 --decode)"
~~~

~~~bash
https://grafana.com/api/dashboards/7249/revisions/1/download



helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm show values bitnami/keycloak
helm install keycloak bitnami/keycloak

export SERVICE_PORT=$(kubectl get --namespace default -o jsonpath="{.spec.ports[0].port}" services keycloak)
export SERVICE_IP=$(kubectl get svc --namespace default keycloak -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo "http://${SERVICE_IP}:${SERVICE_PORT}/auth"

echo Username: user
echo Password: $(kubectl get secret --namespace default keycloak -o jsonpath="{.data.admin-password}" | base64 --decode)
~~~

## Demo Spark

En devenir .. [https://github.com/kubernetes/examples/tree/master/staging/spark/spark-gluster]

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
