# Proxy class to make Commandfile definitions more readable.
class VagrantDevCommands
  def self.define(name, options)
    VagrantPlugins::DevCommands::Definer.define(name, options)
  end
end
