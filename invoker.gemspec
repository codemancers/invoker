# -*- encoding: utf-8 -*-

GEM_NAME = "invoker"

lib = File.expand_path("../lib", __FILE__)
$: << lib unless $:.include?(lib)

require "invoker/version"

Gem::Specification.new do |s|
  s.name = GEM_NAME
  s.version = Invoker::VERSION

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Hemant Kumar", "Amitava Basak"]
  s.description = %q{Something small for process management}
  s.email = %q{hemant@codemancers.com}

  s.files         = Dir.glob("lib/**/*")
  s.test_files    = Dir.glob("spec/**/*")
  s.executables   = Dir.glob("bin/*").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.homepage = %q{https://invoker.codemancers.com}
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.summary = %q{Something small for Process management}

  s.metadata = {
    "bug_tracker_uri" => "https://github.com/code-mancers/invoker/issues",
    "changelog_uri" => "https://github.com/code-mancers/invoker/blob/master/CHANGELOG.md",
    "documentation_uri" => "https://invoker.codemancers.com/",
    "source_code_uri" => "https://github.com/code-mancers/invoker/tree/v#{Invoker::VERSION}",
  }

  s.add_dependency("thor", "~> 0.19")
  s.add_dependency("colorize", "~> 0.8.1")
  s.add_dependency("iniparse", "~> 1.1")
  s.add_dependency("formatador", "~> 0.2")
  s.add_dependency("eventmachine", "~> 1.0.4")
  s.add_dependency("em-proxy", "~> 0.1")
  s.add_dependency("rubydns", "~> 0.8.5")
  s.add_dependency("uuid", "~> 2.3")
  s.add_dependency("http-parser-lite", "~> 0.6")
  s.add_dependency("dotenv", "~> 2.0", "!= 2.3.0", "!= 2.4.0")
  s.add_development_dependency("rspec", "~> 3.0")
  s.add_development_dependency("mocha")
  s.add_development_dependency("rake")
  s.add_development_dependency('fakefs')
end
