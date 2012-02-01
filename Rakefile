require "rake"
require "rake/testtask"
require "rspec/core/rake_task"
require "cucumber/rake/task"


desc "Default: run unit tests."
task :default => [:spec, :cukes]

RSpec::Core::RakeTask.new(:spec) do |t|
  t.fail_on_error = false
  t.verbose = true
end

Cucumber::Rake::Task.new(:cukes) do |t|
  t.cucumber_opts = %w{--format progress}
end