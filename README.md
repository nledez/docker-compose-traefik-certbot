# Terraform

Get the right Openstack `openrc.sh` file and create a file `terraform.tfvars` with right content:

```
keypair = "my_keypair"
```

Add the content to `openrc.sh` :

```
export OVH_ENDPOINT=ovh-eu
export OVH_APPLICATION_KEY=...
export OVH_APPLICATION_SECRET=...
export OVH_CONSUMER_KEY=...
```

You can customize with `flavor`, `region`, `keypair`, `project_name`, `image_name`, `net_public` variables.

```
. ./openrc.sh
terraform init
terraform apply
```

# Connect on host

The `terraform apply` give you the `ssh_command` you can launch it with:

```
eval $(terraform output -raw ssh_command)
```

# Create certificate

```
# Define your parameters
export LE_EMAIL="your-email-for-lets-encrypt@example.com"
export DOMAIN="your-fqdn"
export LE_PARAM_COMMON="--test-cert" # If your want use LE staging

# Or use them from Terraform
. /home/ubuntu/certbot_config.sh

docker-compose exec certbot certbot certificates
docker-compose exec certbot certbot certonly --webroot --webroot-path /var/www --agree-tos --email ${LE_EMAIL} --preferred-challenges http-01 -d ${DOMAIN} ${LE_PARAM_COMMON} -n
docker-compose exec certbot /etc/letsencrypt/renewal-hooks/post/update_certificates.sh
```

# Renew certificates

```
docker-compose exec certbot certbot renew ${LE_PARAM_COMMON} --force-renewal -n
docker-compose exec certbot /etc/letsencrypt/renewal-hooks/post/update_certificates.sh
```

# Revoke certificate

```
docker-compose exec certbot certbot revoke --cert-path /etc/letsencrypt/live/${DOMAIN}/fullchain.pem ${LE_PARAM_COMMON} -n
```
