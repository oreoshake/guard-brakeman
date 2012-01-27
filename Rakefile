require "rake"
require "rake/testtask"
require "rspec/core/rake_task"


desc "Default: run unit tests."
task :default => [:spec]

RSpec::Core::RakeTask.new(:spec) do |t|
  t.fail_on_error = false
  t.verbose = true
end