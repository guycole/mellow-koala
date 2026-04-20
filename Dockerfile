FROM ruby:3.4.9-slim

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential \
      libpq-dev \
      libyaml-dev \
      curl \
      git \
      nodejs \
      npm && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

WORKDIR /rails

ENV RAILS_ENV=production

COPY Gemfile Gemfile.lock ./
RUN bundle config set --local without 'development test' && \
    bundle install

COPY . .

<<<<<<< HEAD
RUN RAILS_ENV=production SECRET_KEY_BASE=dummy bundle exec rails assets:precompile
=======
RUN SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile
>>>>>>> 395e2f72e16faf4887f65e1c9c163f6bcc16531e

EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
