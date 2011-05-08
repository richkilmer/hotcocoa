module HotCocoa

  module Behaviors

    ##
    # Implements the callback Module#included to make sure that classes
    # that mix in the {Behaviors} module and are themselves mixed in
    # later will also have custom methods, delegates, etc. properly
    # set up.
    def self.included klass
      Mappings::Mapper.map_class(klass)
    end

  end

end
