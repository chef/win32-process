if RUBY_PLATFORM == 'java'
  require 'rubygems'
  gem 'ffi'
end

require 'ffi'

module Process::Structs
  extend FFI::Library

  private

  # sizeof(LARGE_INTEGER) == 8
  class LARGE_INTEGER < FFI::Union
    layout(:QuadPart, :long_long)
  end

  # sizeof(IO_COUNTERS) == 48
  class IO_COUNTERS < FFI::Struct
    layout(
      :ReadOperationCount, :ulong_long,
      :WriteOperationCount, :ulong_long,
      :OtherOperationCount, :ulong_long,
      :ReadTransferCount, :ulong_long,
      :WriteTransferCount, :ulong_long,
      :OtherTransferCount, :ulong_long
    )
  end

  class JOBJECT_BASIC_LIMIT_INFORMATION < FFI::Struct
    layout(
      :PerProcessUserTimeLimit, LARGE_INTEGER,
      :PerJobUserTimeLimit, LARGE_INTEGER,
      :LimitFlags, :ulong,
      :MinimumWorkingSetSize, :size_t,
      :MaximumWorkingSetSize, :size_t,
      :ActiveProcessLimit, :ulong,
      :Affinity, :pointer,
      :PriorityClass, :ulong,
      :SchedulingClass, :ulong
    )
  end

  class JOBJECT_EXTENDED_LIMIT_INFORMATION < FFI::Struct
    layout(
      :BasicLimitInformation, JOBJECT_BASIC_LIMIT_INFORMATION,
      :IoInfo, IO_COUNTERS,
      :ProcessMemoryLimit, :size_t,
      :JobMemoryLimit, :size_t,
      :PeakProcessMemoryUsed, :size_t,
      :PeakJobMemoryUsed, :size_t
    )
  end

  class SECURITY_ATTRIBUTES < FFI::Struct
    layout(
      :nLength, :ulong,
      :lpSecurityDescriptor, :pointer,
      :bInheritHandle, :bool
    )
  end

  # sizeof(STARTUPINFO) == 68
  class STARTUPINFO < FFI::Struct
    layout(
      :cb, :ulong,
      :lpReserved, :string,
      :lpDesktop, :string,
      :lpTitle, :string,
      :dwX, :ulong,
      :dwY, :ulong,
      :dwXSize, :ulong,
      :dwYSize, :ulong,
      :dwXCountChars, :ulong,
      :dwYCountChars, :ulong,
      :dwFillAttribute, :ulong,
      :dwFlags, :ulong,
      :wShowWindow, :short,
      :cbReserved2, :short,
      :lpReserved2, :pointer,
      :hStdInput, :ulong,
      :hStdOutput, :ulong,
      :hStdError, :ulong
    )
  end

  class PROCESS_INFORMATION < FFI::Struct
    layout(
      :hProcess, :ulong,
      :hThread, :ulong,
      :dwProcessId, :ulong,
      :dwThreadId, :ulong
    )
  end

  # Used by Process.create
  ProcessInfo = Struct.new("ProcessInfo",
    :process_handle,
    :thread_handle,
    :process_id,
    :thread_id
  )
end
