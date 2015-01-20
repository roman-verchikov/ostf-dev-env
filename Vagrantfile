# vi: ft=ruby:sw=2:ts=2:et

VAGRANTFILE_API_VERSION = "2"

#--------------------------------------------------
# User to modify this value according to needs.
# This one is relative to user's home.
OSTF_DIR="~/Documents/ostf-fuel"
#--------------------------------------------------

vagrant_user = %x(id -un).strip
vagrant_uid = %x(id -u #{vagrant_user}).strip

nodes = {
  "ostf-dev" => {
    "ip" => "192.168.1.100",
    "vm" => {
      "memory" => 4096,
      "cpus" => 2
    }
  }
}

vbox_optimization_opts = ["ioapic", "hwvirtex", "vtxvpid", "vtxux"]


Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/precise64"
  config.vm.synced_folder ENV["HOME"], "/home/#{vagrant_user}", :type => "nfs"
  config.vm.provision "shell",
                      :path => "provisioning/provision-user.sh",
                      :args => ["--user", vagrant_user, "--uid", vagrant_uid]
  config.vm.provision "shell",
                      :path => "provisioning/setup-env.sh",
                      :args => ["--user", vagrant_user,
                                "--ostf-dir", OSTF_DIR.sub('~/', "/home/#{vagrant_user}/")]

  nodes.each_key do |nodename|
    node_data = nodes[nodename]
    config.vm.define nodename do |thisnode|
      thisnode.vm.hostname = nodename

      if node_data.has_key?("ip")
        config.vm.network "private_network", :ip => node_data["ip"]
      end

      config.vm.provider "virtualbox" do |v|
        vbox_optimization_opts.each do |opt|
          v.customize ["modifyvm", :id, "--#{opt}", "on"]
        end

        if node_data.has_key?("vm")
          node_data["vm"].each_key do |opt|
            v.customize ["modifyvm", :id, "--#{opt}", node_data["vm"][opt]]
          end
        end
      end
    end
  end
end
