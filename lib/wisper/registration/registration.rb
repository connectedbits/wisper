# @api private

module Wisper
  class Registration
    attr_reader :on, :listener

    ALL = Object.new.freeze

    def initialize(listener, options)
      @listener = listener
      @on       = stringify(options.fetch(:on, ALL))
    end

    # Global listeners + rails in dev mode causes exception
    # Thanks to gersmann for the workaround
    def listener
      @listener.new if @listener.class == Class
      case @listener
        when Class
          clazz = Kernel.const_get(@listener.to_s)
          clazz.new
        when String
          clazz = Kernel.const_get(@listener)
          clazz.new
        else
          @listener
        end
      end
    end

    private

    def should_broadcast?(event)
      return true if on == ALL

      case on.class.name
      when 'String'
        event == on
      when 'Array'
        on.include?(event)
      when 'Regexp'
        !!on.match(event)
      else
        raise ArgumentError, "#{on.class} not supported for `on` argument"
      end
    end

    def stringify(on)
      case on.class.name
      when 'Symbol'
        on.to_s
      when 'Array'
        on.map(&:to_s)
      else
        on
      end
    end
  end
end
