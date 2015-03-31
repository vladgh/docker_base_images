FROM ruby:2.2
MAINTAINER Vlad Ghinea vlad@ghn.me

COPY Gemfile /tmp/agent/Gemfile
WORKDIR /tmp/agent
RUN bundle install

EXPOSE 8523
