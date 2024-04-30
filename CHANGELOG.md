# v2.0.0
* Updated to make compliant for > Ruby 3.0, updated http-parser-lite reference, fixed exists? vs exist? deprecation. (https://github.com/codemancers/invoker/pull/250)

# v1.5.8
* Add `--wait` / `-w` option to `invoker list` to stream updates instead of printing once & exiting (https://github.com/code-mancers/invoker/pull/239)
* Make `Host` header check case-insensitive (https://github.com/code-mancers/invoker/pull/241)

# v1.5.7
* Enable Manjaro Linux support
* Fix setup on Ubuntu w/ systemd-resolved (https://github.com/code-mancers/invoker/pull/233)
* Ensure same color is re-used for next started process, which is helpful to maintain consistency when using `reload` command (https://github.com/code-mancers/invoker/pull/230)
* Add `install` as an alias of `setup` command (https://github.com/code-mancers/invoker/pull/232)
* Change default process sleep duration to 0 (https://github.com/code-mancers/invoker/pull/231)
* Add `restart` as an alias of `reload` command (https://github.com/code-mancers/invoker/pull/229)
* Remove facter dependency (https://github.com/code-mancers/invoker/pull/236)
* Relax dotenv dependency version restriction (https://github.com/code-mancers/invoker/pull/237)
* Relax thor dependency version restriction (https://github.com/code-mancers/invoker/pull/238)

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
