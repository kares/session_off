Gem::Specification.new do |s|
  s.name        = "session_off"
  s.version     = '0.3'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Karol Bucek"]
  s.email       = ["self@kares.org"]
  s.homepage    = "http://github.com/kares/session_off"
  s.summary     = "declarative session :off from Rails 2.2 'backported'"
  s.description = "`session :off, :only => :foo, :if => Proc.new { |req| req.params[:bar] }`"
 
  s.files        = Dir.glob("lib/*") + %w( LICENSE README.md Rakefile )
  s.require_path = 'lib'
  s.test_files   = Dir.glob("test/*.rb")
 
  s.add_dependency 'actionpack', '>= 2.3'
  s.add_development_dependency "mocha"
  
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to?(:required_rubygems_version=)
  s.extra_rdoc_files = [ "README.md" ]
  s.rubyforge_project = '[none]'
end