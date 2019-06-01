# Vlad's RSysLog

[![](https://images.microbadger.com/badges/image/vladgh/rsyslog.svg)](https://microbadger.com/images/vladgh/rsyslog "Get your own image badge on microbadger.com")
[![](https://images.microbadger.com/badges/version/vladgh/rsyslog.svg)](https://microbadger.com/images/vladgh/rsyslog "Get your own version badge on microbadger.com")
[![](https://images.microbadger.com/badges/commit/vladgh/rsyslog.svg)](https://microbadger.com/images/vladgh/rsyslog "Get your own commit badge on microbadger.com")
[![](https://images.microbadger.com/badges/license/vladgh/rsyslog.svg)](https://microbadger.com/images/vladgh/rsyslog "Get your own license badge on microbadger.com")

Vlad's RSysLog central server with TLS and Logz.io support.

## Environment variables

- `CA_CERT`: the path to the CA certificate (defaults to `/etc/ssl/certs/ca-cert.pem`)
- `SERVER_KEY`: the path to the server key (defaults to `/etc/ssl/certs/server-key.pem`)
- `SERVER_CERT`: the path to the server certificate (defaults to `/etc/ssl/certs/server-cert.pem`)
- `SERVER_TCP_PORT`: the port on which the server listens for logs (defaults to `10514`)
- `REMOTE_LOGS_PATH`: the path for the remote logs storage (defaults to `/logs/remote`)
- `LOGZIO_TOKEN`: Logz.io token (optional)
- `TIME_ZONE`: sets the time zone (optional)
- `TIME_SERVER`: sets the NTP time server (optional)

## Usage

```
docker run -d \
  -e LOGZIO_TOKEN='myToken' \
  -e TIME_ZONE='US/Central' \
  -v ./certs:/etc/ssl/certs:ro \
  -v ./remote_logs:/logs/remote
  vladgh/rs
```

Generate self-signed certificates (thanks to https://nacko.net/securing-your-syslog-server-with-tls-ssl-in-centos-6-rhel-6/)

```
# Create a new self-signed CA certificate.
openssl genrsa -out ca-key.pem 2048
openssl req -new -x509 -sha256 -nodes -days 3600 -subj '/C=US/ST=LA/L=New Orleans/O=VladGh/CN=VladGh CA Root/emailAddress=admin@vladgh.com' -key ca-key.pem -out ca-cert.pem

# Create the request and sign it with our CA certificate
openssl req -newkey rsa:2048 -sha256 -days 3600 -nodes -subj '/C=US/ST=LA/L=New Orleans/O=VladGh/CN=logs.ghn.me/emailAddress=admin@vladgh.com' -keyout server-key.pem -out server-req.pem
openssl x509 -req -in server-req.pem -days 3600 -CA ca-cert.pem -CAkey ca-key.pem -CAcreateserial -out server-cert.pem

# Certificate info
openssl x509 -text -in ca-cert.pem
openssl x509 -text -in server-cert.pem
```
