module Process::Constants
  # Priority constants
  ABOVE_NORMAL_PRIORITY_CLASS = 0x0008000
  BELOW_NORMAL_PRIORITY_CLASS = 0x0004000
  HIGH_PRIORITY_CLASS         = 0x0000080
  IDLE_PRIORITY_CLASS         = 0x0000040
  NORMAL_PRIORITY_CLASS       = 0x0000020
  REALTIME_PRIORITY_CLASS     = 0x0000010

  # Error constants
  INVALID_HANDLE_VALUE = 0xffffffff

  # Process Access Rights
  PROCESS_SET_INFORMATION   = 0x00000200
  PROCESS_QUERY_INFORMATION = 0x00000400

  # Security
  TokenUser   = 1
  TOKEN_QUERY = 0x00000008

  # Define these for Windows
  PRIO_PROCESS = 0
  PRIO_PGRP    = 1
  PRIO_USER    = 2

  # Define these for Windows
  RLIMIT_CPU    = 0 # PerProcessUserTimeLimit
  RLIMIT_FSIZE  = 1 # Hard coded at 4TB - 64K (assumes NTFS)
  RLIMIT_AS     = 5 # ProcessMemoryLimit
  RLIMIT_RSS    = 5 # ProcessMemoryLimit
  RLIMIT_VMEM   = 5 # ProcessMemoryLimit

  # Job constants
  JOB_OBJECT_SET_ATTRIBUTES       = 0x00000002
  JOB_OBJECT_QUERY                = 0x00000004
  JOB_OBJECT_LIMIT_PROCESS_TIME   = 0x00000002
  JOB_OBJECT_LIMIT_PROCESS_MEMORY = 0x00000100
  JobObjectExtendedLimitInformation = 9
end
