# -*- mode: ruby -*-
# vi: set ft=ruby :

DOCKER_IMAGE_TAG='fr-staffapp'
DOCKER_PORT=2380
UNICORN_PORT=3002
VAGRANTFILE_API_VERSION = "2"

DOCKER_ENABLED_BOX="puppetlabs/ubuntu-14.04-64-nocm"

$docker_setup=<<CONF
cat > /etc/default/docker << 'EOF'
DOCKER_OPTS="-H 0.0.0.0:#{DOCKER_PORT} -H unix:///var/run/docker.sock"
EOF
service docker restart
sleep 5
docker stop fr-staffapp >/dev/null 2>&1 || true
docker rm fr-staffapp >/dev/null 2>&1 || true
docker rmi -f fr-staffapp >/dev/null 2>&1 || true
CONF

unless Vagrant.has_plugin?("vagrant-cachier")
  puts "WARNING: vagrant-cachier plugin is not installed! It really speeds this up..."
  puts "         Install using 'vagrant plugin install vagrant-cachier'"
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = DOCKER_ENABLED_BOX
  config.vm.hostname = "#{DOCKER_IMAGE_TAG}-dockerhost"
  config.vm.network "forwarded_port", guest: DOCKER_PORT, host: DOCKER_PORT
  config.vm.network "forwarded_port", guest: UNICORN_PORT, host: UNICORN_PORT

  # Set up SSH agent forwarding.
  config.ssh.forward_agent = true

  config.vm.provision "docker"
  config.vm.provision "shell", inline: $docker_setup

  # build image and start the application
  #  rails 4.2.0 need explicit binding to 0.0.0.0 now
  #  use /tmp/server.pid so that we don't prevent future runs from firing up.
  config.vm.provision "docker" do |d|
      d.build_image "/vagrant", args: "-t #{DOCKER_IMAGE_TAG}"
      d.run "#{DOCKER_IMAGE_TAG}",
      image: "#{DOCKER_IMAGE_TAG}",
      args: "-v /vagrant:/usr/src/app -p #{UNICORN_PORT}:3000"
      # cmd: "bundle exec rails server -P /tmp/server.pid --binding=0.0.0.0"
  end
  # print out help
  config.vm.provision "shell", inline: <<-EOF
    echo "#---------------------------------------"
    echo "# Application should be available at:"
    echo "#  http://localhost:#{UNICORN_PORT}"
    echo "#---------------------------------------"
    echo "# To use docker locally, set:"
    echo "export DOCKER_HOST=tcp://localhost:#{DOCKER_PORT}"
  EOF

end
