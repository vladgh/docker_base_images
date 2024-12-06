FROM alpine:20240923@sha256:f4b9f111e2c5290552a920590dd48dc58f5ea1cacda6e25b0a2718974d090cf0
LABEL maintainer "Vlad Ghinea vlad@ghn.me"

# Install packages
RUN apk --no-cache add gnupg haveged tini

# Entrypoint
ENTRYPOINT ["/sbin/tini", "--", "gpg"]
CMD ["--version"]
