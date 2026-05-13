# pulse-flow

to send message 
curl -X POST "http://localhost:5195/api/work" -H "Content-Type: application/json" -d "\"Hello from Localhost\""


To fetch the message 
http://localhost:5195/api/work

install nginx ingress
# 1. Add the repository
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# 2. Install/Upgrade with Static IP and Azure-specific annotations
helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress --create-namespace \
  --set controller.replicaCount=2