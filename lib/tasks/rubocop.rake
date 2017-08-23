if ['development', 'test'].include? Rails.env
  unless ENV['DOCKER_STATE'] == 'vagrant'
    require 'rubocop/rake_task'
    RuboCop::RakeTask.new

    task(:default).prerequisites << task(:rubocop)
  end
end
