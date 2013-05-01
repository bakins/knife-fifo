require 'chef/knife/fifo_base'

class Chef
  class Knife
    class FifoServerCreate < Knife

      include Knife::FifoBase

       deps do
        require 'project-fifo'
        require 'chef/knife/bootstrap'
        Chef::Knife::Bootstrap.load_deps
      end
      
      banner "knife fifo server create (options)"
      
      option :alias,
      :long => "--alias ALIAS",
      :description => "The alias of server"
      
      option :dataset,
      :long => "--dataset DATASET",
      :description => "The dataset of server",
      :proc => Proc.new { |f| Chef::Config[:knife][:fifo_dataset] = f }
      
      option :package,
      :long => "--package PACKAGE",
      :description => "The package of server",
      :proc => Proc.new { |f| Chef::Config[:knife][:fifo_package] = f }
     
      option :iprange,
      :long => "--iprange PACKAGE",
      :description => "The iprange of server",
      :proc => Proc.new { |f| Chef::Config[:knife][:fifo_iprange] = f }
      
      option :chef_node_name,
      :short => "-N NAME",
      :long => "--node-name NAME",
      :description => "The Chef node name for your new node",
      :proc => Proc.new { |key| Chef::Config[:knife][:chef_node_name] = key }
      
      option :bootstrap_version,
      :long => "--bootstrap-version VERSION",
      :description => "The version of Chef to install",
      :proc => Proc.new { |v| Chef::Config[:knife][:bootstrap_version] = v }
      
      option :run_list,
      :short => "-r RUN_LIST",
      :long => "--run-list RUN_LIST",
      :description => "Comma separated list of roles/recipes to apply",
      :proc => lambda { |o| o.split(/[\s,]+/) }
      
      option :distro,
      :short => "-d DISTRO",
      :long => "--distro DISTRO",
      :description => "Bootstrap a distro using a template; default is 'chef-full'",
      :proc => Proc.new { |d| Chef::Config[:knife][:distro] = d },
      :default => 'chef-full'
      
      option :template_file,
      :long => "--template-file TEMPLATE",
      :description => "Full path to location of template to use",
      :proc => Proc.new { |t| Chef::Config[:knife][:template_file] = t },
      :default => false
      
      def build_bootstrap()
        bootstrap = Chef::Knife::Bootstrap.new
        bootstrap.config[:run_list] = config[:run_list]
        bootstrap.config[:bootstrap_version] = locate_config_value(:bootstrap_version)
        bootstrap.config[:distro] = locate_config_value(:distro) || "chef-full"
        bootstrap.config[:template_file] = locate_config_value(:template_file)
        bootstrap.config[:environment] = locate_config_value(:environment)
        bootstrap.config[:chef_node_name] = locate_config_value(:chef_node_name)
        template = bootstrap.find_template
        bootstrap.render_template(IO.read(template))
      end

      def bootstrap_for_node(server, ssh_host)
        bootstrap = Chef::Knife::Bootstrap.new
        bootstrap.name_args = [ssh_host]
        bootstrap.config[:ssh_user] = config[:ssh_user] || "root"
        bootstrap.config[:ssh_port] = config[:ssh_port] || 22
        bootstrap.config[:ssh_gateway] = config[:ssh_gateway]
        bootstrap.config[:identity_file] = config[:identity_file]
        bootstrap.config[:chef_node_name] = locate_config_value(:chef_node_name) || server
        bootstrap.config[:distro] = locate_config_value(:distro) || "chef-full"
        bootstrap.config[:use_sudo] = true unless config[:ssh_user] == 'root'
        # may be needed for vpc_mode
        bootstrap.config[:host_key_verify] = config[:host_key_verify]
        bootstrap_common_params(bootstrap)
      end
      
      def tcp_test_ssh(hostname, ssh_port=22)
        tcp_socket = TCPSocket.new(hostname, ssh_port)
        readable = IO.select([tcp_socket], nil, nil, 5)
        if readable
          Chef::Log.debug("sshd accepting connections on #{hostname}, banner is #{tcp_socket.gets}")
          yield
          true
        else
          false
        end
      rescue SocketError, Errno::ECONNREFUSED, Errno::EHOSTUNREACH, Errno::ENETUNREACH, IOError
        sleep 2
        false
      rescue Errno::EPERM, Errno::ETIMEDOUT
        false
      ensure
        tcp_socket && tcp_socket.close
      end
       
      def run
        node_alias = locate_config_value(:alias) || locate_config_value(:chef_node_name)
        
        raise "must either provide alias or chef_node_name" unless node_alias
        
        #should we validate the package, dataset, and network before hand?
        data = {
          dataset: locate_config_value(:fifo_dataset), 
          package: locate_config_value(:fifo_package), 
          config: { 
            alias: node_alias,
            ssh_keys: connection.ssh_keys,
            networks: { 
              net0: locate_config_value(:fifo_iprange)
            },
            metadata: {
              hostname: node_alias
            }
          }
        }
        
        server = connection.vms.create(data)

        id = server['uuid']
        msg_pair("ID", id)
        msg_pair("State", server['state'])
        
        puts "waiting for vm to start"
        while true do
          server = connection.vms[id]
          break if server['state'] == "running"
          print('.')
          sleep 10
        end
        puts("done")
        
        ip = begin
               server['config']['networks'].first['ip']
             rescue
               nil
             end
        
        raise "no ipaddress??" unless ip
        
        print "\n#{ui.color("Waiting for sshd", :magenta)}"
        print(".") until tcp_test_ssh(ip) {
          sleep 10
          puts("done")
        }
        
        bootstrap_for_node(node_alias, ip)
      end
    end
  end
end
