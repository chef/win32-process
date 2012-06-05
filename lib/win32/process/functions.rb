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
  attach_function :SetPriorityClass, [:ulong, :ulong], :bool

  attach_function :GetVolumeInformationA,
    [:string, :pointer, :ulong, :pointer, :pointer, :pointer, :pointer, :ulong], :bool

  attach_function :AssignProcessToJobObject, [:ulong, :ulong], :bool
  attach_function :CreateJobObjectA, [:pointer, :string], :ulong
  attach_function :OpenJobObjectA, [:ulong, :bool, :string], :ulong
  attach_function :QueryInformationJobObject, [:ulong, :int, :pointer, :ulong, :pointer], :bool
  attach_function :SetInformationJobObject, [:ulong, :int, :pointer, :ulong], :bool

  ffi_lib :advapi32

  attach_function :ConvertSidToStringSidA, [:buffer_in, :pointer], :bool
  attach_function :GetTokenInformation, [:ulong, :int, :pointer, :ulong, :pointer], :bool
  attach_function :OpenProcessToken, [:ulong, :ulong, :pointer], :bool

  ffi_lib FFI::Library::LIBC

  attach_function :strcpy, [:buffer_in, :ulong], :string
end
