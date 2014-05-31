source "https://rubygems.org"

gemspec

# RAILS_VERSION=3.2.13 bundle update rails
rails_version = ENV['RAILS_VERSION'] || ''
unless rails_version.empty?
  gem 'rails', rails_version
else
  gem 'rails'
end

group :development, :test do
  gem 'rake', :require => nil
  gem 'minitest', '~> 4.7', :require => nil if RUBY_VERSION =~ /1\.8/
end