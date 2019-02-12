FROM ruby:2.5

WORKDIR /usr/src/app
RUN bundle config
COPY . .
RUN bundle install

EXPOSE 9393
ENTRYPOINT ["ruby", "meetingroom.rb"]