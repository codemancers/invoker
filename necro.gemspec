# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{necro}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Hemant Kumar"]
  s.date = %q{2013-05-04}
  s.description = %q{Something small for process management}
  s.email = %q{hemant@codemancers.com}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.homepage = %q{http://github.com/codemancers/necro}
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.summary = %q{Something small for Process management}
  s.add_dependency("slop")
  s.add_dependency("iniparse")
  s.add_dependency("colored")
  s.add_development_dependency("bacon")
  s.add_development_dependency("mocha")
  s.add_development_dependency("mocha-on-bacon")
  s.add_development_dependency("rake")
end

