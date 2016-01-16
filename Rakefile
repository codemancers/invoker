require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new

task :default => :spec
task :test => :spec

desc "run specs inside docker"
task :docker_spec do
  system("docker run -t invoker-ruby")
end
