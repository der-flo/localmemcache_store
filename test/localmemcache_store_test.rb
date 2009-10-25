require File.dirname(__FILE__) + '/test_helper'
require File.dirname(__FILE__) + '/cache_store_behavior.rb'

# Most tests borrowed from the Rails tests
# http://github.com/rails/rails/blob/master/activesupport/test/caching_test.rb

class LocalmemcacheStoreTest < ActiveSupport::TestCase

  def setup
    @cache = ActiveSupport::Cache.lookup_store(:localmemcache_store, { :namespace => 'lmc_store_test' })
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

end
