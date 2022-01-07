# install

~~~bash
mkdir -p ~/.kube && sudo sh -c "cat /root/.kube/config > /home/vagrant/.kube/config" && sudo chown $USER:$USER ~/.kube/config

ansible-galaxy install -r requirements.yml -p ./roles
ansible-playbook -i ./inventory main.yml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.11.0/manifests/namespace.yaml
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.11.0/manifests/metallb.yaml
~~~

## Configuration de mettallb

~~~bash
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - 192.168.56.230-192.168.56.250
EOF
~~~

## Test

~~~bash
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.11.0/manifests/tutorial-2.yaml
kubectl get services
curl http://192.168.56.230
~~~
