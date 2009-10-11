require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

require 'rubygems'
require 'rake/gempackagetask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the localmemcache_store plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the localmemcache_store plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'LocalmemcacheStore'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

################################################################################
# GEM stuff

PKG_FILES = FileList[
  '[a-zA-Z]*',
#  'generators/**/*',
  'lib/**/*',
  'rails/**/*',
  'tasks/**/*',
  'test/**/*'
]

spec = Gem::Specification.new do |s|
  s.name = "localmemcache_store"
  s.version = "0.0.1"
  s.author = "Florian Dütsch (der_flo)"
  s.email = "mail@florian-duetsch.de"
  s.homepage = "http://github.com/der-flo/localmemcache_store"
  s.platform = Gem::Platform::RUBY
  s.summary = "A Rails cache store implementation for localmemcache"
  s.files = PKG_FILES.to_a
  s.require_path = "lib"
  s.has_rdoc = false
  s.extra_rdoc_files = ["README"]
end

desc 'Turn this plugin into a gem.'
Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end
