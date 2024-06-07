FROM alpine:20240606@sha256:166710df254975d4a6c4c407c315951c22753dcaa829e020a3fd5d18fff70dd2
LABEL maintainer "Vlad Ghinea vlad@ghn.me"

# Install packages
RUN apk --no-cache add gnupg haveged tini

# Entrypoint
ENTRYPOINT ["/sbin/tini", "--", "gpg"]
CMD ["--version"]
