require File.expand_path('../../../lib/guard/brakeman',  __FILE__)
require 'aruba/cucumber'
require 'aruba/java' if RUBY_PLATFORM == 'java'

Before do
  @aruba_timeout_seconds = 20
end


After do
  content = <<-EOF
# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
end
	EOF

  overwrite_file(File.expand_path('tmp/aruba/default_app/app/controllers/application_controller.rb'), content)
end