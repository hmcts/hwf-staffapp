worker_processes Integer(ENV["WEB_CONCURRENCY"] || 3)

preload_app true

# rubocop:disable UnusedBlockArgument
before_fork do |server, worker|
  Signal.trap 'TERM' do
    Process.kill 'QUIT', Process.pid
  end

  defined?(ActiveRecord::Base) &&
    ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  Signal.trap 'TERM' do
  end

  defined?(ActiveRecord::Base) &&
    ActiveRecord::Base.establish_connection
end
