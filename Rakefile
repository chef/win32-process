require 'rake'
require 'rake/testtask'
require 'rbconfig'
include Config

desc 'Install the win32-process library (non-gem)'
task :install do
   install_dir = File.join(CONFIG['sitelibdir'], 'win32')
   Dir.mkdir(install_dir) unless File.exists?(install_dir)
   cp 'lib/win32/process.rb', install_dir, :verbose => true
end

desc 'Removes the win32-process library (non-gem)'
task :uninstall do
   file = File.join(CONFIG['sitelibdir'], 'win32', 'process.rb')
   if File.exists?(file)
      rm_f file, :verbose => true
   end
end

desc 'Builds a gem for the win32-process library'
task :build_gem do
   eval(IO.read('win32-process.gemspec'))
end

task :install_gem do
   ruby 'win32-process.gemspec'
   file = Dir["*.gem"].first
   sh "gem install #{file}"
end

Rake::TestTask.new do |t|
   t.verbose = true
   t.warning = true
end
