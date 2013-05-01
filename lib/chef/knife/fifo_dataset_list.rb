require 'chef/knife/fifo_base'

class Chef
  class Knife
    class FifoDatasetList < Knife

      include Knife::FifoBase

      banner "knife fifo dataset list (options)"

      def run
        
        dataset_list = [
                        ui.color('ID', :bold),
                        ui.color('Name', :bold),
                        ui.color('OS', :bold),
                        ui.color('Type', :bold),
                        ui.color('Version', :bold)
                       ]
        
        connection.datasets.list.each do |name|
          dataset = connection.datasets[name]
          dataset_list << dataset['dataset']
          dataset_list << dataset['name']
          dataset_list << dataset['os']
          dataset_list << dataset['type']
          dataset_list << dataset['version']
        end        
        puts ui.list(dataset_list, :uneven_columns_across, 5)
        
      end
    end
  end
end
