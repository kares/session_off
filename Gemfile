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
  if minitest_version = ENV['MINITEST_VERSION']
  	gem 'minitest', minitest_version, :require => nil
  elsif RUBY_VERSION =~ /1\.8/
  	gem 'minitest', '~> 4.7.5', :require => nil
  else
  	gem 'minitest', :require => nil
  end
end