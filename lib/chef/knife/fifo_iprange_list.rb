require 'chef/knife/fifo_base'

class Chef
  class Knife
    class FifoIprangeList < Knife

      include Knife::FifoBase

      banner "knife fifo iprange list (options)"

      def run
        
        iprange_list = [
                        ui.color('ID', :bold),
                        ui.color('Tag', :bold),
                        ui.color('Vlan', :bold),
                        ui.color('Network', :bold),
                        ui.color('Netmask', :bold)
                       ]
        
        connection.ipranges.list.each do |name|
          iprange = connection.ipranges[name]
          iprange_list << iprange['uuid']
          iprange_list << iprange['tag']
          iprange_list << iprange['vlan'].to_s
          iprange_list << iprange['network']
          iprange_list << iprange['netmask']
        end        
        puts ui.list(iprange_list, :uneven_columns_across, 5)
        
      end
    end
  end
end
