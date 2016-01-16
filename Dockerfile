FROM ruby:2.3

MAINTAINER hemant@codemancers.com

RUN apt-get update && apt-get -y install dnsmasq socat

ADD . /invoker
RUN cd /invoker && bundle
CMD cd /invoker && bundle exec rake spec
