IMAGE_NAME = "generic/ubuntu2004"
M = 3
N = 3
UPDATE_OS_TO_LATEST_PKG = false

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
                    { name: "master-0", ip: "192.168.100.50" },
                    { name: "master-1", ip: "192.168.100.51" },
                    { name: "master-2", ip: "192.168.100.52" },
                    { name: "master-3", ip: "192.168.100.53" }
                ],
                listen_port: "6443",
                do_update: UPDATE_OS_TO_LATEST_PKG,
            }
        end
    end

    #provision first master node
    config.vm.define "master-1", primary: true  do |master|
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
                cplane_endpoint_ip: "192.168.100.100",
                do_update: UPDATE_OS_TO_LATEST_PKG,
            }
        end
    end

    #provision rest of control plane
    (2..N).each do |i|
        config.vm.define "master-#{i}" do |node|
            node.vm.box = IMAGE_NAME
            #node.vm.network :public_network, ip: "192.168.69.#{i + 50}", :dev => "br0", :mode => "bridge", :type => "bridge"
            node.vm.network :private_network, ip: "192.168.100.#{i + 60}"
            node.vm.hostname = "node-#{i}"
            node.vm.provision "ansible" do |ansible|
                ansible.playbook = "kubernetes-setup/node-playbook.yml"
                ansible.extra_vars = {
                    node_ip: "192.168.100.#{i + 50}",
                    is_controlplane: true,
                    do_update: UPDATE_OS_TO_LATEST_PKG,
                }
            end
        end
    end

    #provision worker nodes
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
                    is_controlplane: false,
                    do_update: UPDATE_OS_TO_LATEST_PKG,
                }
            end
        end
    end
end
