require File.join(File.expand_path(File.dirname(__FILE__)), 'process', 'functions')
require File.join(File.expand_path(File.dirname(__FILE__)), 'process', 'constants')

module Process
  include Process::Constants
  extend Process::Functions

  def getpriority(kind, int)
    int = Process.pid if int == 0 # Match spec

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
  end

  module_function :getpriority
end

p Process.getpriority(nil, Process.pid)
