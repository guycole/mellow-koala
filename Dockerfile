FROM ruby:3.4.3-slim

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

COPY Gemfile Gemfile.lock ./
RUN bundle config set --local without 'development test' && \
    bundle install

COPY . .

RUN RAILS_ENV=production SECRET_KEY_BASE=dummy bundle exec rails assets:precompile

EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
