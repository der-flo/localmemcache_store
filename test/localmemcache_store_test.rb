require File.dirname(__FILE__) + '/test_helper'
require File.dirname(__FILE__) + '/cache_store_behavior.rb'

# Most tests borrowed from the Rails tests
# http://github.com/rails/rails/blob/master/activesupport/test/caching_test.rb

class LocalmemcacheStoreTest < ActiveSupport::TestCase

  def setup
    @cache = ActiveSupport::Cache.lookup_store(:localmemcache_store,
      { :namespace => 'lmc_store_test' })
    @cache.clear
    @cache.silence!
    @cache.logger = Logger.new("/dev/null")
  end

  test "write a value to the cache" do
    assert_nothing_raised do
      value = :value
      ret = @cache.write :key, value
      assert_equal ret, value
    end
  end

  test "read a cached value" do
    assert_nothing_raised do
      value = :value
      @cache.write :key, value
      assert_equal value, @cache.read(:key)
    end
  end

  test "entry expires" do
    value = :value
    @cache.write :key, value, :expires_in => 1.second
    assert_equal :value, @cache.read(:key)
    sleep 2
    assert_nil @cache.read(:key)
  end
  
  test "delete an entry" do
    @cache.write :key, :value
    @cache.delete :key
    assert_nil @cache.read(:key)
  end
  
  test "entry exists" do
    assert !@cache.exist?(:foo)
    @cache.write :foo, :bar
    assert @cache.exist?(:foo)
  end
  
  test "delete entries by regex" do
    @cache.write :foo1, :bar
    @cache.write :foo2, :bar
    @cache.write :baz, :bar

    @cache.delete_matched /^foo/
    
    assert !@cache.exist?(:foo1)
    assert !@cache.exist?(:foo2)
    assert @cache.exist?(:baz)
  end

  include CacheStoreBehavior

  def test_store_objects_should_be_immutable
    @cache.write('foo', 'bar')
    @cache.read('foo').gsub!(/.*/, 'baz')
    assert_equal 'bar', @cache.read('foo')
  end

  def test_stored_objects_should_not_be_frozen
    @cache.write('foo', 'bar')
    assert !@cache.read('foo').frozen?
  end

  def test_write_should_return_true_on_success
    result = @cache.write('foo', 'bar')
    assert_equal 'bar', @cache.read('foo') # make sure 'foo' was written
    assert result
  end

  test "has status" do
    assert_not_nil @cache.status
  end
  test "status has free_bytes" do
    assert_not_nil @cache.status[:free_bytes]
  end
  test "status has used_bytes" do
    assert_not_nil @cache.status[:used_bytes]    
  end
  test "status has total_bytes" do
    assert_not_nil @cache.status[:total_bytes]
  end
  test "status has usage" do
    assert_not_nil @cache.status[:usage]
  end
end
