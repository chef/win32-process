if RUBY_PLATFORM == 'java'
  require 'rubygems'
  gem 'ffi'
end

require 'ffi'

module Process::Structs
  extend FFI::Library

  typedef :ulong, :dword
  typedef :uintptr_t, :handle
  typedef :short, :word
  typedef :uint64, :dword64
  typedef :uchar, :byte

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

  class OBJECT_ATTRIBUTES < FFI::Struct
    layout(
      :Length, :ulong,
      :RootDirectory, :handle,
      :ObjectName, :pointer,
      :Attributes, :ulong,
      :SecurityDescriptor, :pointer,
      :SecurityQualityOfService, :pointer
    )
  end

  # Size should be 16.
  class M128A < FFI::Struct
    layout(:Low, :ulong_long, :High, :long_long)
    align 16
  end

  class DummyStruct < FFI::Struct
    layout(
      :Header, [M128A, 2],
      :Legacy, [M128A, 8],
      :Xmm0, M128A,
      :Xmm1, M128A,
      :Xmm2, M128A,
      :Xmm3, M128A,
      :Xmm4, M128A,
      :Xmm5, M128A,
      :Xmm6, M128A,
      :Xmm7, M128A,
      :Xmm8, M128A,
      :Xmm9, M128A,
      :Xmm10, M128A,
      :Xmm11, M128A,
      :Xmm12, M128A,
      :Xmm13, M128A,
      :Xmm14, M128A,
      :Xmm15, M128A
    )
  end

  # Same as XSAVE_FORMAT. Size should be 512.
  class XMM_SAVE_AREA32 < FFI::Struct
    layout(
      :ControlWord, :word,
      :StatusWord, :word,
      :TagWord, :byte,
      :Reserved1, :byte,
      :ErrorOpcode, :word,
      :ErrorOffset, :dword,
      :ErrorSelector, :word,
      :Reserved2, :word,
      :DataOffset, :dword,
      :DataSelector, :word,
      :Reserved3, :word,
      :MxCsr, :dword,
      :MxCsr_Mask, :dword,
      :FloatRegisters, [M128A, 8],

      # Might use these instead for 64-bit Ruby
      #M128A XmmRegisters[16];
      #BYTE  Reserved4[96];

      :XmmRegisters, [M128A, 8],
      :Reserved4, [:byte, 192],
      :StackControl, [:dword, 7],
      :Cr0NpxState, :dword
    )
    align 16
  end

  #class DummyUnion < FFI::Union
  #  layout(
  #    :FltSave, XMM_SAVE_AREA32,
  #    :DummyStruct, DummyStruct
  #  )
  #end

  # Size should be 716
  class CONTEXT < FFI::Struct
    layout(
      :P1Home, :dword64,
      :P2Home, :dword64,
      :P3Home, :dword64,
      :P4Home, :dword64,
      :P5Home, :dword64,
      :P6Home, :dword64,

      :ContextFlags, :dword,
      :MxCsr, :dword,

      :SegCs, :word,
      :SegDs, :word,
      :SegEs, :word,
      :SegFs, :word,
      :SegGs, :word,
      :SegSs, :word,
      :EFlags, :dword,

      :Dr0, :dword64,
      :Dr1, :dword64,
      :Dr2, :dword64,
      :Dr3, :dword64,
      :Dr6, :dword64,
      :Dr7, :dword64,

      :Rax, :dword64,
      :Rcx, :dword64,
      :Rdx, :dword64,
      :Rbx, :dword64,
      :Rsp, :dword64,
      :Rbp, :dword64,
      :Rsi, :dword64,
      :Rdi, :dword64,
      :R8, :dword64,
      :R9, :dword64,
      :R10, :dword64,
      :R11, :dword64,
      :R12, :dword64,
      :R13, :dword64,
      :R14, :dword64,
      :R15, :dword64,

      :Rip, :dword64,

      #:Dummy, DummyUnion,

      :VectorRegister, [M128A, 26],
      :VectorControl, :dword64,

      :DebugControl, :dword64,
      :LastBranchToRip, :dword64,
      :LastBranchFromRip, :dword64,
      :LastExceptionToRip, :dword64,
      :LastExceptionFromRip, :dword64
    )
    align 16
  end

  # Used by Process.create
  ProcessInfo = Struct.new("ProcessInfo",
    :process_handle,
    :thread_handle,
    :process_id,
    :thread_id
  )
end
