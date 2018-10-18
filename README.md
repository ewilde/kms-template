# kms-template
If you have a fargate workload and need to pretend you have a docker-secrets mount `/run/secrets`. 
This utility mocks that behaviour with keys read from `kms` and secrets written to `/run/secrets`. 

## Configuration
| Environment variable              | Usage                                                                                          | Default                  | Required |
|-----------------------------------|------------------------------------------------------------------------------------------------|--------------------------|----------|
| `SECRETS`                         | List of secrets names to make available                                                        |                          |   yes    |


## Running
### Locally
An example running using your local docker daemon:

```bash
mkdir -p /tmp/sec
aws secretsmanager create-secret --name db --secret-string "hello db"
docker run \
    -v /tmp/sec:/run/secrets:rw \
    -e SECRETS="db" \
    -e AWS_ACCESS_KEY_ID=xxx \
    -e AWS_SECRET_ACCESS_KEY=xxx \
    -e AWS_REGION=eu-west-1 \
    ewilde/kms-template:latest
cat /tmp/sec/db    
```
