---
layout: default
title: Using Invoker with Ruby version managers
---
## Using Invoker with rvm, rbenv or chruby.

The way `rbenv`, `chruby` and `rvm` work sometimes creates problems when you are trying to use a process supervisor like invoker. There are couple of things to keep in mind,
If you are running invoker with Ruby version x, but your application requires Ruby version Y:

<em> 1. Using with rbenv </em>

When using rbenv and zsh, remember that `.zshrc`
is not read for commands run via `zsh -c`. So first
add:

{% highlight bash %}
~> cat > ~/.zshenv
eval "$(rbenv init -)"
{% endhighlight %}

and then run it using:

{% highlight bash %}
command = RBENV_VERSION=2.0.0-p0 zsh -c "bundle exec rails s"
{% endhighlight %}

Unless version of Ruby using which you are running invoker command and version of Ruby you are using in the application is same, you almost always will want to use
`zsh -c` or `bash -c`.

<em> 2. Using with RVM </em>

When using Invoker on RVM, you may have success running `invoker setup` with:

{% highlight bash %}
~> rvmsudo invoker setup
{% endhighlight %}

RVM in particular requires a login shell and hence sometimes you may have to use `bash -lc`. For example:

{% highlight bash %}
command = bash -lc "rvm 2.0.0-p0 do bundle exec rails s"
{% endhighlight %}

<em> 3. Using with chruby </em>

When using Invoker with chruby, for running setup try:

{% highlight bash %}
~> sudo -E chruby-exec ruby-2.1.2 -- invoker setup
{% endhighlight %}

Above command though may not work on `Linux` and you may have to run it with:

{% highlight bash %}
~> sudo -E chruby-exec ruby-2.1.2 -- ~/.gem/ruby/bin/invoker setup
{% endhighlight %}

Where `ruby-2.1.2` is version of Ruby and `~/.gem/ruby/bin` is PATH where gem binaries are installed by
chruby. For usual usage you should try with:

{% highlight bash %}
[thenextsnapchat]
directory = /Users/jarinudom/projects/thenextsnapchat
command = chruby-exec $(cat .ruby-version) -- bundle exec rails s -p $PORT
{% endhighlight %}
