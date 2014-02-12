# ------------------------------------------------------------------------------------------------ #
# BITCE Template for Rails 4
# ------------------------------------------------------------------------------------------------ #
# Version | Date        | Author        | Changes
# 0.1     | 06-Feb-2014 | N.Jobbins     | Inital creation
# ------------------------------------------------------------------------------------------------ #

# Initialise the git repositiry
git :init

##### Install Gems #####
# Authentication & Authorisation
gem 'devise'

# CSS & Javascript
gem 'bootstrap-sass', '~> 3.1.0'                                        # A Sass powered version of Bootstrap
gem 'bootstrap-generators', '~> 3.1.0'                                  # Add generators to create Bootstrap templates

# Template Engine
gem 'haml-rails'                                                        # Replace ERB with Haml

gem_group :development do
  gem 'annotate'
  gem 'debugger'
  gem 'html2haml'
  gem 'mailcatcher'                                                     # Simple SMTP server to catch mail at http://localhost:1080
end

gem_group :test do
  gem 'cucumber-rails', :require => false                               # BDD Test Suite
  gem 'cucumber-rails-training-wheels'                                  # some pre-fabbed step definitions
  gem 'database_cleaner'                                                # to clear Cucumber’s test database between runs
  gem 'capybara'                                                        # lets Cucumber pretend to be a web browser
  gem 'debugger'
  gem 'mailcatcher'                                                     # Simple SMTP server to catch mail at http://localhost:1080
end

gem_group :production do
  if yes?("Do you plan to deploy on Heroku?")
    gem 'rails_12factor' 
    inject_into_file 'Gemfile', :after => "source 'https://rubygems.org'" do
      "\nruby \"2.0.0\";"
    end
  end
end

run "bundle install"

##### Setup #####
### Bootstrap
# inside('app/assets/') do
#   run "mv stylesheets/application.css stylesheets/application.scss"
#   inject_into_file 'stylesheets/application.scss', :after => "*/" do
#     "\n\n @import \"bootstrap\";"
#   end
# end
generate "bootstrap:install --template-engine=haml"           # Install Bootstrap Generators for Haml
run "rm app/views/layouts/application.html.erb"                         # Delete the ERB Application template

### Devise
# Setup environment for Devise Mailer
environment(nil, env: "development") do
  "# BITCE Template: Mailer for Devise
  config.action_mailer.smtp_settings = {:address => 'localhost', :port => 1025}
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.default_url_options = { :host => 'localhost:3000' }"
end
environment(nil, env: "production") do
  "# BITCE Template: Mailer for Devise using Environment Variables
  config.action_mailer.default_url_options = { :host => ENV['MAILER_HOST'] }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
      :address    => ENV['SMTP_ADDRESS'],
      :port       => ENV['SMTP_PORT'],
      :user_name  => ENV['SMTP_USERNAME'],
      :password   => ENV['SMTP_PASSWORD'],
      :domain     => ENV['SMTP_DOMAIN'],
      :authentication  => :plain,
      :enable_starttls_auto => true
  }
  # BITCE Template: Set Secret Key Base to Environment Variable
  config.secret_key_base = ENV['SECRET_KEY_BASE']"
end

# Install and convert views
generate "devise:install"                                               # Install Devise
generate "devise", "User"                                               # Generate a defualt User Model
rake "db:migrate"
generate "devise:views"                                                 # Generate Devise views to allow customisation
run "for file in app/views/devise/**/*.erb; do html2haml -e $file ${file%erb}haml && rm $file; done"
append_file 'db/seeds.rb' do
  "User.create!(:email=>'admin@bitce.co.uk', :password=>'letmein!')\n"
end
rake "db:seed"

# Create Default Controller and Route
generate "controller", "welcome index"
route "root to: 'welcome#index'"

# Initialise the git repositiry
git add: "."
git commit: "-a -m 'Initial commit of template app'"

if yes?("Shall I create a Staging Environment on Heroku?")
  run "heroku create --remote staging"
end
