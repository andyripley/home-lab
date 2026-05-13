# Setup

Generate the certs needed for sealed secrets:

```bash
openssl req -x509 -days 365 -nodes -newkey rsa:4096 \
-keyout tf/deploy/bootstrap/sealed-secrets/certs/sealed-secrets.key \
-out tf/deploy/bootstrap/sealed-secrets/certs/sealed-secrets.cert \
-subj "/CN=sealed-secret/O=sealed-secret"
```
