require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rbconfig'
include Config

CLEAN.include('**/*.gem', '**/*.rbc')

namespace :gem do
  desc 'Create the win32-process gem'
  task :create do
    spec = eval(IO.read('win32-process.gemspec'))
    Gem::Builder.new(spec).build
  end

  desc 'Install the win32-process gem'
  task :install => [:gem] do
    file = Dir["*.gem"].first
    sh "gem install #{file}"
  end
end

Rake::TestTask.new do |t|
  t.verbose = true
  t.warning = true
end

task :default => :test
