source "https://rubygems.org"

gemspec

gem 'rake', :group => :development
group :test do
  # NOTE: do not update - otherwise we can not test against 2.3.x :
  gem 'mocha', '~> 0.12.10'
  gem 'test-unit', '2.5.4'
  # export RAILS_VERSION=4.0.0 && bundle update rails
  rails_version = ENV['RAILS_VERSION'] || ''
  unless rails_version.empty?
    gem 'rails', rails_version
  else
    gem 'rails'
  end
end
