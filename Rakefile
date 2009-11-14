require 'rubygems'
require 'rake'
require 'hanna/rdoctask'
require 'rake/testtask'
require 'rake/gempackagetask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the localmemcache_store plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  #t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

#task :rcov do
#  excludes = %w( lib/will_paginate/named_scope*
#                 lib/will_paginate/core_ext.rb
#                 lib/will_paginate.rb
#                 rails* )
#
#  system %[rcov -Itest:lib test/*.rb -x #{excludes.join(',')}]
#end

desc 'Generate documentation for the localmemcache_store plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'LocalmemcacheStore Documentation'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.options << '--charset' << 'utf-8'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
  rdoc.rdoc_files.exclude('lib/localmemcache_store.rb')
end

################################################################################
# GEM stuff
PKG_FILES = FileList[
  'MIT-LICENSE',
  'README.rdoc',
  'VERSION',
  'lib/**/*',
  'rails/**/*',
  'test/**/*'
]
begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "localmemcache_store"
    gemspec.summary = "A Rails cache store implementation for localmemcache"
    gemspec.email = "mail@florian-duetsch.de"
    gemspec.homepage = "http://github.com/der-flo/localmemcache_store"
    gemspec.authors = ["Florian Dütsch (der_flo)"]
    gemspec.files = PKG_FILES.to_a
    gemspec.extra_rdoc_files = ['README.rdoc']
    gemspec.add_dependency('localmemcache', '>= 0.4.4')
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end
