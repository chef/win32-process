###############################################################################
# test_win32_process.rb
#
# Test suite for the win32-process library.  This test suite will start
# at least two instances of Notepad on your system, which will then
# be killed. Requires the sys-proctable library.
#
# I haven't added a lot of test cases for fork/wait because it's difficult
# to run such tests without causing havoc with Test::Unit itself.  Ideas
# welcome.
#
# You should run this test case via the 'rake test' task.
###############################################################################
require 'rubygems'
gem 'test-unit'

require 'test/unit'
require 'win32/process'
require 'sys/proctable'

class TC_Win32Process < Test::Unit::TestCase  

  # Start two instances of notepad and give them a chance to fire up
  def self.startup
    IO.popen('notepad')
    IO.popen('notepad')
    sleep 1 # Give the notepad instances a second to startup
      
    @@pids = []

    Sys::ProcTable.ps{ |struct|
      next unless struct.comm =~ /notepad/i
      @@pids << struct.pid
    }
  end

  def setup
    @pri_class = Process::NORMAL_PRIORITY_CLASS
  end
  
  test "win32-process version is set to the correct value" do
    assert_equal('0.6.5', Process::WIN32_PROCESS_VERSION)
  end
   
  test "kill basic functionality" do
    assert_respond_to(Process, :kill)
  end
   
  test "kill requires at least one argument" do
    assert_raises(ArgumentError){ Process.kill }
  end

  test "kill raises an error if an invalid signal is provided" do
    assert_raises(Process::Error){ Process.kill('SIGBOGUS') }
  end

  test "kill raises an error if an invalid process id is provided" do
    assert_raises(Process::Error){ Process.kill(0, 9999999) }
  end
   
  test "kill with signal 0 does not kill the process" do
    pid = @@pids.first
    assert_nothing_raised{ Process.kill(0, pid) }
    assert_not_nil(Sys::ProcTable.ps(pid))
  end
   
  test "kill with signal 1 kills the process normally" do
    pid = @@pids.shift
    assert_nothing_raised{ Process.kill(1, pid) }
    assert_nil(Sys::ProcTable.ps(pid))
  end
   
  test "kill with signal 9 kills the process brutally" do
    pid = @@pids.pop
    msg = "Could not find pid #{pid}"
    assert_nothing_raised(msg){ Process.kill(9, pid) }
    assert_nil(Sys::ProcTable.ps(pid))
  end

  test "fork basic functionality" do
    assert_respond_to(Process, :fork)
  end
      	
  test "create basic functionality" do
    assert_respond_to(Process, :create)
  end

  test "create with common flags works as expected" do
    assert_nothing_raised{
      @@pids << Process.create(
         :app_name         => "notepad.exe",
         :creation_flags   => Process::DETACHED_PROCESS,
         :process_inherit  => false,
         :thread_inherit   => true,
         :cwd              => "C:\\"
      ).process_id
    }

    assert_nothing_raised{ Process.kill(1, @@pids.pop) }
  end
   
  test "create requires a hash argument" do
    assert_raise(TypeError){ Process.create("bogusapp.exe") }
  end

  test "create does not accept invalid keys" do
    assert_raise(ArgumentError){ Process.create(:bogus => 'test.exe') }
    assert_raise_message("invalid key 'bogus'"){
      Process.create(:bogus => 'test.exe')
    }
  end

  test "create does not accept invalid startup_info keys" do
    assert_raise(ArgumentError){
      Process.create(:startup_info => {:foo => 'test'})
    }
    assert_raise_message("invalid startup_info key 'foo'"){
      Process.create(:startup_info => {:foo => 'test'})
    }
  end

  test "create raises an error if the executable cannot be found" do
    err = "CreateProcess() failed: The system cannot find the file specified."
    assert_raise(Process::Error){ Process.create(:app_name => "bogusapp.exe") }
    assert_raise_message(err){ Process.create(:app_name => "bogusapp.exe") }
  end
   
  test "wait basic functionality" do
    assert_respond_to(Process, :wait)
  end
   
  test "wait2 basic functionality" do
    assert_respond_to(Process, :wait2)
  end
   
  test "waitpid basic functionality" do
    assert_respond_to(Process, :waitpid)
  end
   
  test "waitpid2 basic functionality" do
    assert_respond_to(Process, :waitpid2)
  end

  test "ppid basic functionality" do
    assert_respond_to(Process, :ppid)
    assert_nothing_raised{ Process.ppid }
  end

  test "ppid returns expected results" do
    assert_kind_of(Integer, Process.ppid)
    assert_true(Process.ppid > 0)
    assert_false(Process.pid == Process.ppid)
  end
   
  test "uid basic functionality" do
    assert_respond_to(Process, :uid)
    assert_kind_of(Fixnum, Process.uid)
  end

  test "uid accepts a boolean argument" do  
    assert_nothing_raised{ Process.uid(true) }
    assert_nothing_raised{ Process.uid(true) }
  end

  test "uid returns a string if its argument is true" do
    assert_kind_of(String, Process.uid(true))      
  end

  test "uid accepts a maximum of one argument" do
    assert_raise(ArgumentError){ Process.uid(true, true) }
  end

  test "argument to uid must be a boolean" do
    assert_raise(TypeError){ Process.uid('test') }
  end

  test "getpriority basic functionality" do
    assert_respond_to(Process, :getpriority)
    assert_nothing_raised{ Process.getpriority(Process::PRIO_PROCESS, Process.pid) }
    assert_kind_of(Fixnum, Process.getpriority(Process::PRIO_PROCESS, Process.pid))
  end

  test "getpriority treats an int argument of zero as the current process" do
    assert_nothing_raised{ Process.getpriority(0, 0) }
  end

  test "getpriority requires both a kind and an int" do
    assert_raise(ArgumentError){ Process.getpriority }
    assert_raise(ArgumentError){ Process.getpriority(Process::PRIO_PROCESS) }
  end

  test "getpriority requires integer arguments" do
    assert_raise(TypeError){ Process.getpriority('test', 0) }
    assert_raise(TypeError){ Process.getpriority(Process::PRIO_PROCESS, 'test') }
  end

  test "setpriority basic functionality" do
    assert_respond_to(Process, :setpriority)
    assert_nothing_raised{ Process.setpriority(0, Process.pid, @pri_class) }
  end

  test "setpriority returns zero on success" do
    assert_equal(0, Process.setpriority(0, Process.pid, @pri_class))
  end

  test "setpriority treats an int argument of zero as the current process" do
    assert_equal(0, Process.setpriority(0, 0, @pri_class))
  end

  test "setpriority requires at least three arguments" do
    assert_raise(ArgumentError){ Process.setpriority }
    assert_raise(ArgumentError){ Process.setpriority(0) }
    assert_raise(ArgumentError){ Process.setpriority(0, 0) }
  end

  test "arguments to setpriority must be numeric" do
    assert_raise(TypeError){ Process.setpriority('test', 0, @pri_class) }
    assert_raise(TypeError){ Process.setpriority(0, 'test', @pri_class) }
    assert_raise(TypeError){ Process.setpriority(0, 0, 'test') }
  end

  test "custom creation constants are defined" do
    assert_not_nil(Process::CREATE_DEFAULT_ERROR_MODE)
    assert_not_nil(Process::CREATE_NEW_CONSOLE)
    assert_not_nil(Process::CREATE_NEW_PROCESS_GROUP)
    assert_not_nil(Process::CREATE_NO_WINDOW)
    assert_not_nil(Process::CREATE_SEPARATE_WOW_VDM)
    assert_not_nil(Process::CREATE_SHARED_WOW_VDM)
    assert_not_nil(Process::CREATE_SUSPENDED)
    assert_not_nil(Process::CREATE_UNICODE_ENVIRONMENT)
    assert_not_nil(Process::DEBUG_ONLY_THIS_PROCESS)
    assert_not_nil(Process::DEBUG_PROCESS)
    assert_not_nil(Process::DETACHED_PROCESS)
  end

  test "getrlimit basic functionality" do
    assert_respond_to(Process, :getrlimit)
    assert_nothing_raised{ Process.getrlimit(Process::RLIMIT_CPU) }
  end

  test "getrlimit returns an array of two numeric elements" do
    assert_kind_of(Array, Process.getrlimit(Process::RLIMIT_CPU))
    assert_equal(2, Process.getrlimit(Process::RLIMIT_CPU).length)
    assert_kind_of(Integer, Process.getrlimit(Process::RLIMIT_CPU).first)
  end

  test "getrlimit can be called multiple times without issue" do
    assert_nothing_raised{ Process.getrlimit(Process::RLIMIT_CPU) }
    assert_nothing_raised{ Process.getrlimit(Process::RLIMIT_CPU) }
    assert_nothing_raised{ Process.getrlimit(Process::RLIMIT_CPU) }
  end

  test "getrlimit requires a valid resource value" do
    assert_raise(Process::Error){ Process.getrlimit(9999) }
  end

  test "setrlimit basic functionality" do
    assert_respond_to(Process, :getrlimit)
    assert_nothing_raised{ Process.setrlimit(Process::RLIMIT_VMEM, 1024 * 4) }
  end

  test "setrlimit returns nil on success" do
    assert_nil(Process.setrlimit(Process::RLIMIT_VMEM, 1024 * 4))
  end

  test "setrlimit sets the resource limit as expected" do
    assert_nothing_raised{ Process.setrlimit(Process::RLIMIT_VMEM, 1024 * 4) }
    assert_equal([4096, 4096], Process.getrlimit(Process::RLIMIT_VMEM))
  end

  test "setrlimit raises an error if the resource value is invalid" do
    assert_raise(Process::Error){ Process.setrlimit(9999, 100) }
  end

  test "is_job basic functionality" do
    assert_respond_to(Process, :job?)
    assert_nothing_raised{ Process.job? }
  end

  test "is_job returns a boolean value" do
    assert_boolean(Process.job?)
  end

  test "is_job does not accept any arguments" do
    assert_raise(ArgumentError){ Process.job?(Process.pid) }
  end
   
  def teardown
    @pri_class = nil
  end

  def self.shutdown
    @@pids.each{ |pid| Process.kill(1, pid) }
    @@pids = []
  end
end
