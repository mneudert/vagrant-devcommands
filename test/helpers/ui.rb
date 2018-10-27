module Helpers
  module UI
    # Stores all messages for later retrieval
    class Tangible < Vagrant::UI::Interface
      attr_accessor :messages

      def initialize
        super

        @messages = []
      end

      %i[detail warn error info output success].each do |method|
        define_method(method) do |message, *opts|
          @messages << {
            method: method,
            message: message,
            opts: opts
          }
        end
      end
    end
  end
end
