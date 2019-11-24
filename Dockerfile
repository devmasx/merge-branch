FROM ruby:2.6.3-slim

RUN gem install octokit

COPY lib /action/lib

CMD ["ruby", "/action/lib/index.rb"]
