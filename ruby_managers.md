---
layout: default
title: Using Invoker with Ruby version managers
---
## Using Invoker with rvm, rbenv or chruby.

The way `rbenv`, `chruby` and `rvm` work sometimes creates problems when you are trying to use a process supervisor like invoker. There are couple of things to keep in mind,
If you are running invoker with Ruby version x, but your application requires Ruby version Y:

### Using with rbenv

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

### Using with RVM

When using Invoker on RVM, you may have success running `invoker setup` with:

{% highlight bash %}
~> rvmsudo invoker setup
{% endhighlight %}

RVM in particular requires a login shell and hence sometimes you may have to use `bash -lc`. For example:

{% highlight bash %}
command = bash -lc "rvm 2.0.0-p0 do bundle exec rails s"
{% endhighlight %}

### Using with chruby

Ensure that the `source` directive is present in the `~/.bashrc` or
`~/.zshrc`.

#### Linux
Due to the way non-sudo gem installs work in chruby, invoker should be
installed using this command:

{% highlight bash %}
~> gem install invoker --bindir $RUBY_ROOT/bin
{% endhighlight %}

Once that is done, the setup can be run like so:

{% highlight bash %}
~> sudo -E chruby-exec ruby-2.1.2 -- invoker setup
{% endhighlight %}

Or, if you installed the gem without the `--bindir` option, you can
supply the path of the executable directly:

{% highlight bash %}
~> sudo -E chruby-exec ruby-2.1.2 -- $GEM_HOME/bin/invoker setup
{% endhighlight %}

Where `ruby-2.1.2` is version of Ruby; replace it with whatever version
you have installed. Once the setup is run successfully, running the
invoker process is straight forward.


{% highlight bash %}
~> invoker start Procfile
{% endhighlight %}

#### Mac

If you're running Mac OSX and have chruby installed on it, there are no
special instructions you need to follow. By default, chruby should pick
up the invoker binary even when run under `sudo`.

{% highlight bash %}
~> gem install invoker
~> sudo invoker setup
{% endhighlight %}
