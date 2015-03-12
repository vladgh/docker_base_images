FROM ruby:2.2
MAINTAINER Vlad Ghinea vlad@ghn.me

ADD Gemfile /tmp/agent/Gemfile
WORKDIR /tmp/agent
RUN bundle install

EXPOSE 8523
