require 'json'

# These gems need to be approved  (e.g yes()) before they are installed
OPTIONAL_GEMS = {
  # gem name => environments
  "devise" => nil,
}

def apply_template!
  add_template_repository_to_source_path

  git_commit("Initial commit", init: true)

  run "echo 'node_modules' >> .gitignore"
  copy_file "config/application.rb", force: true
  copy_file "config/initializers/sidekiq.rb"
  copy_file "config/initializers/redis.rb"
  copy_file "config/initializers/app_env_vars_and_dotenv.rb"
  copy_file ".env"
  copy_file "Procfile", force: true

  copy_file "bin/doctor", force: true
  copy_file "bin/reset_db", force: true
  copy_file "bin/dev-all", force: true
  copy_file "bin/dev-web", force: true
  copy_file "README_TEMPLATE.md", "README.md", force: true
  copy_file "docs/README.md", force: true
  git_commit("Sets config/ files")

  setup_gems


  after_bundle do
    git_commit("Rails initialized")

    apply "app/template.rb"

    # CSS
    run "yarn add --silent tailwindcss postcss postcss-flexbugs-fixes postcss-import postcss-nested autoprefixer postcss-preset-env"
    run "yarn add --silent @tailwindcss/forms @tailwindcss/typography @tailwindcss/aspect-ratio"
    run "npx tailwindcss init"
    copy_file "tailwind.config.js", force: true
    copy_file "postcss.config.js", force: true
    # Javascript
    run "yarn add --silent esbuild @hotwired/turbo-rails @hotwired/stimulus"

    # Setup database
    copy_file "config/database.yml", force: true
    gsub_file "config/database.yml", "{{APP_NAME}}", app_name.underscore
    run "bin/setup"

    # Add root route
    route "root to: 'pages#home'"

    setup_package_json
    setup_tests

    puts "• Done!"
    puts "• Run `bin/dev-web` to start the web app."
  end
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
  puts "• Setting up gems..."

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
    gem "binding_of_caller"
    gem "foreman"
    gem "happy_gemfile"
    gem "spring"
    gem "spring-commands-rspec"
  end

  gem_group :test do
    # Capybara, Selenium, and ChromeDriver for system testing are already part
    # of new rails apps by default
    gem "database_cleaner"
    gem "launchy"
    gem "webmock"
  end

  run "bundle install --quiet"
  git_commit("Basic gems installed")

  OPTIONAL_GEMS.each do |gem_name, environments|
    next if skip_command?(gem_name) || !yes?("Install `#{gem_name}`? [Y/n]")

    if respond_to?(:"install_#{gem_name}")
      send(:"install_#{gem_name}", environments)
    else
      install_gem(gem_name, environments)
    end
  end

  # TODO - should run this for organizing the Gemfile?
  #
  # run "bundle exec happy_gemfile all"
  # git_commit("organizes Gemfile with happy_gemfile")
end

def setup_tests
  puts "• Setting up tests..."
  copy_file "spec/support/fixtures.rb", force: true
  copy_file "spec/spec_helper.rb", force: true
  copy_file "spec/rails_helper.rb", force: true
  copy_file "spec/lib/testing_the_suite_spec.rb", force: true
  # Create a new directory
  empty_directory "spec/fixtures/"
  # Create a .keep file in the new directory
  create_file "spec/fixtures/.keep"
  git_commit("adds tests")
  puts "• Running tests..."
  run "bundle exec rspec spec"
end

def install_devise(environments)
  puts "• Installing Devise..."
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
  run "bundle install --quiet"
end

def setup_package_json
  puts "• Setting up package.json..."
  # Read the file
  file_path = 'package.json'
  json = JSON.parse(File.read(file_path))

  # Add new scripts to the existing JSON
  json['scripts'] = {
    'build' => 'esbuild app/javascript/*.* --bundle --sourcemap --outdir=app/assets/builds --public-path=assets',
    'build:css' => 'tailwindcss --postcss -i ./app/assets/stylesheets/application.tailwind.css -o ./app/assets/builds/application.css'
  }

  # Write the modified JSON back to the file
  File.open(file_path, 'w') do |file|
    file.write(JSON.pretty_generate(json))
  end
  git_commit("add scripts to package.json")
end

def skip_command?(command)
  if ARGV.include?("--skip-#{command}")
    say "Skipping #{command} installation..."
    return true
  end
  false
end

apply_template!
