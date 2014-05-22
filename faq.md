---
layout: default
title: Invoker - A Process Manager
---
## FAQ

<em> 1. Does Invoker work with pow? </em>

On OSX - If you have already installed pow, Invoker will
have a conflict with it.
You will be prompted to overwrite pow setup with Invoker. You should
uninstall pow before running Invoker setup.

If DNS does not work after running invoker setup. Try turning wi-fi on and off.

<em> 2. How do I undo Invoker setup? </em>

Short answer - you can just run `sudo invoker uninstall` or manually depending on your operating system:

a. On OSX - you have to first remove DNS resolver file in `/etc/resolver/dev` and then firewall rule that port forwards incoming requests on port `80` and `443` to another port.

You can remove Invoker setup by removing `/etc/resolver/dev` and by running `sudo launchctl unload -w com.codemancers.invoker.firewall.plist`. Finally remove this file `/Library/LaunchDaemons/com.codemancers.invoker.firewall.plist`.

b. On `Ubuntu` - you can first uninstall `dnsmasq` and `rinetd` packages and after that you can remove following files:
<ul style="margin-left:50px;">
  <li> `/etc/dnsmasq.d/dev-tld` </li>
  <li> `/etc/rinetd.conf` </li>
</ul>

Additionally you can also delete `Invoker` configuration file from `$HOME/.invoker`.
