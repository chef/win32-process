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
end
