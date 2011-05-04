# -*- coding: utf-8 -*-
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
    # @return [Hash{Symbol=>Hash{Symbol=>Constant}}]
    def constants_map
      @constants_map ||= {}
    end

    ##
    # Custom methods are modules that are mixed into the class being
    # mapped; they provide idiomatic Ruby methods for the mapped
    # Objective-C class instances.
    #
    # @example
    #   custom_methods do
    #     def bezel= value
    #       setBezelStyle(value)
    #     end
    #     def on?
    #       state == NSOnState
    #     end
    #   end
    #
    # The first method in the example, #bezel=, provides a better method
    # name than #setBezelStyle. Although we could provide idiomatic Ruby
    # methods for every Objective-C method, the number of these methods
    # is huge. The general principle is to customize where the custom
    # method provides something better or new functionality, not just to
    # add snake\_cased versions of Objective-C methods.
    #
    # Custom methods, like constant mappings, are inherited by
    # subclasses and can be used as the keys for arguments to object
    # constructors.
    #
    # @yield A block that will be evaluated in the context of a new module
    #
    # @overload custom_methods do ... end
    #   Create and cache a new module to mix into the mapped class
    # @overload custom_methods
    #   @return [Module,nil] Return the Module if it exists, otherwise nil.
    def custom_methods &block
      if block
        @custom_methods = Module.new
        @custom_methods.module_eval(&block)
      else
        @custom_methods
      end
    end

    ##
    # Delegation is a pattern that is used pervasively in Cocoa to
    # facilitate customization of controls; it is a powerful tool, but
    # is a little more complex to setup than custom methods.
    #
    # Normally, you would implement the delegate methods in a class of
    # your own. You would then set an instance of that class as the
    # delegate of the control.
    #
    # In Hot Cocoa, delegate methods are replaced with Ruby blocks and
    # the need to set a delegate is completely removed, see the
    # "Comparison" example.
    #
    # @example Comparison
    #
    #   # the traditional way of delegation:
    #   class MyDelegate
    #     def windowWillClose(sender)
    #       # perform something
    #     end
    #   end
    #   window.setDelegate(MyDelegate.new)
    #
    #   # is simplified to the Ruby code:
    #   window.will_close { 'performed something' }
    #
    # Each method for a delegate has to be mapped with an individual
    # delegating call.
    #
    # To enable this, you map individual delegate selectors to a string
    # name, then map parameters that are passed to that delegate method
    # to the block parameters as in the "Simple Delegation" example.
    #
    # @example Simple delegation
    #
    #   HotCocoa::Mapping.map(window: NSWindow) do
    #     delegating 'windowWillClose:', :to => :will_close
    #   end
    #
    # This creates a `#will_close` method that accepts a block.
    #
    # The generated `#windowWillClose` method calls that block when
    # Cocoa calls the `#windowWillClose` method.
    #
    # When a delegate needs to forward parameters to the block, the
    # definition becomes a little more complex as shown in the
    # "Delegation with parameters" example.
    #
    # @example Delegation with parameters
    #
    #   HotCocoa::Mapping.map(window: NSWindow) do
    #       delegating 'window:willPositionSheet:usingRect:',
    #                  :to         => :will_position_sheet,
    #                  :parameters => [:willPositionSheet, :usingRect]
    #   end
    #
    #   # using the method would look like:
    #   window.will_position_sheet {|sheet, rect| ... }
    #
    # The `:parameters` list contains the corresponding selector name
    # from the Objective-C selector. Even though the delegate method
    # normally has three parameters (window, willPositionSheet, and
    # usingRect), the block will only be passed the last two.
    #
    # It’s also possible to pre-process a parameter, in cases where you
    # have to invoke a more complex calling on the parameter as shown in
    # the "Pre-processing a parameter" example.
    #
    # @example Pre-processing a parameter
    #
    #   HotCocoa::Mapping.map(:window => :NSWindow) do
    #     delegating "windowDidExpose:",
    #       :to         => :did_expose,
    #       :parameters => ["windowDidExpose.userInfo['NSExposedRect']"]
    #   end
    #
    #   # using this method would look like:
    #   window.did_expose { | rect| ... }
    #
    # Here we want to walk the first parameter’s `userInfo` dictionary,
    # get the `NSExposedRect` rectangle, and pass it as a parameter to the
    # `#did_expose` block.
    #
    # @param [String,Symbol] name
    # @param [Hash{:to=>:ruby_name, :parameters=>Array<String>}] options
    #   the `:to` key must be included, but `:parameters` is optional
    def delegating name, options
      delegate_map[name] = options
    end

    ##
    # @todo Can we use attr_accessor :delegate_map instead?
    #
    # A mapping of constant mappings that were created with calls to
    # {#delegating}.
    #
    # @return [Hash{Symbol=>Hash{Symbol=>SEL}}]
    def delegate_map
      @delegate_map ||= {}
    end

  end
end
