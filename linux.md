---
layout: default
title: Using Invoker on Linux
---

## Using on Linux

All the features of Invoker has been tested to work with various versions of `Ubuntu` (which includes -
`kubuntu`, `xubuntu` etc), `ArchLinux` and `Fedora` Linux. Contributions for making it work on other distros are more than welcome.

On Linux - `Invoker` uses `dnsmasq` and `rinetd` for DNS and port forwarding respectively. Same as setup
on OSX, you can start Invoker setup by running command:

{% highlight bash %}
~> sudo invoker setup
{% endhighlight %}

Above command will install and configure all the dependencies correctly, so as using `Invoker` can be
as painless as possible.

## Troubleshooting

On `Linux` machines - `sudo` does not preserve path and hence I recommend adding following alias:

{% highlight bash %}
alias sudo='sudo env PATH=$PATH'
{% endhighlight %}

before running `sudo invoker setup`. If you are using `rvm`, you should use `rvmsudo`. See
<a href="/ruby_managers.html"> Using with rvm, rbenv or chruby </a> section for more information.
