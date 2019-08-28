# v1.5.7
* Enable Manjaro Linux support
* Ensure same color is re-used for next started process, which is helpful to maintain consistency when using `reload` command (https://github.com/code-mancers/invoker/pull/230)

# v1.5.6
* Change default tld from .dev to .test (https://github.com/code-mancers/invoker/pull/208)

# v1.5.5
* Fix high cpu usage when process managed by Invoker crashes and Invoker doesn't read from its socket.(https://github.com/code-mancers/invoker/pull/198)
* Allow users to specify custom ssl certificate and key (https://github.com/code-mancers/invoker/pull/199)
* Remove rainbow dependency and migrate to colorize

# v1.5.4
* Add support for running Invoker build in SELinux environments (https://github.com/code-mancers/invoker/pull/188)
* Add an option to print process listing in raw format. This enables us to see complete process list (https://github.com/code-mancers/invoker/pull/193)
* Fix colors in console output (https://github.com/code-mancers/invoker/pull/192)
* Add a new option to optionally disable colors in log when starting invoker (#196)
* Handle TERM and INT signals when stopping invoker. (#196)

## v1.5.3

* Always capture STDOUT/STDERR of process to invoker's log file, if invoker is daemonized. (https://github.com/code-mancers/invoker/pull/186)
* Add a command for filtering all logs for a process. (https://github.com/code-mancers/invoker/pull/186)
* Prefer Procfile.dev to Procfile (https://github.com/code-mancers/invoker/pull/183)
* Downgrade Rainbow version to prevent compilation errors in certain environments (https://github.com/code-mancers/invoker/pull/180)
* Non existant PWD environment variable may cause errors while starting a process (https://github.com/code-mancers/invoker/pull/179)
* Implement support for specifying process ordering. This allows user to be explicit about
  order in which Invoker should start processes from ini file (https://github.com/code-mancers/invoker/pull/174)
* Return correct version of Invoker in HTTP header (https://github.com/code-mancers/invoker/pull/173)
