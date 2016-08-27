FROM alpine:3.4
MAINTAINER Vlad Ghinea vlad@ghn.me

# Install packages
RUN apk --no-cache add bash minidlna

# Entrypoint
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
