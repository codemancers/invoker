Necro is a gem for managing processes in development environment.

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

    # stop running dj
    ~> necro remove dj
    
    # add and start running
    ~> necro add dj
    
That is about it.     
    



