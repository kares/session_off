# -*- encoding: utf-8 -*-
Gem::Specification.new do |gem|
  gem.name        = "session_off"
  gem.version     = '0.5.1'
  gem.platform    = Gem::Platform::RUBY
  gem.authors     = ["Karol Bucek"]
  gem.email       = ["self@kares.org"]
  gem.homepage    = "http://github.com/kares/session_off"
  gem.summary     = "declarative session :off 'backported' from Rails 2.2"
  gem.description = "session :off, :only => :foo, :if => Proc.new { |req| req.params[:bar] }"
  gem.licenses    = ['Apache-2.0']

  gem.require_path = 'lib'
  gem.files        = Dir.glob("lib/*") + %w( LICENSE README.md Rakefile )
  gem.test_files   = Dir.glob("test/*.rb")

  gem.add_dependency 'actionpack', '>= 2.3'
  gem.add_development_dependency 'rake', '~> 10.3.2'
  gem.add_development_dependency 'minitest', '>= 4.7'
  gem.add_development_dependency 'mocha', '~> 0.13.0'

  gem.extra_rdoc_files = [ "README.md" ]
  gem.rubyforge_project = '[none]'
end