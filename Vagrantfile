# -*- mode: ruby -*-
# # vi: set ft=ruby :
#
$script = <<SCRIPT
# Install wget
sudo apt-get install -qy wget;

# Update puppet installation
wget https://raw.githubusercontent.com/hashicorp/puppet-bootstrap/master/ubuntu.sh
sh ubuntu.sh
SCRIPT

Vagrant.configure('2') do |config|
  # set to false, if you do NOT want to check the correct VirtualBox Guest Additions version when booting this box
  if defined?(VagrantVbguest::Middleware)
    config.vbguest.auto_update = true
  end

  config.vm.box = "hashicorp/precise64"
  config.vm.box_url = "http://mirror.hdcore.eu/vagrant/boxes/precise64.box"

  config.vm.network "forwarded_port", guest: 80, host: 8080
  config.vm.network "forwarded_port", guest: 8081, host: 8081
  config.vm.network "forwarded_port", guest: 2003, host: 2003
  config.vm.network "forwarded_port", guest: 2003, host: 2003, protocol: 'udp'
  config.vm.network "forwarded_port", guest: 2004, host: 2004
  config.vm.network "forwarded_port", guest: 8125, host: 8125, protocol: 'udp'
  config.vm.network "forwarded_port", guest: 9200, host: 9200

  config.vm.provider 'virtualbox' do |v|
    v.name = "Take Away Monitoring"
    v.customize ["modifyvm", :id, "--memory", 512]
    v.customize ["modifyvm", :id, "--cpus", 2]
  end

  config.vm.provision "shell", inline: $script
  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = "puppet/manifests"
    puppet.module_path    = "puppet/modules"
    puppet.manifest_file  = "base.pp"
    puppet.options = "--verbose --debug --trace"
  end
end
