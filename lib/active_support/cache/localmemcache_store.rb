begin
  gem 'localmemcache', '>=0.4.3'
  require 'localmemcache'
rescue LoadError
  raise '"localmemcache>=0.4.3" gem is not installed!'
end

module ActiveSupport::Cache
  class LocalmemcacheStore < Store
    
    DataExpiresPair = Struct.new(:data, :expires_at)
    
    def initialize options = {}
      # TODO: Define default parameters
      options.reverse_merge!({
        :namespace => :x,
        :size_mb => 64
      })
      @lmc = LocalMemCache::SharedObjectStorage.new options
    end

    def read(name, options = nil)
      super
      data_expires_pair = @lmc[name]
      return nil unless data_expires_pair
      
      # entry expired?
      if data_expires_pair.expires_at &&
         data_expires_pair.expires_at <= Time.now
         
        # delete entry from database
        @lmc.delete(name)
        nil
      else
        data_expires_pair.data
      end
    end

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

    def delete(name, options = nil)
      super
      @lmc.delete(name)
    end

    def delete_matched(matcher, options = nil)
      super
      # TODO: Performance?
      @lmc.each_pair do |key, value|
        next unless key =~ matcher
        @lmc.delete(key)
      end
    end

    def exist?(name,options = nil)
      super
      # TODO: Performance?
      # Read the value and check for nil?
      @lmc.keys.include?(name)
    end

    def clear
      @lmc.clear
    end
  end
end
