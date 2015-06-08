source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.1.10'
# Use postgresql as the database for Active Record
gem 'pg'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer',  platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0',          group: :doc

gem 'azure',
    github: 'Azure/azure-sdk-for-ruby',
    branch: 'master',
    ref: 'e61400c9b8f184da74a1723495b503340218c637'

gem 'atmosphere',
    github: 'dice-cyfronet/atmosphere',
    branch: 'azure-1-june'

gem 'active_model_serializers', '0.8.1'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

gem 'omniauth-vph'

# Cross-Origin Resource Scharing for external UIs
gem 'rack-cors', :require => 'rack/cors'

group :development do
  gem 'annotate'
  gem 'quiet_assets'
  gem 'letter_opener'
  # gem 'rack-mini-profiler'

  # Better error page
  gem 'better_errors'
  gem 'binding_of_caller'

  gem 'rails_best_practices'

  gem 'foreman'
end

group :development, :test do
  gem 'pry-rails'

  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'guard-rspec', require: false
end

group :test do
  gem 'rspec-rails'
  gem 'rspec-sidekiq'
  gem 'shoulda-matchers'

  gem 'factory_girl'
  gem 'ffaker'
  gem 'database_cleaner'
end

gem 'puma'
gem 'clockwork'
gem 'newrelic_rpm'
