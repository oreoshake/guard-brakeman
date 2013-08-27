# encoding: utf-8

Gem::Specification.new do |s|
  s.name        = 'guard-brakeman'
  s.version     = '0.7.1'
  s.platform    = Gem::Platform::RUBY
  s.license     = 'MIT'
  s.authors     = ['Neil Matatall', 'Justin Collins']
  s.homepage    = 'https://github.com/guard/guard-brakeman'
  s.summary     = 'Guard gem for Brakeman'
  s.description = 'Guard::Brakeman automatically scans your Rails app for vulnerabilities using the Brakeman Scaner https://github.com/presidentbeef/brakeman'

  s.rubyforge_project         = 'guard-brakeman'

  s.add_dependency 'guard',   '>= 1.1.0'
  s.add_dependency 'brakeman', '>= 1.8.2'

  s.files        = Dir.glob('{lib}/**/*') + %w[LICENSE README.md]
  s.require_path = 'lib'

  s.rdoc_options = ["--charset=UTF-8", "--main=README.md", "--exclude='(test|spec)|(Gem|Guard|Rake)file'"]
end
