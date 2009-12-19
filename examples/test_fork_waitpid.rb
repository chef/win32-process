##########################################################################
# test_fork_waitpid.rb
#
# Generic test script for futzing around with the traditional form of
# fork/wait, plus waitpid and waitpid2.
##########################################################################
Dir.chdir('..') if File.basename(Dir.pwd) == 'examples'
$LOAD_PATH.unshift Dir.pwd
$LOAD_PATH.unshift Dir.pwd + '/lib'
Dir.chdir('examples') rescue nil

require 'win32/process'

puts "VERSION: " + Process::WIN32_PROCESS_VERSION

pid = Process.fork
puts "PID1: #{pid}"

#child
if pid.nil?
   7.times{ |i|
      puts "Child: #{i}"
      sleep 1
   }
   exit(-1)
end

pid2 = Process.fork
puts "PID2: #{pid2}"

#child2
if pid2.nil?
   7.times{ |i|
      puts "Child2: #{i}"
      sleep 1
   }
   exit(1)
end

#parent
2.times { |i|
   puts "Parent: #{i}"
   sleep 1
}

p Process.waitpid2(pid)
p Process.waitpid2(pid2)

puts "Continuing on..."

