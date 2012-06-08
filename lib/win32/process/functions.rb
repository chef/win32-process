if RUBY_PLATFORM == 'java'
  require 'rubygems'
  gem 'ffi'
end

require 'ffi'

module Process::Functions
  extend FFI::Library

  ffi_lib :kernel32

  attach_function :CloseHandle, [:ulong], :bool
  attach_function :GetCurrentProcess, [], :ulong
  attach_function :GetProcessAffinityMask, [:ulong, :pointer, :pointer], :bool
  attach_function :GetPriorityClass, [:ulong], :ulong
  attach_function :IsProcessInJob, [:ulong, :pointer, :pointer], :void
  attach_function :OpenProcess, [:ulong, :bool, :ulong], :ulong
  attach_function :SetHandleInformation, [:ulong, :ulong, :ulong], :bool
  attach_function :SetPriorityClass, [:ulong, :ulong], :bool

  attach_function :GetVolumeInformationA,
    [:string, :pointer, :ulong, :pointer, :pointer, :pointer, :pointer, :ulong], :bool

  attach_function :CreateProcessA,
    [:string, :buffer_in, :pointer, :pointer, :bool,
     :ulong, :buffer_in, :string, :pointer, :pointer], :bool

  attach_function :CreateProcessW,
    [:buffer_in, :buffer_in, :pointer, :pointer, :bool,
     :ulong, :buffer_in, :buffer_in, :pointer, :pointer], :bool

  attach_function :AssignProcessToJobObject, [:ulong, :ulong], :bool
  attach_function :CreateJobObjectA, [:pointer, :string], :ulong
  attach_function :OpenJobObjectA, [:ulong, :bool, :string], :ulong
  attach_function :QueryInformationJobObject, [:ulong, :int, :pointer, :ulong, :pointer], :bool
  attach_function :SetInformationJobObject, [:ulong, :int, :pointer, :ulong], :bool

  ffi_lib :advapi32

  attach_function :ConvertSidToStringSidA, [:buffer_in, :pointer], :bool
  attach_function :GetTokenInformation, [:ulong, :int, :pointer, :ulong, :pointer], :bool
  attach_function :OpenProcessToken, [:ulong, :ulong, :pointer], :bool

  attach_function :CreateProcessWithLogonW,
    [:buffer_in, :buffer_in, :buffer_in, :ulong, :buffer_in, :buffer_in,
     :ulong, :buffer_in, :buffer_in, :pointer, :pointer], :bool

  ffi_lib FFI::Library::LIBC

  attach_function :get_errno, :_get_errno, [:pointer], :int
  attach_function :get_osfhandle, :_get_osfhandle, [:int], :ulong
end
