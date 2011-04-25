module Kernel

  alias_method :default_framework, :framework

  ##
  # @todo The idea given here should probably be pushed upstream to MacRuby
  #       since framework loading in MacRuby doesn't really short path if
  #       the framework is already loaded (it still does the lookup).
  #
  # Override MacRuby's built-in #framework method in order to support lazy
  # loading frameworks inside of HotCocoa.
  def framework name
    if default_framework(name)
      HotCocoa::Mappings.framework_loaded
      true
    else
      false
    end
  end

end
