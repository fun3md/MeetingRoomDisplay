FROM ruby:2.5

WORKDIR /usr/src/app
RUN bundle config
COPY . .
RUN bundle install

CMD ["ruby meetingroom.rb"]


