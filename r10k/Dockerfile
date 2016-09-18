FROM ruby:2.3-alpine
MAINTAINER Vlad Ghinea vlad@ghn.me

# Environment
ENV R10K_VERSION='2.4.3'

# Install packages
RUN apk --no-cache add bash git

# Install R10K
RUN gem install r10k --version "$R10K_VERSION" --no-ri --no-rdoc

# Default entrypoint and command
ENTRYPOINT ["r10k"]
CMD ["version"]
