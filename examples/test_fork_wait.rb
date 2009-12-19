##########################################################################
# test_fork_wait.rb
#
# Generic test script for futzing around with the block form of fork/wait
##########################################################################
Dir.chdir('..') if File.basename(Dir.pwd) == 'examples'
$LOAD_PATH.unshift Dir.pwd
$LOAD_PATH.unshift Dir.pwd + '/lib'
Dir.chdir('examples') rescue nil

require 'win32/process'

puts "VERSION: " + Process::WIN32_PROCESS_VERSION

# In the child, using block form
fork{
  	7.times { |i|
     	puts "Child: #{i}"
     	sleep 1
  	}
}

# Back in the parent
4.times{ |i|
   	puts "Parent: #{i}"
   	sleep 1
}

# Wait for the children
Process.wait

# Children should be done here before continuing on
puts "Continuing on..."
