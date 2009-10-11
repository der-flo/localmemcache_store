# Module borrowed from the Rails tests
# http://github.com/rails/rails/blob/master/activesupport/test/caching_test.rb

# Tests the base functionality that should be identical across all cache stores.
module CacheStoreBehavior
  def test_should_read_and_write_strings
    @cache.write('foo', 'bar')
    assert_equal 'bar', @cache.read('foo')
  end
 
  def test_should_read_and_write_hash
    @cache.write('foo', {:a => "b"})
    assert_equal({:a => "b"}, @cache.read('foo'))
  end
 
  def test_should_read_and_write_integer
    @cache.write('foo', 1)
    assert_equal 1, @cache.read('foo')
  end
 
  def test_should_read_and_write_nil
    @cache.write('foo', nil)
    assert_equal nil, @cache.read('foo')
  end
 
  def test_fetch_without_cache_miss
    @cache.write('foo', 'bar')
    assert_equal 'bar', @cache.fetch('foo') { 'baz' }
  end
 
  def test_fetch_with_cache_miss
    assert_equal 'baz', @cache.fetch('foo') { 'baz' }
  end
 
  def test_fetch_with_forced_cache_miss
    @cache.fetch('foo', :force => true) { 'bar' }
  end
 
  def test_increment
    @cache.write('foo', 1, :raw => true)
    assert_equal 1, @cache.read('foo', :raw => true).to_i
    assert_equal 2, @cache.increment('foo')
    assert_equal 2, @cache.read('foo', :raw => true).to_i
    assert_equal 3, @cache.increment('foo')
    assert_equal 3, @cache.read('foo', :raw => true).to_i
  end
 
  def test_decrement
    @cache.write('foo', 3, :raw => true)
    assert_equal 3, @cache.read('foo', :raw => true).to_i
    assert_equal 2, @cache.decrement('foo')
    assert_equal 2, @cache.read('foo', :raw => true).to_i
    assert_equal 1, @cache.decrement('foo')
    assert_equal 1, @cache.read('foo', :raw => true).to_i
  end
 
  def test_exist
    @cache.write('foo', 'bar')
    assert @cache.exist?('foo')
    assert !@cache.exist?('bar')
  end
end