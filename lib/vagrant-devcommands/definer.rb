module Vagrant
  class DevCommand

    @@commands = {}


    def self.commands
      @@commands
    end

    def self.define(name, *args)
      command = args.last
      options = {}

      if 2 == args.size
        options = args.first
      end

      @@commands[name] = { options: options, command: command }
    end

  end
end
