FROM vladgh/awscli:stable
MAINTAINER Vlad Ghinea vlad@ghn.me

# Install iNotify tools
RUN apk --no-cache add inotify-tools

# Configure entrypoint
COPY entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
