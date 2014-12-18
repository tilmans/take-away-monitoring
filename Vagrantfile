# -*- mode: ruby -*-
# # vi: set ft=ruby :
#
Vagrant.configure('2') do |config|
  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"

  config.vm.network "forwarded_port", guest: 80, host: 8080
  config.vm.network "forwarded_port", guest: 2003, host: 2003
  config.vm.network "forwarded_port", guest: 2003, host: 2003, protocol: 'udp'
  config.vm.network "forwarded_port", guest: 2004, host: 2004
  config.vm.network "forwarded_port", guest: 8125, host: 8125, protocol: 'udp'

  config.vm.provider 'virtualbox' do |v|
    v.customize ["modifyvm", :id, "--memory", 512]
    v.customize ["modifyvm", :id, "--cpus", 2]
  end

  config.vm.provision :puppet do |puppet|
    puppet.manifests_path = "puppet/manifests"
    puppet.module_path    = "puppet/modules"
    puppet.manifest_file  = "base.pp"
    puppet.options = "--verbose --debug --trace"
  end
end
