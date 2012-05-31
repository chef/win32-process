require 'ffi'

module Process::Functions
  extend FFI::Library

  ffi_lib :kernel32

  attach_function :CloseHandle, [:ulong], :bool
  attach_function :GetPriorityClass, [:ulong], :ulong
  attach_function :OpenProcess, [:ulong, :bool, :ulong], :ulong
end
