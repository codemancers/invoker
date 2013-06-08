Necro is a gem for managing processes in development environment.

[![Build Status](https://travis-ci.org/code-mancers/necro.png)](https://travis-ci.org/code-mancers/necro)


## Usage ##

You need to start by creating a `ini` file which will define processes you want to manage using necro. An example
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

    ~> necro start necro.ini
    
Above command will start all your processes in one terminal with their stdout/stderr merged and labelled.

Now additionally you can control individual process by,

    # Will try to stop running delayed job by sending SIGINT to the process
    ~> necro remove dj

    # If Process can't be killed by SIGINT send a custom signal
    ~> necro remove dj -s 9

    # add and start running
    ~> necro add dj
    
You can also enable OSX notifications for crashed processes by installing `terminal-notification` gem. It is not a dependency, but can be useful if something crashed and you weren't paying attention.    
    

## Bug reports, Feature requests ## 

Please use [Github Issue Tracker](https://github.com/code-mancers/necro/issues) for feature requests or bug reports.





