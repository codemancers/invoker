Invoker is a gem for managing processes in development environment.

[![Build Status](https://travis-ci.org/code-mancers/invoker.png)](https://travis-ci.org/code-mancers/invoker)
[![Code Climate](https://codeclimate.com/repos/51d3bfb9c7f3a3777b060155/badges/7e150ca223f6bc8935f7/gpa.png)](https://codeclimate.com/repos/51d3bfb9c7f3a3777b060155/feed)

## Usage ##

First we need to install `invoker` gem to get command line utility called `invoker`, we can do that via:

    gem install invoker

Currently it only works with Ruby 1.9.3 and 2.0.

You need to start by creating a `ini` file which will define processes you want to manage using invoker. An example
`ini` file is included in the repo.

    [rails]
    directory = /home/gnufied/god_particle
    command = zsh -c 'bundle exec rails s -p 5000'

    [dj]
    directory = /home/gnufied/god_particle
    command = zsh -c 'bundle exec ruby script/delayed_job'

    [events]
    directory = /home/gnufied/god_particle
    command = zsh -c 'bundle exec ruby script/event_server'

After that you can start process manager via:

    ~> invoker start invoker.ini

Above command will start all your processes in one terminal with their stdout/stderr merged and labelled.

Now additionally you can control individual process by,

    # Will try to stop running delayed job by sending SIGINT to the process
    ~> invoker remove dj

    # If Process can't be killed by SIGINT send a custom signal
    ~> invoker remove dj -s 9

    # add and start running
    ~> invoker add dj

    # List currently running processes managed by invoker
    ~> invoker list

    # Restart process given by command Label
    ~> invoker reload dj

    # Restart process given by command label using specific signal for killing
    ~> invoker reload dj -s 9

You can also enable OSX notifications for crashed processes by installing `terminal-notifier` gem. It is not a dependency, but can be useful if something crashed and you weren't paying attention.

## Using with rbenv or rvm ##

The way `rbenv` and `rvm` work sometimes creates problems when you are trying to use a process supervisor like `invoker`. There are couple of things to keep in mind,
If you are running `invoker` with Ruby version x, but your application requires Ruby version Y:

* When using `rbenv`, you can define the command with environment variable `RBENV_VERSION=Y` and then start your application. In other words:

        command = RBENV_VERSION=2.0.0-p0 zsh -c "bundle exec rails s"

* Unless version of Ruby using which you are running `invoker` command and version of Ruby you are using in the application is same, you almost always will want to use
`zsh -c` or `bash -c`. `RVM` in particular requires a login shell and hence sometimes you may have to use `bash -lc`. For example:

        command = bash -lc "rvm 2.0.0-p0 do bundle exec rails s"


## Bug reports and Feature requests

Please use [Github Issue Tracker](https://github.com/code-mancers/invoker/issues) for feature requests or bug reports.
