FROM ruby:2.6.3-alpine

WORKDIR /action
COPY Gemfile Gemfile.lock /action/
RUN bundle install
COPY lib /action/lib

CMD ["ruby", "/action/lib/index.rb"]
