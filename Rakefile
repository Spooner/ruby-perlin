require 'rake/clean'
require 'rspec/core/rake_task'
require 'rake/extensiontask'
require 'yard'
require 'redcloth'
require 'launchy'


begin
  require 'devkit' # only used on windows
rescue LoadError
end

CLOBBER << "coverage"

spec = Gem::Specification.load Dir["*.gemspec"][0]

Gem::PackageTask.new spec do
end

Rake::ExtensionTask.new 'perlin', spec do |ext|
  RUBY_VERSION =~ /(\d+.\d+)/
  ext.lib_dir = "lib/perlin/#{$1}"
end

YARD::Rake::YardocTask.new

task :default => :spec
task :spec => :compile

RSpec::Core::RakeTask.new do |t|
end

desc "Generate SimpleCov test coverage and open in your browser"
task :coverage do
  rm_r "coverage" rescue nil

  sh %q<ruby -rsimplecov -e "SimpleCov.command_name 'spec'; SimpleCov.start">

  Launchy.open "coverage/index.html" rescue nil
end

desc "Open yard docs in browser"
task :browse_yard => :yard do
  Launchy.open "doc/index.html" rescue nil
end

desc "Run benchmarks"
task :bench => :compile do
  require File.expand_path("../bench/benchmarks.rb", __FILE__)
end