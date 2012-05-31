require File.join(File.expand_path(File.dirname(__FILE__)), 'process', 'functions')
require File.join(File.expand_path(File.dirname(__FILE__)), 'process', 'constants')

module Process
  include Process::Constants
  extend Process::Functions

  def getpriority(kind, int)
    raise TypeError, kind unless kind.is_a?(Fixnum) # Match spec
    raise TypeError, int unless int.is_a?(Fixnum)   # Match spec
    int = Process.pid if int == 0                   # Match spec

    handle = OpenProcess(PROCESS_QUERY_INFORMATION, false, int)

    if handle == INVALID_HANDLE_VALUE
      raise SystemCallError, FFI.errno, "OpenProcess"
    end

    begin
      priority = GetPriorityClass(handle)

      if priority == 0
        raise SystemCallError, FFI.errno, "GetPriorityClass"
      end
    ensure
      CloseHandle(handle)
    end

    priority
  end

  module_function :getpriority
end
