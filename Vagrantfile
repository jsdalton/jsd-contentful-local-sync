# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.require_version '>= 1.8.1'

VAGRANTFILE_API_VERSION = '2'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = 'ubuntu/trusty64'
  config.vm.host_name = 'moneypenny-backend'

  # Forwarded ports
  config.vm.network :forwarded_port, guest: 4567, host: 14567

  # Synced folders
  # The mount options here optimize the speed of the NFS mount to better support
  # features like file watchers etc.
  # See https://www.jverdeyen.be/vagrant/speedup-vagrant-nfs/
  config.vm.synced_folder('.',
                          '/vagrant',
                          type: 'nfs',
                          mount_options: ['rw', 'vers=3', 'tcp', 'fsc',
                                          'actimeo=2'])

  # Host only network required for NFS
  config.vm.network :private_network, ip: '10.0.0.75'

  # Requires Ansible 2.0+ to be installed on host machine
  config.vm.provision 'ansible' do |ansible|
    ansible.playbook = './vagrant_provisioning.yml'
  end

  # Make sure bundle install doesn't run out of memory
  config.vm.provider 'virtualbox' do |v|
    v.memory = 1024
  end
end
