if RUBY_PLATFORM == "java"
  require "rubygems" unless defined?(Gem)
  gem "ffi"
end

require "ffi" unless defined?(FFI)

module Process::Structs
  extend FFI::Library

  typedef :ulong, :dword
  typedef :uintptr_t, :handle
  typedef :short, :word

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
      :LimitFlags, :dword,
      :MinimumWorkingSetSize, :size_t,
      :MaximumWorkingSetSize, :size_t,
      :ActiveProcessLimit, :dword,
      :Affinity, :pointer,
      :PriorityClass, :dword,
      :SchedulingClass, :dword
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
      :nLength, :dword,
      :lpSecurityDescriptor, :pointer,
      :bInheritHandle, :int
    )
  end

  # sizeof(STARTUPINFO) == 68
  class STARTUPINFO < FFI::Struct
    layout(
      :cb, :ulong,
      :lpReserved, :string,
      :lpDesktop, :string,
      :lpTitle, :string,
      :dwX, :dword,
      :dwY, :dword,
      :dwXSize, :dword,
      :dwYSize, :dword,
      :dwXCountChars, :dword,
      :dwYCountChars, :dword,
      :dwFillAttribute, :dword,
      :dwFlags, :dword,
      :wShowWindow, :word,
      :cbReserved2, :word,
      :lpReserved2, :pointer,
      :hStdInput, :handle,
      :hStdOutput, :handle,
      :hStdError, :handle
    )
  end

  class PROCESS_INFORMATION < FFI::Struct
    layout(
      :hProcess, :handle,
      :hThread, :handle,
      :dwProcessId, :ulong,
      :dwThreadId, :ulong
    )
  end

  class OSVERSIONINFO < FFI::Struct
    layout(
      :dwOSVersionInfoSize, :dword,
      :dwMajorVersion, :dword,
      :dwMinorVersion, :dword,
      :dwBuildNumber, :dword,
      :dwPlatformId, :dword,
      :szCSDVersion, [:char, 128]
    )
  end

  class THREADENTRY32 < FFI::Struct
    layout(
      :dwSize, :dword,
      :cntUsage, :dword,
      :th32ThreadID, :dword,
      :th32OwnerProcessID, :dword,
      :tpBasePri, :long,
      :tpDeltaPri, :long,
      :dwFlags, :dword
    )
  end

  class HEAPLIST32 < FFI::Struct
    layout(
      :dwSize, :size_t,
      :th32ProcessID, :dword,
      :th32HeapID, :uintptr_t,
      :dwFlags, :dword
    )
  end

  class HEAPENTRY32 < FFI::Struct
    layout(
      :dwSize, :size_t,
      :hHandle, :handle,
      :dwAddress, :uintptr_t,
      :dwBlockSize, :size_t,
      :dwFlags, :dword,
      :dwLockCount, :dword,
      :dwResvd, :dword,
      :th32ProcessID, :dword,
      :th32HeapID, :uintptr_t
    )
  end

  class MODULEENTRY32 < FFI::Struct
    layout(
      :dwSize, :dword,
      :th32ModuleID, :dword,
      :th32ProcessID, :dword,
      :GlblcntUsage, :dword,
      :ProccntUsage, :dword,
      :modBaseAddr, :pointer,
      :modBaseSize, :dword,
      :hModule, :handle,
      :szModule, [:char, 256],
      :szExePath, [:char, 260]
    )
  end

  class PROCESSENTRY32 < FFI::Struct
    layout(
      :dwSize, :dword,
      :cntUsage, :dword,
      :th32ProcessID, :dword,
      :th32DefaultHeapID, :uintptr_t,
      :th32ModuleID, :dword,
      :cntThreads, :dword,
      :th32ParentProcessID, :dword,
      :pcPriClassBase, :long,
      :dwFlags, :dword,
      :szExeFile, [:char, 260]
    )
  end

  # Used by Process.create

  ProcessInfo = Struct.new("ProcessInfo",
    :process_handle,
    :thread_handle,
    :process_id,
    :thread_id)

  # Used by Process.snapshot

  ThreadSnapInfo = Struct.new("ThreadSnapInfo",
    :thread_id,
    :process_id,
    :base_priority)

  HeapSnapInfo = Struct.new("HeapSnapInfo",
    :address,
    :block_size,
    :flags,
    :process_id,
    :heap_id)

  ModuleSnapInfo = Struct.new("ModuleSnapInfo",
    :process_id,
    :address,
    :module_size,
    :handle,
    :name,
    :path)

  ProcessSnapInfo = Struct.new("ProcessSnapInfo",
    :process_id,
    :threads,
    :parent_process_id,
    :priority,
    :flags,
    :path)
end
