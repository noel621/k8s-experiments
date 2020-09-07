IMAGE_NAME = "generic/ubuntu2004"
M = 3
N = 3

Vagrant.configure("2") do |config|
    config.ssh.insert_key = false

    config.vm.provider "virtualbox" do |v|
        v.memory = 2024
        v.cpus = 2
    end

    config.vm.provider "libvirt" do |v|
        v.memory = 2048
        v.cpus = 2
        v.disk_bus = 'sata'
    end

    config.vm.define "k8s-lb", primary: true  do |master|
        master.vm.box = IMAGE_NAME
        master.vm.network :private_network, ip: "192.168.100.100"
        master.vm.hostname = "k8s-lb"
        master.vm.provision "ansible" do |ansible|
            ansible.playbook = "kubernetes-setup/lb-playbook.yml"
            ansible.extra_vars = {
                node_ip: "192.168.100.100",
                backend_servers: [
                    { name: "k8s-master-0", ip: "192.168.100.50" },
                    { name: "k8s-master-1", ip: "192.168.100.51" },
                    { name: "k8s-master-2", ip: "192.168.100.52" },
                    { name: "k8s-master-3", ip: "192.168.100.53" }
                ],
                listen_port: "6443",
            }
        end
    end

    config.vm.define "k8s-master-1", primary: true  do |master|
        master.vm.box = IMAGE_NAME
#        master.vm.network :public_network, ip: "192.168.69.50", :dev => "br0", :mode => "bridge", :type => "bridge"
        master.vm.network :private_network, ip: "192.168.100.51"
        master.vm.hostname = "k8s-master-1"
        master.vm.provision "ansible" do |ansible|
            ansible.playbook = "kubernetes-setup/master-playbook.yml"
            ansible.extra_vars = {
                node_ip: "192.168.100.51",
                service_cidr: "10.254.254.0/24",
                pod_cidr: "172.31.0.0/16",
            }
        end
    end

    (1..N).each do |i|
        config.vm.define "node-#{i}" do |node|
            node.vm.box = IMAGE_NAME
            #node.vm.network :public_network, ip: "192.168.69.#{i + 50}", :dev => "br0", :mode => "bridge", :type => "bridge"
            node.vm.network :private_network, ip: "192.168.100.#{i + 60}"
            node.vm.hostname = "node-#{i}"
            node.vm.provision "ansible" do |ansible|
                ansible.playbook = "kubernetes-setup/node-playbook.yml"
                ansible.extra_vars = {
                    node_ip: "192.168.100.#{i + 60}",
                }
            end
        end
    end
end