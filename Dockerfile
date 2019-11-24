FROM ruby:2.6.3-alpine

RUN gem install octokit

COPY lib /action/lib

CMD ["ruby", "/action/lib/index.rb"]
