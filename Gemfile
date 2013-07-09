source "https://rubygems.org"

gemspec

# RAILS_VERSION=3.2.13 bundle update rails
rails_version = ENV['RAILS_VERSION'] || ''
unless rails_version.empty?
  gem 'rails', rails_version
else
  gem 'rails'
end

gem 'rake', :require => nil

group :test do
  gem 'mocha', '~> 0.13.0', :require => false
  gem 'test-unit', '2.5.4'
end
