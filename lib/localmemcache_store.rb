unless defined? ActiveSupport::Cache::LocalmemcacheStore
  require 'expiry_cache'
  require 'active_support/cache/localmemcache_store'
end