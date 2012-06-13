if RUBY_PLATFORM == 'java'
  require 'rubygems'
  gem 'ffi'
end

require 'ffi'

module Process::Functions
  module FFI::Library
    # Wrapper method for attach_function + private
    def attach_pfunc(*args)
      attach_function(*args)
      private args[0]
    end
  end

  extend FFI::Library

  ffi_lib :kernel32

  attach_pfunc :CloseHandle, [:ulong], :bool
  attach_pfunc :GenerateConsoleCtrlEvent, [:ulong, :ulong], :bool
  attach_pfunc :GetCurrentProcess, [], :ulong
  attach_pfunc :GetModuleHandle, :GetModuleHandleA, [:string], :ulong
  attach_pfunc :GetProcessAffinityMask, [:ulong, :pointer, :pointer], :bool
  attach_pfunc :GetPriorityClass, [:ulong], :ulong
  attach_pfunc :GetProcAddress, [:ulong, :string], :ulong
  attach_pfunc :IsProcessInJob, [:ulong, :pointer, :pointer], :void
  attach_pfunc :OpenProcess, [:ulong, :bool, :ulong], :ulong
  attach_pfunc :SetHandleInformation, [:ulong, :ulong, :ulong], :bool
  attach_pfunc :SetErrorMode, [:uint], :uint
  attach_pfunc :SetPriorityClass, [:ulong, :ulong], :bool
  attach_pfunc :TerminateProcess, [:ulong, :uint], :bool
  attach_pfunc :WaitForSingleObject, [:ulong, :ulong], :ulong

  attach_pfunc :CreateRemoteThread,
    [:ulong, :pointer, :size_t, :ulong, :pointer, :ulong, :pointer], :ulong

  attach_pfunc :GetVolumeInformationA,
    [:string, :pointer, :ulong, :pointer, :pointer, :pointer, :pointer, :ulong], :bool

  attach_pfunc :CreateProcessW,
    [:buffer_in, :buffer_in, :pointer, :pointer, :bool,
     :ulong, :buffer_in, :buffer_in, :pointer, :pointer], :bool

  attach_pfunc :AssignProcessToJobObject, [:ulong, :ulong], :bool
  attach_pfunc :CreateJobObjectA, [:pointer, :string], :ulong
  attach_pfunc :OpenJobObjectA, [:ulong, :bool, :string], :ulong
  attach_pfunc :QueryInformationJobObject, [:ulong, :int, :pointer, :ulong, :pointer], :bool
  attach_pfunc :SetInformationJobObject, [:ulong, :int, :pointer, :ulong], :bool

  ffi_lib :advapi32

  attach_pfunc :ConvertSidToStringSidA, [:buffer_in, :pointer], :bool
  attach_pfunc :GetTokenInformation, [:ulong, :int, :pointer, :ulong, :pointer], :bool
  attach_pfunc :OpenProcessToken, [:ulong, :ulong, :pointer], :bool

  attach_pfunc :CreateProcessWithLogonW,
    [:buffer_in, :buffer_in, :buffer_in, :ulong, :buffer_in, :buffer_in,
     :ulong, :buffer_in, :buffer_in, :pointer, :pointer], :bool

  ffi_lib FFI::Library::LIBC

  attach_pfunc :get_errno, :_get_errno, [:pointer], :int
  attach_pfunc :get_osfhandle, :_get_osfhandle, [:int], :ulong
end
