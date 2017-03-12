module VagrantPlugins
  module DevCommands
    # Utility module
    class Util
      def self.machine_name?(name, machine_index)
        machine_index.any? { |machine| name == machine.name }
      end

      def self.pad_to(items)
        items.keys.map(&:length).max
      end

      def self.padded_columns(pad_to, left, right)
        left  = left.to_s  unless left.is_a?(String)
        right = right.to_s unless right.is_a?(String)

        if right.nil?
          "     #{left}"
        else
          "     #{left.ljust(pad_to)}   #{right}"
        end
      end
    end
  end
end
