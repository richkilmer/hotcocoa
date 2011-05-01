module HotCocoa

  ##
  # The set of methods that are available when creating a mapping.
  module MappingMethods

    ##
    # You can provide a hash of default options in the definition of
    # your mapping. This is very useful for many Cocoa classes, because
    # there are so many options to set at initialization.
    #
    # The defaults that are set with this method are used in the
    # constructor to set a value for any keys that are not passed to the
    # constructor when it is called.
    #
    # @overload defaults
    #   Get the hash of defaults
    #   @return [Hash,nil]
    # @overload defaults key1: value1, key2: value2, ...
    #   Set the hash of defaults
    #   @param [Hash]
    #   @return [Hash]
    def defaults defaults = nil
      if defaults
        @defaults = defaults
      else
        @defaults
      end
    end

    ##
    # Create a mapping of a constant type to an enumeration of constants.
    #
    # A constant mapping allows the use of short symbol names to be used
    # in place of long constant names in the scope of the wrapped class.
    #
    # You can create as many different constant mappings as you want, or
    # you can create no mappings; you can still use the original constants.
    #
    # Constant mappings are inherited.
    #
    # @example Normal usage
    #   constant :state, {
    #     on:    NSOnState,
    #     off:   NSOffState,
    #     mixed: NSMixedState
    #   }
    #   # then you can initalize an object with the following
    #   button :state => :on
    #   # instead of
    #   button :state => NSOnState
    #
    # @param [Symbol] name
    # @param [Hash{Symbol=>Constant}] constants
    def constant name, constants
      constants_map[name] = constants
    end

    ##
    # @todo Can we use attr_accessor :constants_map instead?
    #
    # A mapping of constant mappings that were created with calls to
    # {#constant}.
    #
    # @return [Hash{ Symbol => Hash{ Symbol => Constant } }]
    def constants_map
      @constants_map ||= {}
    end

    def custom_methods(&block)
      if block
        @custom_methods = Module.new
        @custom_methods.module_eval(&block)
      else
        @custom_methods
      end
    end

    def delegating(name, options)
      delegate_map[name] = options
    end

    def delegate_map
      @delegate_map ||= {}
    end
  end
end