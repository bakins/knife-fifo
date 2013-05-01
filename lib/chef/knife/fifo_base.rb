require 'chef/knife'

class Chef
  class Knife
    module FifoBase
      def self.included(includer)
        includer.class_eval do

          deps do
            require 'project-fifo'
          end

          option :fifo_username,
          :long => "--fifo-username KEY",
          :description => "Your Project Fifo username",
          :proc => Proc.new { |key| Chef::Config[:knife][:fifo_username] = key }
          
          option :fifo_password,
          :long => "--fifo-password SECRET",
          :description => "Your Project Fifo Password",
          :proc => Proc.new { |key| Chef::Config[:knife][:fifo_password] = key }
          
          option :fifo_endpoint,
          :long => "--fifo-endpoint REGION",
          :description => "Your Project Fifo endpoint",
          :proc => Proc.new { |key| Chef::Config[:knife][:fifo_endpoint] = key }
        end
      end
      
      def connection
        @connection ||= begin
                          c = ProjectFifo.new(
                                              Chef::Config[:knife][:fifo_endpoint], 
                                              Chef::Config[:knife][:fifo_username],
                                              Chef::Config[:knife][:fifo_password]
                                              )
                          c.connect
                          c
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

