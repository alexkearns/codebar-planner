# 1. GitHub codespaces

- install SAM CLI
- sam build && deploy

# 2. AWS

- update password var in AWS
- update DNS record

# 3. Local PC

- setup EC2 remote session forwarding

```
aws ssm start-session --target i-0f2d5f11e0438874c --document-name AWS-StartPortForwardingSessionToRemoteHost --parameters '{"portNumber":["5432"],"localPortNumber":["5432"],"host":["codebar-planner.cluster-ccisptzg7d4j.eu-west-2.rds.amazonaws.com"]}'
```

- docker-compose build web
- docker run --add-host=host.docker.internal:host-gateway -it planner-web:latest bash
  - apt-get install vim
  - vi config/database.yml -> change the dev db name to `planner`
  - RAILS_ENV=development DB_HOST=host.docker.internal DB_USER=codebar_planner_app POSTGRES_PASSWORD='YoUrPa$$Word' SECRET_KEY_BASE='YourSecretK£y' rake db:drop db:create db:migrate db:seed
