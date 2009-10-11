unless defined? ActiveSupport::Cache::LocalmemcacheStore
  require 'active_support/cache/localmemcache_store'
end