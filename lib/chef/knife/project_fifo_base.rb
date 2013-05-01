require 'chef/knife'

class Chef
  class Knife
    module ProjectFifoBase
      def self.included(includer)
        includer.class_eval do

          deps do
            require 'project-fifo-ruby'
          end

          option :project_fifo_username,
          :long => "--project-fifo-username KEY",
          :description => "Your Project Fifo username",
          :proc => Proc.new { |key| Chef::Config[:knife][:project_fifo_username] = key }
          
          option :project_fifo_password,
          :long => "--project-fifo-password SECRET",
          :description => "Your Project Fifo Password",
          :proc => Proc.new { |key| Chef::Config[:knife][:project_fifo_password] = key }
          
          option :project_fifo_endpoint,
          :long => "--project-fifo-endpoint REGION",
          :description => "Your Project Fifo endpoint",
          :proc => Proc.new { |key| Chef::Config[:knife][:project_fifo_endpoint] = key }
        end
      end
      
      def connection
        @connection ||= begin
                          ProjectFifo.new(
                                          Chef::Config[:knife][:project_fifo_endpoint], 
                                          Chef::Config[:knife][:project_fifo_username],
                                          Chef::Config[:knife][:project_fifo_password]
                                          )
                        end
      end

      def locate_config_value(key)
        key = key.to_sym
        config[key] || Chef::Config[:knife][key]
      end

      def msg_pair(label, value, color=:cyan)
        if value && !value.to_s.empty?
          puts "#{ui.color(label, color)}: #{value}"
        end
      end
    end
  end
end

