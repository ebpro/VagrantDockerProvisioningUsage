# -*- mode: ruby -*-
# vi: set ft=ruby :

nodes = [
  { :hostname => 'docker-node-'+ENV['HOSTNAME'], :ram => ENV['DOCKER_RAM']||1024, :cpus => ENV['DOCKER_CPUS']||2  }
]
Vagrant.configure("2") do |config|
  ## Provision nodes
  nodes.each do |node|
    config.vm.define node[:hostname] do |nodeconfig|
      nodeconfig.vm.box ="ebruno/ansible-docker"
      nodeconfig.vm.hostname = node[:hostname] + ".box"
      # nodeconfig.vm.network :private_network, ip: node[:ip]
      memory = node[:ram] ? node[:ram] : 512;
      cpus = node[:cpus] ? node[:cpus] : 1;
      nodeconfig.vm.provider :virtualbox do |vb|
        vb.customize [
          "modifyvm", :id,
          "--memory", memory.to_s,
          "--cpus", cpus.to_s
        ]
    end
  end

  ## Create a forwarded port mapping which allows access to a specific port
  ## within the machine from a port on the host machine and only allow access
  ## via 127.0.0.1 to disable public access
  config.vm.define "docker-node-1" do |masterconfig|
#    masterconfig.vm.network "forwarded_port", guest: 80,    host: 80,
#    		auto_correct: true #, host_ip: "127.0.0.1"
#    masterconfig.vm.network "forwarded_port", guest: 443,   host: 443,
#    		auto_correct: true  #, host_ip: "127.0.0.1"

    masterconfig.vm.network "forwarded_port", guest: 8080,  host: 8080,
    		auto_correct: true , host_ip: "127.0.0.1"
    masterconfig.vm.network "forwarded_port", guest: 4443,  host: 4443,
    		auto_correct: true , host_ip: "127.0.0.1"
    # H2 Database
    masterconfig.vm.network "forwarded_port", guest: 1521,  host: 1521,
    		auto_correct: true , host_ip: "127.0.0.1"
   #Postgres Database
    masterconfig.vm.network "forwarded_port", guest: 5432,  host: 5432,
    		auto_correct: true , host_ip: "127.0.0.1"
   #MySQL Database
   masterconfig.vm.network "forwarded_port", guest: 3306,  host: 3306,
   auto_correct: true #, host_ip: "127.0.0.1"

# Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
masterconfig.vm.synced_folder "~/", "/vagrant_data"

end
#    nodeconfig.vm.provision :shell, path: "cleanup.sh"
  end
end
