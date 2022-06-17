namespace :static_pages do
  desc "Generates static pages"
  Rails.application.middleware.tap do |middleware|
    middleware.delete ActiveRecord::Migration::CheckPending
    middleware.delete ActiveRecord::QueryCache
  end
  task generate: 'assets:precompile' do
    pages = {
      '/static/404' => '404.html',
      '/static/400' => '400.html',
      '/static/500' => '500.html',
      '/static/503' => '503.html'
    }

    # Silence a warning for the session key not being set.
    Rails.application.config.secret_key_base = SecureRandom.hex
    app = ActionDispatch::Integration::Session.new(Rails.application)

    pages.each do |route, output|
      puts "Generating #{output}..."
      outpath = Rails.public_path.join(output)
      resp = app.get(route)
      if resp == 200
        File.delete(outpath) if File.exist?(outpath)
        File.write(outpath, app.response.body.sub!('http://www.example.com', ''))
      else
        puts "Error generating #{output}!"
      end
    end
  end
end
