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
require 'test-unit'
require 'win32/process'
require 'sys/proctable'

class TC_Win32Process < Test::Unit::TestCase
  def setup
    @priority = Process::NORMAL_PRIORITY_CLASS
  end

  test "win32-process version is set to the correct value" do
    assert_equal('0.7.0', Process::WIN32_PROCESS_VERSION)
  end

=begin
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
=end

=begin
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
=end

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

=begin
  test "setpriority basic functionality" do
    assert_respond_to(Process, :setpriority)
    assert_nothing_raised{ Process.setpriority(0, Process.pid, @priority) }
  end

  test "setpriority returns zero on success" do
    assert_equal(0, Process.setpriority(0, Process.pid, @priority))
  end

  test "setpriority treats an int argument of zero as the current process" do
    assert_equal(0, Process.setpriority(0, 0, @priority))
  end

  test "setpriority requires at least three arguments" do
    assert_raise(ArgumentError){ Process.setpriority }
    assert_raise(ArgumentError){ Process.setpriority(0) }
    assert_raise(ArgumentError){ Process.setpriority(0, 0) }
  end

  test "arguments to setpriority must be numeric" do
    assert_raise(TypeError){ Process.setpriority('test', 0, @priority) }
    assert_raise(TypeError){ Process.setpriority(0, 'test', @priority) }
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
=end

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
    @priority = nil
  end
end
