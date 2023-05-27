OPTIONAL_GEMS = {
  # gem name => environments
  "devise" => nil,
}

def apply_template!
  add_template_repository_to_source_path

  git_commit("Initial commit", init: true)

  copy_file "config/application.rb"
  copy_file "config/initializers/sidekiq.rb"
  copy_file "config/initializers/redis.rb"
  git_commit("Sets config/ files")

  setup_gems

  return
  apply "app/template.rb"

  run "yarn add tailwindcss postcss postcss-flexbugs-fixes postcss-import postcss-nested"
  run "yarn add @tailwindcss/forms @tailwindcss/typography"
  run "npx tailwindcss init"
  copy_file "tailwind.config.js"

  # Setup database
  rails_command "db:create"
  rails_command "db:migrate"

  # Add root route
  route "root to: 'pages#home'"

  # Generate a Procfile for `foreman` and Heroku
  file(
    "Procfile.dev",
    <<~PROCFILE
      web: bin/rails server -p 3000
      js: yarn build --watch
      css: yarn build:css --watch
    PROCFILE
  )

  inject_into_file 'package.json', before: "^}" do <<-'RUBY'
    ,
    "scripts": {
      "build": "esbuild app/javascript/*.* --bundle --sourcemap --outdir=app/assets/builds --public-path=assets",
      "build:css": "tailwindcss --postcss -i ./app/assets/stylesheets/application.tailwind.css -o ./app/assets/builds/application.css"
    }
  RUBY
  end

  git add: "."
  git commit: '-a -m "Rails template applied"'

  puts "Done!"
  puts "Run `foreman start -f Procfile.dev` to start the app."
end

require "fileutils"
require "shellwords"

# Taken from https://github.com/mattbrictson/rails-template/blob/master/template.rb
#
# Add this template directory to source_paths so that Thor actions like
# copy_file and template resolve against our source files. If this file was
# invoked remotely via HTTP, that means the files are not present locally.
# In that case, use `git clone` to download them to a local temporary dir.
def add_template_repository_to_source_path
  if __FILE__ =~ %r{\Ahttps?://}
    require "tmpdir"
    source_paths.unshift(tempdir = Dir.mktmpdir("rails-template-"))
    at_exit { FileUtils.remove_entry(tempdir) }
    git clone: [
      "--quiet",
      "https://github.com/kurko/rails-template.git",
      tempdir,
    ].map(&:shellescape).join(" ")

    if (branch = __FILE__[%r{rails-template/(.+)/template.rb}, 1])
      Dir.chdir(tempdir) { git checkout: branch }
    end
  else
    source_paths.unshift(File.dirname(__FILE__))
  end
end

def git_commit(message, init: false)
  git :init if init
  git add: "."
  git commit: "-a -m \"[rails-template] #{message}\""
end

def setup_gems
  gem "amazing_print"
  gem "clockwork"
  copy_file "config/clock.rb"

  gem "cssbundling-rails"
  gem "dotenv-rails"
  gem "friendly_id"
  gem "jsbundling-rails"
  gem "hiredis"
  # Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
  gem "kredis"
  gem "redis"
  gem 'redis-store'
  gem 'redis-rails'
  # This is deprecated but some gems need it (e.g devise:install). Despite being
  # in the Gemfile, we will use cssbundling-rails to handle sass.
  gem "sassc-rails"
  gem "sidekiq"
  gem "parallel"

  gem_group :development, :test do
    gem "factory_bot_rails"
    gem "faker"
    gem "rspec-rails"
  end

  gem_group :development do
    gem "annotate"
    gem "better_errors"
    gem "foreman"
    gem "happy_gemfile"
    gem "spring"
    gem "spring-commands-rspec"
  end

  gem_group :test do
    gem "capybara"
    gem "launchy"
    gem "selenium-webdriver"
    gem "webdrivers"
  end

  run "bundle install --quiet"
  git_commit("Basic gems installed")

  OPTIONAL_GEMS.each do |gem_name, environments|
    next unless yes?("Install `#{gem_name}`? [Y/n]")

    if respond_to?(:"install_#{gem_name}")
      send(:"install_#{gem_name}", environments)
    else
      install_gem(gem_name, environments)
    end
  end

  #run "bundle exec happy_gemfile all"
  git_commit("organizes Gemfile with happy_gemfile")
end

def install_devise(environments)
  install_gem(:devise, environments)

  # Run Devise generators
  generate "devise:install"

  # Get the `User` model name
  model_name = ask("What is the user model? [User]")
  model_name = "User" if model_name.blank?

  # Setup action mailer default url options (needed by Devise)
  environment 'config.action_mailer.default_url_options = { host: "localhost", port: 5000 }', env: "development"

  # Run Devise User generators
  generate "devise", model_name
end

def install_gem(gem_name, environments)
  # Add devise to Gemfile
  if environments.nil?
    gem gem_name.to_s
  else
    gem_group(*Array(environments)) do
      gem gem_name.to_s
    end
  end
  run "bundle install"
end

apply_template!
