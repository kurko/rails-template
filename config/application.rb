require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RailsTemplate
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "America/Sao_Paulo"
    config.eager_load_paths << Rails.root.join("lib")

    # We will use lib for domain specific code.
    config.autoload_paths << "#{root}/lib"

    config.generators do |g|
      g.test_framework :rspec
      g.fixture_replacement :factory_bot
      g.factory_bot dir: 'spec/factories'
      g.controller_specs false
      g.request_specs true
      g.helper_specs false
      g.feature_specs true
      g.mailer_specs true
      g.model_specs true
      g.observer_specs false
      g.routing_specs false
      g.view_specs false
    end
  end
end
