##########################################################################
# test_kill.rb
#
# Generic test script for futzing around Process.kill.  This script
# requires the sys-proctable package (available on the RAA).
##########################################################################
Dir.chdir('..') if File.basename(Dir.pwd) == 'examples'
$LOAD_PATH.unshift Dir.pwd
$LOAD_PATH.unshift Dir.pwd + '/lib'
Dir.chdir('examples') rescue nil

require "win32/process"

begin
   require "sys/proctable"
rescue LoadError
   STDERR.puts "Whoa there!"
   STDERR.puts "This script requires the sys-proctable package to work."
   STDERR.puts "You can find it at http://ruby-sysutils.sf.net"
   STDERR.puts "Exiting..."
   exit
end
include Sys

puts "VERSION: " + Process::WIN32_PROCESS_VERSION

IO.popen("notepad")
sleep 1 # Give it a chance to start before checking for its pid

pids = []
ProcTable.ps{ |s|
   pids.push(s.pid) if s.cmdline =~ /notepad/i
}

p Process.kill(9,pids.last)