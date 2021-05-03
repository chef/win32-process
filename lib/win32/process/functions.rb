if RUBY_PLATFORM == "java"
  require "rubygems" unless defined?(Gem)
  gem "ffi"
end

require "ffi" unless defined?(FFI)

module Process::Functions
  module FFI::Library
    unless instance_methods.include?(:attach_pfunc)
      # Wrapper method for attach_function + private
      def attach_pfunc(*args)
        attach_function(*args)
        private args[0]
      end
    end
  end

  extend FFI::Library

  typedef :ulong, :dword
  typedef :uintptr_t, :handle
  typedef :uintptr_t, :hwnd
  typedef :uintptr_t, :hmodule

  ffi_lib :kernel32

  attach_pfunc :CloseHandle, [:handle], :bool
  attach_pfunc :CreateToolhelp32Snapshot, %i{dword dword}, :handle
  attach_pfunc :GenerateConsoleCtrlEvent, %i{dword dword}, :bool
  attach_pfunc :GetCurrentProcess, [], :handle
  attach_pfunc :GetModuleHandle, :GetModuleHandleA, [:string], :hmodule
  attach_pfunc :GetProcessAffinityMask, %i{handle pointer pointer}, :bool
  attach_pfunc :GetPriorityClass, [:handle], :dword
  attach_pfunc :GetProcAddress, %i{hmodule string}, :pointer
  attach_pfunc :GetVersionExA, [:pointer], :bool
  attach_pfunc :Heap32ListFirst, %i{handle pointer}, :bool
  attach_pfunc :Heap32ListNext, %i{handle pointer}, :bool
  attach_pfunc :Heap32First, %i{pointer dword uintptr_t}, :bool
  attach_pfunc :Heap32Next, [:pointer], :bool
  attach_pfunc :Module32First, %i{handle pointer}, :bool
  attach_pfunc :Module32Next, %i{handle pointer}, :bool
  attach_pfunc :IsProcessInJob, %i{handle pointer pointer}, :bool # 2nd arg optional
  attach_pfunc :OpenProcess, %i{dword int dword}, :handle
  attach_pfunc :Process32First, %i{handle pointer}, :bool
  attach_pfunc :Process32Next, %i{handle pointer}, :bool
  attach_pfunc :SetHandleInformation, %i{handle dword dword}, :bool
  attach_pfunc :SetErrorMode, [:uint], :uint
  attach_pfunc :SetPriorityClass, %i{handle dword}, :bool
  attach_pfunc :TerminateProcess, %i{handle uint}, :bool
  attach_pfunc :Thread32First, %i{handle pointer}, :bool
  attach_pfunc :Thread32Next, %i{handle pointer}, :bool
  attach_pfunc :WaitForSingleObject, %i{handle dword}, :dword

  attach_pfunc :CreateRemoteThread,
    %i{handle pointer size_t pointer pointer dword pointer}, :handle

  attach_pfunc :GetVolumeInformationA,
    %i{string pointer dword pointer pointer pointer pointer dword}, :bool

  attach_pfunc :CreateProcessW,
    %i{buffer_in buffer_inout pointer pointer int
     dword buffer_in buffer_in pointer pointer}, :bool

  attach_pfunc :AssignProcessToJobObject, %i{handle handle}, :bool
  attach_pfunc :CreateJobObjectA, %i{pointer string}, :handle
  attach_pfunc :OpenJobObjectA, %i{dword int string}, :handle
  attach_pfunc :QueryInformationJobObject, %i{handle int pointer dword pointer}, :bool
  attach_pfunc :SetInformationJobObject, %i{handle int pointer dword}, :bool
  attach_pfunc :GetExitCodeProcess, %i{handle pointer}, :bool

  ffi_lib :advapi32

  attach_pfunc :ConvertSidToStringSidA, %i{buffer_in pointer}, :bool
  attach_pfunc :GetTokenInformation, %i{handle int pointer dword pointer}, :bool
  attach_pfunc :OpenProcessToken, %i{handle dword pointer}, :bool

  attach_pfunc :CreateProcessWithLogonW,
    %i{buffer_in buffer_in buffer_in dword buffer_in buffer_inout
     dword buffer_in buffer_in pointer pointer}, :bool

  ffi_lib FFI::Library::LIBC

  attach_pfunc :get_osfhandle, :_get_osfhandle, [:int], :intptr_t

  begin
    attach_pfunc :get_errno, :_get_errno, [:pointer], :int
  rescue FFI::NotFoundError
    # Do nothing, Windows XP or earlier.
  end
end
