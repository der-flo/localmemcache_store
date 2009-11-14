require File.dirname(__FILE__) + '/test_helper'

class ExpiryCacheTest < ActiveSupport::TestCase

  def setup
    @cache = ExpiryCache.new(:namespace => 'expiry_cache_test', :size_mb => 16)
    @cache.clear
  end

  def expire_entries_test method
    1.upto(10) { |i| @cache.write(i, 'x' * 1_000, 1.second) }
    used = @cache.shm_status[:used_bytes]
    sleep 2
    @cache.send method
    assert_operator used, :>, @cache.shm_status[:used_bytes]
  end
  
  test "expiration by expire_random_entries" do
    expire_entries_test :expire_random_entries
  end
  test "expiration by expire_some_entries" do
    expire_entries_test :expire_some_entries
  end
  
  test "automatic deletion of some expired entries" do
    @cache.write :foo, :bar, 1.second
    sleep 2
    used = @cache.shm_status[:used_bytes]
    999.times { @cache.write :baz, :baz }
    assert_operator used, :>, @cache.shm_status[:used_bytes]
  end
  
  test "safe_write with full pool" do
    five_mb = 1_024 * 1_024 * 5 
    @cache.write :foo, 'x' * five_mb, 1.second
    sleep 2
    assert_nothing_raised do
      @cache.write :bar, 'x' * five_mb
    end
  end
  
  test "safe_write with full pool and no chance to random expire entries" do
    five_mb = 1_024 * 1_024 * 5 
    @cache.write :foo, 'x' * five_mb, 1.second
    1.upto(50_000) { |i| @cache.write i, 'x' }
    assert_nothing_raised do
      @cache.write :bar, 'x' * five_mb
    end
  end
  
  test "safe_write with full pool and no expirable entries" do
    five_mb = 1_024 * 1_024 * 5 
    @cache.write :foo, 'x' * five_mb
    sleep 2
    assert_nothing_raised do
      @cache.write :bar, 'x' * five_mb
    end
  end
end
