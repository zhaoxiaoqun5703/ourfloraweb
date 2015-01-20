source 'https://rubygems.org'
source 'https://rails-assets.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.0'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby
# Use the json-schema gem for validating imported json
gem 'json-schema'

# Color output from puts for logging
gem 'colorize'

# Detect if the user is mobile, tablet or desktop
gem 'browser'

group :development do
  # Use sqlite3 as the database for Active Record
  gem 'sqlite3'

  # Capistrano for deployment to remote servers
  gem 'capistrano'
  gem 'capistrano-rails'
  gem 'capistrano-rbenv'
  gem 'capistrano-passenger'
  gem 'capistrano-bundler'

  # Use bullet for watching and optimising active record queries
  gem 'bullet'
end

group :deployment do
  gem 'mysql2'
  gem 'therubyracer'
end

# Use activeadmin for managing database
gem 'activeadmin', github: 'activeadmin'
gem 'inherited_resources', github: 'josevalim/inherited_resources', branch: 'rails-4-2'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc
# use devise for user accounts
gem 'devise'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use paperclip for file uploads
gem 'paperclip'

# Front end gems below -----
# Jquery
gem 'rails-assets-jquery'
# Normalize css
gem 'rails-assets-normalize.css'
# Backbone.js for front end MVC framework
gem 'rails-assets-backbone'
# Fastclick.js to remove mobile input delay on clicking elements
gem 'rails-assets-fastclick'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem 'pry'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

