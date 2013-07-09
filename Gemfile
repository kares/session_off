source "https://rubygems.org"

gemspec

gem 'rake', :group => :development
group :test do
  gem 'mocha'
  gem 'test-unit'
  # export RAILS_VERSION=4.0.0.beta1 && bundle update rails
  gem 'rails', ENV['RAILS_VERSION']
end