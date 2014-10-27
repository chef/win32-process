########################################################################
# test_win32_process_kill.rb
#
# Tests for the custom Process.kill method
########################################################################
require 'win32/process'
require 'test-unit'

class TC_Win32_Process_Kill < Test::Unit::TestCase
  def self.startup
    @@signals = Signal.list
  end

  def setup
    @ruby = RUBY_PLATFORM == 'java' ? 'jruby' : 'ruby'
    @cmd  = "#{@ruby} -e 'sleep 10'"
    @pid  = nil
  end

  test "kill basic functionality" do
    assert_respond_to(Process, :kill)
  end

  test "kill with signal 0 does not actually send a signal" do
    assert_nothing_raised{ Process.kill(0, Process.pid) }
  end

  test "kill with signal 0 returns 1 if the process exists" do
    assert_equal(1, Process.kill(0, Process.pid))
  end

  test "kill with signal 0 raises an ESRCH error if any process does not exist" do
    assert_raise(Errno::ESRCH){ Process.kill(0, 99999999) }
    assert_raise(Errno::ESRCH){ Process.kill(0, Process.pid, 99999999) }
  end

  test "kill accepts multiple pid values" do
    pid = Process.pid
    assert_nothing_raised{ Process.kill(0, pid, pid, pid, pid) }
  end

  test "kill with any signal returns the number of killed processes" do
    pid1 = Process.spawn(@cmd)
    pid2 = Process.spawn(@cmd)
    assert_equal(2, Process.kill(9, pid1, pid2))
  end

  test "kill accepts a string as a signal name" do
    pid = Process.spawn(@cmd)
    assert_nothing_raised{ Process.kill('SIGKILL', pid) }
  end

  test "kill accepts a string without 'SIG' as a signal name" do
    pid = Process.spawn(@cmd)
    assert_nothing_raised{ Process.kill('KILL', pid) }
  end

  test "kill accepts a symbol as a signal name" do
    pid = Process.spawn(@cmd)
    assert_nothing_raised{ Process.kill(:KILL, pid) }
  end

  test "kill coerces the pid to an integer" do
    pid = Process.pid.to_f + 0.7
    assert_nothing_raised{ Process.kill(0, pid) }
  end

  test "an EINVAL error is raised on Windows if the signal is negative" do
    @pid = Process.spawn(@cmd)
    assert_raise(Errno::EINVAL){ Process.kill(-3, @pid) }
  end

  test "an EINVAL error is raised on Windows if the pid is 0 and it's not a SIGINT" do
    assert_raise(Errno::EINVAL){ Process.kill(9, 0) }
  end

  test "kill accepts BRK or SIGBRK as a signal name" do
    pid = Process.spawn(@cmd)
    assert_nothing_raised{ Process.kill(:BRK, pid) }
    assert_nothing_raised{ Process.kill(:SIGBRK, pid) }
  end

  # We break from the spec here.
  #test "an EINVAL error is raised if the pid is the current process and it's not a 0 or SIGKILL" do
  #  assert_raise(Errno::EINVAL){ Process.kill(1, Process.pid) }
  #end

  test "kill requires at least two arguments" do
    assert_raise(ArgumentError){ Process.kill }
    assert_raise(ArgumentError){ Process.kill(@pid) }
  end

  test "the first argument to kill must be an integer or string" do
    assert_raise(ArgumentError){ Process.kill([], 0) }
  end

  test "kill raises an ArgumentError if the signal name is invalid" do
    assert_raise(ArgumentError){ Process.kill("BOGUS", 0) }
  end

  test "kill does not accept lowercase signal names" do
    assert_raise(ArgumentError){ Process.kill("kill", 0) }
  end

  test "kill raises an EINVAL error if the signal number is invalid" do
    assert_raise(Errno::EINVAL){ Process.kill(999999, 0) }
  end

  test "kill raises an TypeError if the pid value is not an integer" do
    assert_raise(TypeError){ Process.kill(0, "BOGUS") }
  end

  # TODO: Fix this
  #test "kill raises an EPERM if user does not have proper privileges" do
  #  omit_if(Process.uid == 0)
  #  assert_raise(Errno::EPERM){ Process.kill(9, 1) }
  #end

  test "kill raises a SecurityError if $SAFE level is 2 or greater" do
    omit_if(@ruby == 'jruby')
    assert_raise(SecurityError){
      proc do
        $SAFE = 2
        @pid = Process.spawn(@cmd)
        Process.kill(9, @pid)
      end.call
    }
  end

  test "kill works if the $SAFE level is 1 or lower" do
    omit_if(@ruby == 'jruby')
    assert_nothing_raised{
      proc do
        $SAFE = 1
        @pid = Process.spawn(@cmd)
        Process.kill(9, @pid)
      end.call
    }
  end

=begin
  test "kill(0) can't tell if the process ended, use get_exitcode instead" do
    pid = Process.create(
      :app_name         => 'cmd /c exit 0',
      :creation_flags   => Process::DETACHED_PROCESS
    ).process_id
    10.times do
      sleep(0.1)
      assert_nothing_raised do
        assert_equal 1, Process.kill(0, pid)
      end
    end
  end
=end

  def teardown
    @cmd  = nil
    @ruby = nil
    Process.kill(9, @pid) if @pid rescue nil
  end

  def self.teardown
    @@signals = nil
  end
end
