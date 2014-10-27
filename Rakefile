require 'rake'
require 'rake/clean'
require 'rake/testtask'
require 'rbconfig'
include RbConfig

CLEAN.include('**/*.gem', '**/*.rbc', '**/*.log')

namespace :gem do
  desc 'Create the win32-process gem'
  task :create => [:clean] do
    spec = eval(IO.read('win32-process.gemspec'))
    if Gem::VERSION < "2.0"
      Gem::Builder.new(spec).build
    else
      require 'rubygems/package'
      Gem::Package.build(spec)
    end
  end

  desc 'Install the win32-process gem'
  task :install => [:create] do
    file = Dir["*.gem"].first
    sh "gem install -l #{file}"
  end
end

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
