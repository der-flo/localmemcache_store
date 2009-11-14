module ActiveSupport::Cache
  class LocalmemcacheStore < Store

    # Useful options:
    # * +:namespace+: Namespace to avoid name collisions, defaults to
    #   +:lmc_store+.
    #
    #   This is especially useful if to run separated caches on one machine.   
    # * +:size_mb+: Size of the cache, defaults to +64+.
    def initialize options = {}
      options.reverse_merge!({
        :namespace => :lmc_store,
        :size_mb => 64
      })
      @size_mb = options[:size_mb]
      @cache = ExpiryCache.new options
    end

    # Reads a value by +name+.
    #
    # (options are ignored at the time)
    def read(name, options = nil)
      super
      @cache.read name
    end

    # Writes a +name+-+value+ pair to the cache.
    # Useful options:
    # * +:expires_in+: Number of seconds an entry is valid
    def write(name, value, options = {})
      super
      @cache.write name, value, options[:expires_in]
    end

    # Delete a pair by key name
    #
    # (options are ignored at the time)
    def delete(name, options = nil)
      super
      @cache.delete name
    end

    # Delete all pair with key matching matcher
    #
    # (options are ignored at the time)
    def delete_matched(matcher, options = nil)
      super
      @cache.delete_matched matcher
    end

    # Checks key for existance 
    #
    # (options are ignored at the time)
    def exist?(name, options = nil)
      super
      @cache.has_key?(name)
    end

    # Clears the entire cache.
    def clear
      @cache.clear
    end

    # Returns the status of the cache in form of a hash. Elements are:
    # +:free_bytes+, +:used_bytes+, +:total_bytes+ and +:usage+
    def status
      s = @cache.shm_status
      s[:usage] = s[:used_bytes].to_f / s[:total_bytes].to_f
      s
    end
  end
end
