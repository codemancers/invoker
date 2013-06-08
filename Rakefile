desc "Run the tests"
task :spec do
  spec_files = Dir["spec/**/*.rb"]
  sh("bacon -I spec #{spec_files.join(" ")}")
end
