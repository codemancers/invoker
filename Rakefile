require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new

task :default => :spec
task :test => :spec

current_directory = File.expand_path(File.dirname(__FILE__))

desc "run specs inside docker"
task :docker_spec do
  system("docker build -t invoker-ruby . ")
  system("docker run --name invoker-rspec --rm -v #{current_directory}:/invoker -t invoker-ruby")
end
