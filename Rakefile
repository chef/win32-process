require "rubygems"
require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rbconfig'
include RbConfig

CLEAN.include('**/*.gem', '**/*.rbc', '**/*.log')

namespace :example do
  desc 'Run the fork + wait example'
  task :fork_wait do
    sh "ruby -Ilib examples/example_fork_wait.rb"
  end

  desc 'Run the fork + waitpid example'
  task :fork_waitpid do
    sh "ruby -Ilib examples/example_fork_waitpid.rb"
  end

  desc 'Run the kill example'
  task :kill do
    sh "ruby -Ilib examples/example_kill.rb"
  end

  desc 'Run the create example'
  task :create do
    sh "ruby -Ilib examples/example_create.rb"
  end
end

namespace :test do
  Rake::TestTask.new(:kill) do |t|
    t.verbose = true
    t.warning = true
    t.test_files = FileList['test/test_win32_process_kill.rb']
  end
end

Rake::TestTask.new do |t|
  t.verbose = true
  t.warning = true
end

task :default => :test
