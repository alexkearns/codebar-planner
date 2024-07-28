FROM public.ecr.aws/docker/library/ruby:3.2.2-bullseye as build

# Install nodejs 20.x
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
RUN apt-get install -y --force-yes build-essential libpq-dev nodejs

# Create a secure user for prod and app directory.
RUN mkdir /app \
  && groupadd -g 10001 app \
  && useradd -u 10000 -g app app \
  && chown -R app:app /app
USER app

# Set working directory
WORKDIR "/app"

# Copy prod application files
COPY --chown=app:app . .

# Set bundle config for build.
RUN bundle config set --local without 'production' && \
  bundle config set --local path 'vendor/bundle' && \
  bundle config set --local jobs 4

# Install gems and precompile assets.
RUN bundle install
RUN bundle exec rake assets:precompile

FROM ghcr.io/rails-lambda/crypteia-extension-debian:1 AS crypteia
FROM public.ecr.aws/docker/library/ruby:3.2.2-bullseye as runtime

# Install Crypteia for secure SSM-backed envs.
COPY --from=crypteia /opt /opt
ENV LD_PRELOAD=/opt/lib/libcrypteia.so

# Install nodejs 20.x
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
RUN apt-get install -y --force-yes build-essential libpq-dev nodejs

# Install aws_lambda_ric
RUN gem install 'aws_lambda_ric'

RUN mkdir /app \
  && groupadd -g 10001 app \
  && useradd -u 10000 -g app app \
  && chown -R app:app /app
USER app
WORKDIR /app

COPY --from=build --chown=app:app /app .

# Set bundle config for production.
RUN bundle config set --local deployment 'true' && \
  bundle config set --local without 'development test' && \
  bundle config set --local path 'vendor/bundle' && \
  bundle config set --local jobs 4

# Re-install gems, keeping only production ones.
RUN bundle install

ENV RAILS_SERVE_STATIC_FILES=1

ENTRYPOINT [ "/usr/local/bundle/bin/aws_lambda_ric" ]
CMD ["config/environment.Lamby.cmd"]