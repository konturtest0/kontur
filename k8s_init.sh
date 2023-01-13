#!/bin/bash

#Write a script which setup k8s cluster, launch Nginx web server and configure backend to accept requests. Script should check web server and backend availability via loadbalancer.


# иницилизуруем кластер
kubeadm init

# запускаем nginx сервер
kubectl create deployment nginx --image=nginx

# настриваем бэк для получения запросов
kubectl expose deployment nginx --port=80 --type=LoadBalancer

# проверяем статус nginx
kubectl get service nginx

# Ждем, пока балансер получит IP
while [ -z "$(kubectl get service nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')" ]; do
  sleep 1
done

# Показать IP адрес баланс
echo "Load balancer IP: $(kubectl get service nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"

# Проверям доступность nginx
curl $(kubectl get service nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# Проверем доступность бэка nginx
curl $(kubectl get service nginx -o jsonpath='{.status.loadBalancer.ingress[0].ip}')/backend
