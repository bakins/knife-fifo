require 'chef/knife/project_fifo_base'
require 'pp'

class Chef
  class Knife
    class ProjectFifoServerList < Knife

      include Knife::ProjectFifoBase

      banner "knife project-fifo server list (options)"

      def run
        $stdout.sync = true
        
        server_list = [
          ui.color('Instance ID', :bold),
        
          if config[:name]
            ui.color("Name", :bold)
          end,

          ui.color('Public IP', :bold),
          ui.color('Private IP', :bold),
          ui.color('Flavor', :bold),
          ui.color('Image', :bold),
          ui.color('SSH Key', :bold),
          ui.color('Security Groups', :bold),
          
          if config[:tags]
            config[:tags].split(",").collect do |tag_name|
              ui.color("Tag:#{tag_name}", :bold)
            end
          end,
          
          ui.color('State', :bold)
        ].flatten.compact
        
        connection.vms.list.each do |server|
          pp server
        end
      end
      
    end
  end
end
