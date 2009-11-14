begin
  gem 'localmemcache', '>=0.4.4'
  require 'localmemcache'
rescue LoadError
  raise '"localmemcache>=0.4.4" gem is not installed!'
end

class ExpiryCache

  class Entry < Struct.new(:data, :expires_at)
    def expired?
      expires_at && expires_at <= Time.now
    end
  end

  def initialize(options = {})
    opts = {
      :expiration_check_interval => 1_000
    }.merge(options)
    @cache = LocalMemCache::SharedObjectStorage.new opts
    @expiration_check_interval = opts[:expiration_check_interval]
    @expiration_check_counter = 0
  end

  def has_key? key
    verify_key_not_expired key
    @cache.has_key? key
  end

  def clear
    @cache.clear
  end
  def shm_status
    @cache.shm_status
  end
  
  def read key
    do_expiration_check
    entry = @cache[key]

    # return if nothing in cache
    return nil unless entry
    
    # entry expired?
    if verify_entry_not_expired(key, entry)
      entry.data
    else
      nil
    end
  end

  def write key, value, expires_in = nil
    do_expiration_check

    value.freeze

    # calculate expiration
    expires_at = if expires_in && expires_in.to_i > 0
      Time.now + expires_in.to_i
    end

    # store data
    if expires_at.nil? || expires_at > Time.now
      entry = Entry.new(value, expires_at)
      safe_write key, entry
    end

    value
  end
  
  def delete key
    @cache.delete key
  end
  
  def delete_matched matcher
    @cache.each_pair do |key, value|
      @cache.delete(key) if key =~ matcher
    end
  end

  private

  def verify_key_not_expired key
    entry = @cache[key]
    verify_entry_not_expired(key, entry) if entry
  end
  def verify_entry_not_expired key, entry
    if entry.expired?
      @cache.delete(key)
      false
    else
      true
    end
  end
  
  def do_expiration_check
    @expiration_check_counter += 1
    return unless @expiration_check_counter >= @expiration_check_interval
    @expiration_check_counter = 0
    expire_random_entries
  end

  def expire_random_entries count = 1_000
    [count, @cache.size].min.times do
      key, entry = @cache.random_pair
      break if key.nil?
      verify_entry_not_expired key, entry
    end
  end

  def expire_some_entries count = 100
    count = [count, @cache.size].min
    @cache.each_pair do |key, entry|
      break if count <= 0
      count -= 1 unless verify_entry_not_expired(key, entry)
    end
  end

  # TODO: Performance?
  def safe_write key, entry
    random_tries = 10
    some_tries = 10
    cleared = false
    begin
      @cache[key] = entry
    rescue LocalMemCache::MemoryPoolFull
      if random_tries > 0
        random_tries -= 1
        expire_random_entries
        retry
      elsif some_tries > 0
        some_tries -= 1
        expire_some_entries
        retry
    else
        raise if cleared
        @cache.clear
        cleared = true
        retry
      end
    end
    entry
  end
end
