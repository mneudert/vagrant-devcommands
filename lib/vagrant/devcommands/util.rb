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

      def self.collect_flags(flags)
        flags.collect do |key, _opts|
          "[--#{key}]"
        end
      end

      def self.collect_mandatory_params(params)
        params.collect do |key, opts|
          "--#{key}=<#{key}>" unless opts[:optional]
        end
      end

      def self.collect_optional_params(params)
        params.collect do |key, opts|
          "[--#{key}=<#{key}>]" if opts[:optional]
        end
      end

      def self.max_pad(items_list)
        paddings = items_list.map do |items|
          if items.nil? || items.empty?
            0
          else
            pad_to(items)
          end
        end

        paddings.max
      end

      def self.pad_to(items)
        items = items.keys unless items.is_a?(Array)

        items.map(&:length).max
      end

      def self.padded_columns(pad_to, left, right = nil)
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
