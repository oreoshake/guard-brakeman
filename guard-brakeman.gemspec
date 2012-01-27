# encoding: utf-8
$:.push File.expand_path('../lib', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'guard-brakeman'
  s.version     = "0.1.4"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Neil Matatall']
  s.email       = ['neil@matatall.com']
  s.homepage    = 'http://rubygems.org/gems/guard-brakeman'
  s.summary     = 'Guard gem for Brakeman'
  s.description = 'Guard::Brakeman automatically scans your Rails app for vulnerabilities'

  s.rubyforge_project         = 'guard-brakeman'

  s.add_dependency 'guard',   '>= 0.2.2'
  s.add_dependency 'brakeman', '>= 1.2.2'

  s.add_development_dependency 'rspec',       '~> 2.6.0'
  s.add_development_dependency 'guard-rspec', '~> 0.3.1'

  s.files        = Dir.glob('{lib}/**/*') + %w[LICENSE README.md]
  s.require_path = 'lib'

  s.rdoc_options = ["--charset=UTF-8", "--main=README.md", "--exclude='(lib|test|spec)|(Gem|Guard|Rake)file'"]
end
