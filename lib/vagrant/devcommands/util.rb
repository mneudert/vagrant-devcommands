module VagrantPlugins
  module DevCommands
    # Utility module
    class Util
      def self.argv_command(argv, env)
        return nil if argv.empty?

        command = argv[0].to_s
        command = argv[1].to_s if env.machine_index.include?(command)

        command
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
