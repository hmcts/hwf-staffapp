require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
# require "active_job/railtie"
require "active_record/railtie"
require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"
require "action_text/engine"
require "action_view/railtie"
# require "action_cable/engine"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

if ['development', 'test'].include? ENV['RAILS_ENV']
  Dotenv::Rails.load
end

module FrStaffapp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: ['assets', 'tasks'])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Don't generate system test files.
    config.generators.system_tests = nil

    config.i18n.load_path += Rails.root.glob('config/locales/**/*.{rb,yml}')
    config.i18n.default_locale = 'en-GB'

    if ENV['AZURE_APP_INSIGHTS_INSTRUMENTATION_KEY'].present?
      config.middleware.use(
        ApplicationInsights::Rack::TrackRequest,
        ENV['AZURE_APP_INSIGHTS_INSTRUMENTATION_KEY']
      )
    end
    config.exceptions_app = routes

    config.maintenance_enabled = ENV.fetch('MAINTENANCE_ENABLED', 'false').casecmp('true').zero?
    config.maintenance_allowed_ips = ENV.fetch('MAINTENANCE_ALLOWED_IPS', '').split(',').map(&:strip)
    config.maintenance_end = ENV.fetch('MAINTENANCE_END', nil)

    config.active_support.remove_deprecated_time_with_zone_name = true
    config.active_record.yaml_column_permitted_classes = [Symbol, Date, Time, ActiveSupport::HashWithIndifferentAccess]

    # Interim solution for datashare enabled offices
    config.datashare_office_ids = [
      138, 83, 64, 166, 142, 184, 51, 84, 20, 52, 100012, 185, 186, 92,
      143, 144, 96, 139, 121, 122, 171, 100001, 140, 192, 53, 137, 123,
      93, 200048, 188, 120, 5, 100014, 198, 54, 49, 200015, 155, 38,
      200022, 168, 26, 47, 37, 97, 125, 154, 1, 165, 25, 98, 36, 65,
      145, 33, 3, 19, 164, 197, 163, 128, 133, 56, 129, 100, 57, 162,
      67, 200027, 194, 189, 117, 101, 200004, 174, 152, 151, 200030,
      200001, 175, 176, 136, 193, 73, 105, 200008, 150, 199, 135, 94,
      201, 31, 195, 200033, 42, 200043, 7, 178, 86, 95, 200010, 29,
      200016, 202, 149, 58, 77, 22, 106, 41, 179, 60, 146, 46, 13,
      87, 200040, 119, 187, 190, 200012, 200045, 112, 116, 115, 114,
      113, 40, 2, 35, 88, 160, 200003, 159, 196, 158, 8, 204, 28,
      203, 200, 4, 89, 61, 50, 78, 127, 107, 79, 39, 27, 118, 90,
      85, 200009, 18, 81, 147, 148, 141, 69, 102, 24, 70, 23, 63,
      71, 80, 17, 200011, 110, 72, 91, 200038, 200002, 21, 82, 200023,
      191, 132, 12, 16, 157
    ]
  end
  WillPaginate.per_page = 20
end
