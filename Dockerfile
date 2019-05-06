FROM ruby:2.5

WORKDIR /usr/src/app
RUN locale-gen de_DE.UTF-8 && update-locale LANG=de_DE.UTF-8
RUN bundle config
COPY . .
RUN bundle install

EXPOSE 9393
ENTRYPOINT ["ruby", "meetingroom.rb"]
