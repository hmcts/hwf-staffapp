# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"
Rails.application.config.assets.paths << Rails.root.join('node_modules')

Rails.application.config.assets.precompile += ['income_calculator.js']
Rails.application.config.assets.precompile += ['*.png', '*.ico']
Rails.application.config.assets.precompile += ['.svg', '.eot', '.woff', '.ttf']
Rails.application.config.assets.precompile += ['ckeditor/*']
Rails.application.config.assets.precompile += ['chartkick.js']
Rails.application.config.assets.precompile += ['govuk-frontend/dist/govuk/all.css']
Rails.application.config.assets.precompile += ['govuk-frontend/dist/govuk/govuk-frontend.min.js']
Rails.application.config.assets.precompile += ['govuk-fonts/dist/*']
Rails.application.config.assets.precompile += ['images/dist/*']
Rails.application.config.assets.precompile += ['accessible-autocomplete/dist/accessible-autocomplete.min.js']
Rails.application.config.assets.precompile += ['accessible-autocomplete/dist/accessible-autocomplete.min.css']
