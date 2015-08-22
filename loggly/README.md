loggly-docker
=============

Docker container for loggly (via rsyslog). Check out Loggly's [Docker logging documentation](https://www.loggly.com/docs/docker-syslog/) to learn more.

Usage:

```
docker run -e LOGGLY_AUTH_TOKEN=[Loggly Customer Token] -e LOGGLY_TAG=[Tag Describing Source] sendgridlabs/loggly-docker
```

