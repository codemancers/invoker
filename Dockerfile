FROM ruby:2.3

MAINTAINER hemant@codemancers.com

RUN apt-get update && apt-get -y install dnsmasq socat

CMD cd /invoker && bundle install --path vendor/ && bundle exec rake spec
