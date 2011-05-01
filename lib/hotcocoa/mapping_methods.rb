module HotCocoa
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
    #   @return [Hash,nil] The hash of
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

    def constant(name, constants)
      constants_map[name] = constants
    end

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