FROM alpine:3
LABEL maintainer "Vlad Ghinea vlad@ghn.me"

# Install packages
RUN apk --no-cache add gnupg haveged tini

# Entrypoint
ENTRYPOINT ["/sbin/tini", "--", "gpg"]
CMD ["--version"]
