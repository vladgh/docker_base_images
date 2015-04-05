FROM ruby:2.2
MAINTAINER Vlad Ghinea vlad@ghn.me

EXPOSE 8523
WORKDIR /tmp/agent

COPY Gemfile /tmp/agent/Gemfile
RUN bundle install

