begin
  gem 'localmemcache', '>=0.4.3'
  require 'localmemcache'
rescue LoadError
  raise '"localmemcache>=0.4.3" gem is not installed!'
end

module ActiveSupport::Cache
  class LocalmemcacheStore < Store
    
    DataExpiresPair = Struct.new(:data, :expires_at) #:nodoc:

    # Useful options:
    # * +:namespace+: Namespace to avoid name collisions, defaults to
    #   +:lmc_store+.
    #
    #   This is escpecially useful if to run seperated caches on one machine.   
    # * +:size_mb+: Size of the cache, defaults to +128+.
    def initialize options = {}
      options.reverse_merge!({
        :namespace => :lmc_store,
        :size_mb => 128
      })
      @size_mb = options[:size_mb]
      @lmc = LocalMemCache::ExpiryCache.new options
    end

    # Reads a value by +name+.
    #
    # (options are ignored at the time)
    def read(name, options = nil)
      super
      data_expires_pair = @lmc[name]
      return nil unless data_expires_pair
      
      # entry expired?
      if data_expires_pair.expires_at &&
         data_expires_pair.expires_at <= Time.now
         
        # delete entry from database
        @lmc.hash.delete(name)
        nil
      else
        data_expires_pair.data
      end
    end

    # Writes a +name+-+value+ pair to the cache.
    # Useful options:
    # * +:expires_in+: Number of seconds an entry is valid
    def write(name, value, options = {})
      super
      data = value.freeze
      expires_in = options[:expires_in]
      expires_at = if expires_in && expires_in.to_i > 0
        Time.now + expires_in.to_i
      end
      @lmc[name] = DataExpiresPair.new(data, expires_at)
      data
    end

    # Delete a pair by key name
    #
    # (options are ignored at the time)
    def delete(name, options = nil)
      super
      @lmc.delete(name)
    end

    # Delete all pair with key matching matcher
    #
    # (options are ignored at the time)
    def delete_matched(matcher, options = nil)
      super
      @lmc.each_pair do |key, value|
        @lmc.delete(key) if key =~ matcher
      end
    end

    # Checks key for existance 
    #
    # (options are ignored at the time)
    def exist?(name, options = nil)
      super
      !@lmc[name].nil?
    end

    # Clears the entire cache.
    def clear
      @lmc.clear
    end
  end
end
