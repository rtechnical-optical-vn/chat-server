FROM ruby:3.3-slim-bookworm

RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y build-essential libpq-dev curl git && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile Gemfile.lock* ./
RUN bundle install

COPY . .

EXPOSE 3002

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb", "-b", "tcp://0.0.0.0:3002"]
