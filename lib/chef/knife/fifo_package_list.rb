require 'chef/knife/fifo_base'

class Chef
  class Knife
    class FifoPackageList < Knife

      include Knife::FifoBase

      banner "knife fifo package list (options)"

      def run
        
        package_list = [
                        ui.color('ID', :bold),
                        ui.color('Name', :bold),
                        ui.color('RAM', :bold),
                        ui.color('Quota', :bold),
                        ui.color('CPU CAP', :bold)
                       ]
        
        connection.packages.list.each do |name|
          package = connection.packages[name]
          package_list << package['uuid']
          package_list << package['name']
          package_list << package['ram'].to_s
          package_list << package['quota'].to_s
          package_list << package['cpu_cap'].to_s
        end        
        puts ui.list(package_list, :uneven_columns_across, 5)
        
      end
    end
  end
end
