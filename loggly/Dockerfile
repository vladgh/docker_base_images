#################################################################
#
#                    ##        .
#              ## ## ##       ==
#           ## ## ## ##      ===
#       /""""""""""""""""\___/ ===
#  ~~~ {~~ ~~~~ ~~~ ~~~~ ~~ ~ /  ===- ~~~
#       \______ o          __/
#         \    \        __/
#          \____\______/
#
#################################################################

FROM alpine:latest
MAINTAINER Vlad Ghinea vlad@ghn.me

RUN apk --no-cache add rsyslog rsyslog-tls

EXPOSE 514
EXPOSE 514/udp

COPY rsyslog.conf /etc/
COPY loggly.crt /etc/rsyslog.d/keys/ca.d/

COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
