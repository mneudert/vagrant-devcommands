module VagrantPlugins
  module DevCommands
    module Model
      # Definition of an executable command
      class Command
        PARAM_PARSER = VagrantPlugins::DevCommands::ParamParser

        attr_reader :name

        attr_reader :flags
        attr_reader :parameters
        attr_reader :script
        attr_reader :tty

        attr_reader :machine
        attr_reader :desc
        attr_reader :help
        attr_reader :usage

        def initialize(spec)
          @name = spec[:name]

          @flags      = spec[:flags] || {}
          @parameters = spec[:parameters] || {}
          @script     = spec[:script]
          @tty        = spec[:tty] == true

          @machine = spec[:machine]
          @desc    = spec[:desc]
          @help    = spec[:help]
          @usage   = spec[:usage]
        end

        def run_script(argv)
          param_parser = PARAM_PARSER.new
          params       = param_parser.parse!(self, argv)

          script = @script
          script = eval_script_proc(script, params) if script.is_a?(Proc)

          (script % params).strip
        end

        private

        def eval_script_proc(script, params)
          if script.arity == 1
            instance_exec(params, &script)
          else
            instance_exec(&script)
          end
        end
      end
    end
  end
end
