module VagrantPlugins
  module DevCommands
    # Utility module
    class Util
      JARO_WINKLER = VagrantPlugins::DevCommands::Util::JaroWinkler

      def self.argv_command(argv, env)
        return nil if argv.empty?

        command = argv[0].to_s
        command = argv[1].to_s if machine_name?(command, env.machine_index)

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

      def self.did_you_mean(command, registry)
        alternatives = registry.commands.keys + registry.chains.keys
        distances    = {}

        alternatives.each do |alternative|
          calculator             = JARO_WINKLER.new(command, alternative)
          distances[alternative] = calculator.distance
        end

        distances.max_by { |_k, v| v }
      end

      def self.machine_name?(name, machine_index)
        machine_index.any? { |machine| name == machine.name }
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
