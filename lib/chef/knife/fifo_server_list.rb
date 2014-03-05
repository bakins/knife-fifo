require 'chef/knife/fifo_base'
require 'pp'

class Chef
  class Knife
    class FifoServerList < Knife

      include Knife::FifoBase

      banner "knife fifo server list (options)"

      def run
        $stdout.sync = true
        
        server_list = [
                       ui.color('ID', :bold),
                       ui.color("Alias", :bold),
                       ui.color('First IP', :bold),
                       ui.color('Dataset', :bold),
                       ui.color('Package', :bold),
                       ui.color('State', :bold)
                      ].flatten.compact
        
        output_column_count = server_list.length
        
        connection.vms.list.each do |server|
          server = connection.vms[server]
          server_list << server['uuid']
          server_list << server['config']['alias'] or 'none'
          server_list << begin
                           server['config']['networks'].first['ip']
                         rescue
                           'none'
                         end
          server_list << begin
                           connection.datasets[server['dataset']]['name']
                         rescue
                           'unknown'
                         end
          server_list << begin
                           connection.packages[server['package']]['name']
                         rescue
                           'unknown'
                         end
          server_list << server['state'] || 'unknown'
        end
        
        puts ui.list(server_list, :uneven_columns_across, output_column_count)
      end
      
    end
  end
end
