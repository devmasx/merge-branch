FROM ruby:2.6.3-slim

RUN gem install octokit

COPY index.rb /action/index.rb
