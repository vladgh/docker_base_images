FROM ruby:alpine
MAINTAINER Vlad Ghinea vlad@ghn.me

# Environment
ENV R10K_VERSION='2.3.0'

# Install packages
RUN apk --no-cache add bash python git

# Install AWS Command Line Interface
RUN apk --no-cache add --virtual build-dependencies py-pip && \
    pip install awscli && \
    apk del build-dependencies

# Install R10K
RUN gem install r10k --version "$R10K_VERSION" --no-ri --no-rdoc

# Default entrypoint and command
ENTRYPOINT ["r10k"]
CMD ["version"]
