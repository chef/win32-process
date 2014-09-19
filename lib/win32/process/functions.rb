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

  typedef :ulong, :dword
  typedef :uintptr_t, :handle
  typedef :uintptr_t, :hwnd
  typedef :uintptr_t, :hmodule
  typedef :long, :ntstatus

  ffi_lib :kernel32

  attach_pfunc :CloseHandle, [:handle], :bool
  attach_pfunc :GenerateConsoleCtrlEvent, [:dword, :dword], :bool
  attach_pfunc :GetCurrentProcess, [], :handle
  attach_pfunc :GetModuleHandle, :GetModuleHandleA, [:string], :hmodule
  attach_pfunc :GetProcessAffinityMask, [:handle, :pointer, :pointer], :bool
  attach_pfunc :GetPriorityClass, [:handle], :dword
  attach_pfunc :GetProcAddress, [:hmodule, :string], :pointer
  attach_pfunc :GetVersionExA, [:pointer], :bool
  attach_pfunc :IsProcessInJob, [:handle, :pointer, :pointer], :bool # 2nd arg optional
  attach_pfunc :OpenProcess, [:dword, :bool, :dword], :handle
  attach_pfunc :SetHandleInformation, [:handle, :dword, :dword], :bool
  attach_pfunc :SetErrorMode, [:uint], :uint
  attach_pfunc :SetPriorityClass, [:handle, :dword], :bool
  attach_pfunc :TerminateProcess, [:handle, :uint], :bool
  attach_pfunc :WaitForSingleObject, [:handle, :dword], :dword

  attach_pfunc :CreateRemoteThread,
    [:handle, :pointer, :size_t, :pointer, :pointer, :dword, :pointer], :handle

  attach_pfunc :GetVolumeInformationA,
    [:string, :pointer, :dword, :pointer, :pointer, :pointer, :pointer, :dword], :bool

  attach_pfunc :CreateProcessW,
    [:buffer_in, :buffer_in, :pointer, :pointer, :bool,
     :dword, :buffer_in, :buffer_in, :pointer, :pointer], :bool

  attach_pfunc :AssignProcessToJobObject, [:handle, :handle], :bool
  attach_pfunc :CreateJobObjectA, [:pointer, :string], :handle
  attach_pfunc :OpenJobObjectA, [:dword, :bool, :string], :handle
  attach_pfunc :QueryInformationJobObject, [:handle, :int, :pointer, :dword, :pointer], :bool
  attach_pfunc :SetInformationJobObject, [:handle, :int, :pointer, :dword], :bool
  attach_pfunc :GetExitCodeProcess, [:handle, :pointer], :bool

  ffi_lib :advapi32

  attach_pfunc :ConvertSidToStringSidA, [:buffer_in, :pointer], :bool
  attach_pfunc :GetTokenInformation, [:handle, :int, :pointer, :dword, :pointer], :bool
  attach_pfunc :OpenProcessToken, [:handle, :dword, :pointer], :bool

  attach_pfunc :CreateProcessWithLogonW,
    [:buffer_in, :buffer_in, :buffer_in, :dword, :buffer_in, :buffer_in,
     :dword, :buffer_in, :buffer_in, :pointer, :pointer], :bool

  ffi_lib FFI::Library::LIBC

  attach_pfunc :get_osfhandle, :_get_osfhandle, [:int], :intptr_t
  attach_pfunc :setjmp, :_setjmp, [:pointer], :int
  attach_pfunc :longjmp, [:pointer, :int], :void

  begin
    attach_pfunc :get_errno, :_get_errno, [:pointer], :int
  rescue FFI::NotFoundError
    # Do nothing, Windows XP or earlier.
  end

  ffi_lib :ntdll

  attach_pfunc :ZwClose, [:handle], :ntstatus
  attach_pfunc :ZwCreateProcess, [:pointer, :ulong, :pointer, :handle, :bool, :handle, :handle, :handle], :ntstatus
  attach_pfunc :ZwCreateThread, [:pointer, :ulong, :pointer, :handle, :pointer, :pointer, :pointer, :bool], :ntstatus
  attach_pfunc :ZwGetContextThread, [:handle, :pointer], :ntstatus
  attach_pfunc :ZwQueryVirtualMemory, [:handle, :uint64, :int, :pointer, :ulong, :pointer], :ntstatus
  attach_pfunc :ZwQueryInformationThread, [:handle, :int, :pointer, :ulong, :pointer], :ntstatus
  attach_pfunc :ZwResumeThread, [:handle, :pointer], :ntstatus
  attach_pfunc :ZwWriteVirtualMemory, [:handle, :uint64, :pointer, :ulong, :pointer], :ntstatus
end
