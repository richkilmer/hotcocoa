HotCocoa::Mappings.map :user_defaults => :NSUserDefaults do
  defaults :defaults => {}

  def alloc_with_options(options)
    user_defaults = NSUserDefaults.standardUserDefaults

    unless options[:defaults].nil?
      defs = {}
      # force all keys to be strings, doesn't seem to like symbols
      options.delete(:defaults).each_pair { |key, value| defs[key.to_s] = value }
      user_defaults.registerDefaults(defs)
    end

    user_defaults
  end

  custom_methods do
    def []=(key, value)
      if value.nil?
        delete(key.to_s)
      else
        setObject(value, forKey:key.to_s)
      end
      sync
    end

    def [](key)
      objectForKey(key.to_s)
    end

    def delete(key)
      removeObjectForKey(key)
      sync
    end

    def sync
      puts "Failed to synchronize" unless synchronize
    end
  end
end