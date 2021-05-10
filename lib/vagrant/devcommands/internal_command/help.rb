# frozen_string_literal: true

module VagrantPlugins
  module DevCommands
    module InternalCommand
      # Internal "help" command
      class Help
        I18N_KEY = 'vagrant_devcommands.internal.help'
        UTIL     = VagrantPlugins::DevCommands::Util
        MESSAGES = VagrantPlugins::DevCommands::Messages
        PRINTER  = VagrantPlugins::DevCommands::HelpPrinter

        def initialize(env, registry)
          @env      = env
          @registry = registry
        end

        def execute(argv)
          return message(:no_commands) if @registry.commands.empty?

          command = argv[0]

          return plugin_help(command) unless @registry.available?(command)
          return internal_help(command) if @registry.reserved_command?(command)

          help(command)
        end

        private

        def help(command)
          if @registry.valid_chain?(command)
            PRINTER::Chain.new(@env).output(@registry.chains[command])
          elsif @registry.valid_command_alias?(command)
            PRINTER::CommandAlias.new(@env).output(
              @registry.command_aliases[command]
            )
          else
            PRINTER::Command.new(@env).output(@registry.commands[command])
          end
        end

        def info(msg, pre_ln: false)
          @env.ui.info '' if pre_ln
          @env.ui.info msg
        end

        def internal_commands
          VagrantPlugins::DevCommands::Runner::InternalCommand::COMMANDS
        end

        def internal_help(command)
          internal_help_header(command)
          info(internal_commands[command].help.strip, pre_ln: true)

          message(:plugin_readme, pre_ln: true) if command == 'help'
        end

        def internal_help_header(command)
          spec  = internal_commands[command]
          usage = format(spec.usage, command: command)

          info(I18n.t("#{I18N_KEY}.usage", what: usage))
        end

        def list_pad_to
          UTIL.max_pad([internal_commands,
                        @registry.chains,
                        @registry.command_aliases,
                        @registry.commands])
        end

        def message(msg, pre_ln: false)
          if pre_ln
            MESSAGES.pre_ln(msg, &@env.ui.method(:info))
          else
            MESSAGES.public_send(msg, &@env.ui.method(:info))
          end
        end

        def plugin_help(command)
          plugin_help_header(command) unless command == '--commands'

          pad_to = list_pad_to

          plugin_help_commands('available', @registry.commands, pad_to)
          plugin_help_chains(@registry.chains, pad_to)
          plugin_help_command_aliases(@registry.command_aliases, pad_to)
          plugin_help_commands('internal', internal_commands, pad_to)
        end

        def plugin_help_chains(chains, pad_to)
          return if chains.empty?

          info(I18n.t("#{I18N_KEY}.list.chains"), pre_ln: true)

          chains.sort.each do |name, chain|
            info(UTIL.padded_columns(pad_to, name, chain.desc))
          end
        end

        def plugin_help_commands(type, commands, pad_to)
          return if commands.empty?

          info(I18n.t("#{I18N_KEY}.list.commands_#{type}"), pre_ln: true)

          commands.sort.each do |name, command|
            info(UTIL.padded_columns(pad_to, name, command.desc))
          end
        end

        def plugin_help_command_aliases(command_aliases, pad_to)
          return if command_aliases.empty?

          info(I18n.t("#{I18N_KEY}.list.command_aliases"), pre_ln: true)

          command_aliases.sort.each do |name, command_alias|
            info(UTIL.padded_columns(pad_to, name, command_alias.desc))
          end
        end

        def plugin_help_header(command)
          if command.nil?
            message(:plugin_usage)
          else
            @env.ui.error I18n.t("#{I18N_KEY}.invalid_command", what: command)
          end
        end
      end
    end
  end
end
