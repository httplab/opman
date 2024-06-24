#!/usr/bin/env bash

export RAILS_ENV=test

cd spec/dummy
bundle exec rails generate op:install
bundle exec rails db:drop db:create db:migrate
