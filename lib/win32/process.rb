require_relative 'process/functions'
require_relative 'process/constants'
require_relative 'process/structs'
require_relative 'process/helper'

module Process
  include Process::Constants
  extend Process::Functions
  extend Process::Structs
  extend Process::Constants

  # The version of the win32-process library.
  WIN32_PROCESS_VERSION = '0.7.5'

  # Disable popups. This mostly affects the Process.kill method.
  SetErrorMode(SEM_FAILCRITICALERRORS | SEM_NOGPFAULTERRORBOX)

  class << self
    # Returns whether or not the current process is part of a Job (process group).
    def job?
      pbool = FFI::MemoryPointer.new(:int)
      IsProcessInJob(GetCurrentProcess(), nil, pbool)
      pbool.read_int == 1 ? true : false
    end

    # Returns the process and system affinity mask for the given +pid+, or the
    # current process if no pid is provided. The return value is a two element
    # array, with the first containing the process affinity mask, and the second
    # containing the system affinity mask. Both are decimal values.
    #
    # A process affinity mask is a bit vector indicating the processors that a
    # process is allowed to run on. A system affinity mask is a bit vector in
    # which each bit represents the processors that are configured into a
    # system.
    #
    # Example:
    #
    #    # System has 4 processors, current process is allowed to run on all.
    #    Process.get_affinity # => [[15], [15]], where '15' is 1 + 2 + 4 + 8
    #
    #    # System has 4 processors, current process only allowed on 1 and 4.
    #    Process.get_affinity # => [[9], [15]]
    #
    # If you want to convert a decimal bit vector into an array of 0's and 1's
    # indicating the flag value of each processor, you can use something like
    # this approach:
    #
    #    mask = Process.get_affinity.first
    #    (0..mask).to_a.map{ |n| mask[n] }
    #
    def get_affinity(int = Process.pid)
      pmask = FFI::MemoryPointer.new(:ulong)
      smask = FFI::MemoryPointer.new(:ulong)

      if int == Process.pid
        unless GetProcessAffinityMask(GetCurrentProcess(), pmask, smask)
          raise SystemCallError, FFI.errno, "GetProcessAffinityMask"
        end
      else
        begin
          handle = OpenProcess(PROCESS_QUERY_INFORMATION, 0 , int)

          if handle == 0
            raise SystemCallError, FFI.errno, "OpenProcess"
          end

          unless GetProcessAffinityMask(handle, pmask, smask)
            raise SystemCallError, FFI.errno, "GetProcessAffinityMask"
          end
        ensure
          CloseHandle(handle)
        end
      end

      [pmask.read_ulong, smask.read_ulong]
    end

    remove_method :getpriority

    # Retrieves the priority class for the specified process id +int+. Unlike
    # the default implementation, lower return values do not necessarily
    # correspond to higher priority classes.
    #
    # The +kind+ parameter is ignored but required for API compatibility.
    # You can only retrieve process information, not process group or user
    # information, so it is effectively always Process::PRIO_PROCESS.
    #
    # Possible return values are:
    #
    # 32    => Process::NORMAL_PRIORITY_CLASS
    # 64    => Process::IDLE_PRIORITY_CLASS
    # 128   => Process::HIGH_PRIORITY_CLASS
    # 256   => Process::REALTIME_PRIORITY_CLASS
    # 16384 => Process::BELOW_NORMAL_PRIORITY_CLASS
    # 32768 => Process::ABOVE_NORMAL_PRIORITY_CLASS
    #
    def getpriority(kind, int)
      raise TypeError, kind unless kind.is_a?(Fixnum) # Match spec
      raise TypeError, int unless int.is_a?(Fixnum)   # Match spec
      int = Process.pid if int == 0                   # Match spec

      handle = OpenProcess(PROCESS_QUERY_INFORMATION, false, int)

      if handle == 0
        raise SystemCallError, FFI.errno, "OpenProcess"
      end

      begin
        priority = GetPriorityClass(handle)

        if priority == 0
          raise SystemCallError, FFI.errno, "GetPriorityClass"
        end
      ensure
        CloseHandle(handle)
      end

      priority
    end

    remove_method :setpriority

    # Sets the priority class for the specified process id +int+.
    #
    # The +kind+ parameter is ignored but present for API compatibility.
    # You can only retrieve process information, not process group or user
    # information, so it is effectively always Process::PRIO_PROCESS.
    #
    # Possible +int_priority+ values are:
    #
    # * Process::NORMAL_PRIORITY_CLASS
    # * Process::IDLE_PRIORITY_CLASS
    # * Process::HIGH_PRIORITY_CLASS
    # * Process::REALTIME_PRIORITY_CLASS
    # * Process::BELOW_NORMAL_PRIORITY_CLASS
    # * Process::ABOVE_NORMAL_PRIORITY_CLASS
    #
    def setpriority(kind, int, int_priority)
      raise TypeError unless kind.is_a?(Integer)          # Match spec
      raise TypeError unless int.is_a?(Integer)           # Match spec
      raise TypeError unless int_priority.is_a?(Integer)  # Match spec
      int = Process.pid if int == 0                       # Match spec

      handle = OpenProcess(PROCESS_SET_INFORMATION, false , int)

      if handle == 0
        raise SystemCallError, FFI.errno, "OpenProcess"
      end

      begin
        unless SetPriorityClass(handle, int_priority)
          raise SystemCallError, FFI.errno, "SetPriorityClass"
        end
      ensure
        CloseHandle(handle)
      end

      return 0 # Match the spec
    end

    remove_method :uid

    # Returns the uid of the current process. Specifically, it returns the
    # RID of the SID associated with the owner of the process.
    #
    # If +sid+ is set to true, then a binary sid is returned. Otherwise, a
    # numeric id is returned (the default).
    #--
    # The Process.uid method in core Ruby always returns 0 on MS Windows.
    #
    def uid(sid = false)
      token = FFI::MemoryPointer.new(:ulong)

      raise TypeError unless sid.is_a?(TrueClass) || sid.is_a?(FalseClass)

      unless OpenProcessToken(GetCurrentProcess(), TOKEN_QUERY, token)
        raise SystemCallError, FFI.errno, "OpenProcessToken"
      end

      token   = token.read_ulong
      rlength = FFI::MemoryPointer.new(:ulong)
      tuser   = 0.chr * 512

      bool = GetTokenInformation(
        token,
        TokenUser,
        tuser,
        tuser.size,
        rlength
      )

      unless bool
        raise SystemCallError, FFI.errno, "GetTokenInformation"
      end

      string_sid = tuser[FFI.type_size(:pointer)*2, (rlength.read_ulong - FFI.type_size(:pointer)*2)]

      if sid
        string_sid
      else
        psid = FFI::MemoryPointer.new(:uintptr_t)

        unless ConvertSidToStringSidA(string_sid, psid)
          raise SystemCallError, FFI.errno, "ConvertSidToStringSid"
        end

        psid.read_pointer.read_string.split('-').last.to_i
      end
    end

    remove_method :getrlimit

    # Gets the resource limit of the current process. Only a limited number
    # of flags are supported.
    #
    # Process::RLIMIT_CPU
    # Process::RLIMIT_FSIZE
    # Process::RLIMIT_AS
    # Process::RLIMIT_RSS
    # Process::RLIMIT_VMEM
    #
    # The Process:RLIMIT_AS, Process::RLIMIT_RSS and Process::VMEM constants
    # all refer to the Process memory limit. The Process::RLIMIT_CPU constant
    # refers to the per process user time limit. The Process::RLIMIT_FSIZE
    # constant is hard coded to the maximum file size on an NTFS filesystem,
    # approximately 4TB (or 4GB if not NTFS).
    #
    # While a two element array is returned in order to comply with the spec,
    # there is no separate hard and soft limit. The values will always be the
    # same.
    #
    # If [0,0] is returned then it means no limit has been set.
    #
    # Example:
    #
    #   Process.getrlimit(Process::RLIMIT_VMEM) # => [0, 0]
    #--
    # NOTE: Both the getrlimit and setrlimit method use an at_exit handler
    # to close a job handle. This is necessary because simply calling it
    # at the end of the block, while marking it for closure, would also make
    # it unavailable within the same process again since it would no longer
    # be associated with the job. In other words, trying to call it more than
    # once within the same program would fail.
    #
    def getrlimit(resource)
      if resource == RLIMIT_FSIZE
        if volume_type == 'NTFS'
          return ((1024**4) * 4) - (1024 * 64) # ~ 4TB
        else
          return (1024**3) * 4 # 4 GB
        end
      end

      handle = nil
      in_job = Process.job?

      # Put the current process in a job if it's not already in one
      if in_job && defined?(@win32_process_job_name)
        handle = OpenJobObjectA(JOB_OBJECT_QUERY, true, @win32_process_job_name)
        raise SystemCallError, FFI.errno, "OpenJobObject" if handle == 0
      else
        @win32_process_job_name = 'ruby_' + Process.pid.to_s
        handle = CreateJobObjectA(nil, @win32_process_job_name)
        raise SystemCallError, FFI.errno, "CreateJobObject" if handle == 0
      end

      begin
        unless in_job
          unless AssignProcessToJobObject(handle, GetCurrentProcess())
            raise Error, get_last_error
          end
        end

        ptr = JOBJECT_EXTENDED_LIMIT_INFORMATION.new
        val = nil

        # Set the LimitFlags member of the struct
        case resource
          when RLIMIT_CPU
            ptr[:BasicLimitInformation][:LimitFlags] = JOB_OBJECT_LIMIT_PROCESS_TIME
          when RLIMIT_AS, RLIMIT_VMEM, RLIMIT_RSS
            ptr[:BasicLimitInformation][:LimitFlags] = JOB_OBJECT_LIMIT_PROCESS_MEMORY
          else
            raise ArgumentError, "unsupported resource type: '#{resource}'"
        end

        bool = QueryInformationJobObject(
          handle,
          JobObjectExtendedLimitInformation,
          ptr,
          ptr.size,
          nil
        )

        unless bool
          raise SystemCallError, FFI.errno, "QueryInformationJobObject"
        end

        case resource
          when Process::RLIMIT_CPU
            val = ptr[:BasicLimitInformation][:PerProcessUserTimeLimit][:QuadPart]
          when RLIMIT_AS, RLIMIT_VMEM, RLIMIT_RSS
            val = ptr[:ProcessMemoryLimit]
        end

      ensure
        at_exit{ CloseHandle(handle) if handle }
      end

      [val, val]
    end

    remove_method :setrlimit

    # Sets the resource limit of the current process. Only a limited number
    # of flags are supported.
    #
    # Process::RLIMIT_CPU
    # Process::RLIMIT_AS
    # Process::RLIMIT_RSS
    # Process::RLIMIT_VMEM
    #
    # The Process:RLIMIT_AS, Process::RLIMIT_RSS and Process::VMEM constants
    # all refer to the Process memory limit. The Process::RLIMIT_CPU constant
    # refers to the per process user time limit.
    #
    # The +max_limit+ parameter is provided for interface compatibility only.
    # It is always set to the current_limit value.
    #
    # Example:
    #
    #   Process.setrlimit(Process::RLIMIT_VMEM, 1024 * 4) # => nil
    #   Process.getrlimit(Process::RLIMIT_VMEM) # => [4096, 4096]
    #
    # WARNING: Exceeding the limit you set with this method could segfault
    # the interpreter. Consider this method experimental.
    #
    def setrlimit(resource, current_limit, max_limit = nil)
      max_limit = current_limit

      handle = nil
      in_job = Process.job?

      unless [RLIMIT_AS, RLIMIT_VMEM, RLIMIT_RSS, RLIMIT_CPU].include?(resource)
        raise ArgumentError, "unsupported resource type: '#{resource}'"
      end

      # Put the current process in a job if it's not already in one
      if in_job && defined? @win32_process_job_name
        handle = OpenJobObjectA(JOB_OBJECT_SET_ATTRIBUTES, true, @win32_process_job_name)
        raise SystemCallError, FFI.errno, "OpenJobObject" if handle == 0
      else
        @win32_process_job_name = 'ruby_' + Process.pid.to_s
        handle = CreateJobObjectA(nil, @win32_process_job_name)
        raise SystemCallError, FFI.errno, "CreateJobObject" if handle == 0
      end

      begin
        unless in_job
          unless AssignProcessToJobObject(handle, GetCurrentProcess())
            raise SystemCallError, FFI.errno, "AssignProcessToJobObject"
          end
        end

        ptr = JOBJECT_EXTENDED_LIMIT_INFORMATION.new

        # Set the LimitFlags and relevant members of the struct
        if resource == RLIMIT_CPU
          ptr[:BasicLimitInformation][:LimitFlags] = JOB_OBJECT_LIMIT_PROCESS_TIME
          ptr[:BasicLimitInformation][:PerProcessUserTimeLimit][:QuadPart] = max_limit
        else
          ptr[:BasicLimitInformation][:LimitFlags] = JOB_OBJECT_LIMIT_PROCESS_MEMORY
          ptr[:ProcessMemoryLimit] = max_limit
        end

        bool = SetInformationJobObject(
          handle,
          JobObjectExtendedLimitInformation,
          ptr,
          ptr.size
        )

        unless bool
          raise SystemCallError, FFI.errno, "SetInformationJobObject"
        end
      ensure
        at_exit{ CloseHandle(handle) if handle }
      end
    end

    # Process.create(key => value, ...) => ProcessInfo
    #
    # This is a wrapper for the CreateProcess() function. It executes a process,
    # returning a ProcessInfo struct. It accepts a hash as an argument.
    # There are several primary keys:
    #
    # * command_line     (this or app_name must be present)
    # * app_name         (default: nil)
    # * inherit          (default: false)
    # * process_inherit  (default: false)
    # * thread_inherit   (default: false)
    # * creation_flags   (default: 0)
    # * cwd              (default: Dir.pwd)
    # * startup_info     (default: nil)
    # * environment      (default: nil)
    # * close_handles    (default: true)
    # * with_logon       (default: nil)
    # * domain           (default: nil)
    # * password         (default: nil, mandatory if with_logon)
    #
    # Of these, the 'command_line' or 'app_name' must be specified or an
    # error is raised. Both may be set individually, but 'command_line' should
    # be preferred if only one of them is set because it does not (necessarily)
    # require an explicit path or extension to work.
    #
    # The 'domain' and 'password' options are only relevent in the context
    # of 'with_logon'. If 'with_logon' is set, then the 'password' option is
    # mandatory.
    #
    # The startup_info key takes a hash. Its keys are attributes that are
    # part of the StartupInfo struct, and are generally only meaningful for
    # GUI or console processes. See the documentation on CreateProcess()
    # and the StartupInfo struct on MSDN for more information.
    #
    # * desktop
    # * title
    # * x
    # * y
    # * x_size
    # * y_size
    # * x_count_chars
    # * y_count_chars
    # * fill_attribute
    # * sw_flags
    # * startf_flags
    # * stdin
    # * stdout
    # * stderr
    #
    # Note that the 'stdin', 'stdout' and 'stderr' options can be either Ruby
    # IO objects or file descriptors (i.e. a fileno). However, StringIO objects
    # are not currently supported. Unfortunately, setting these is not currently
    # an option for JRuby.
    #
    # If 'stdin', 'stdout' or 'stderr' are specified, then the +inherit+ value
    # is automatically set to true and the Process::STARTF_USESTDHANDLES flag is
    # automatically OR'd to the +startf_flags+ value.
    #
    # The ProcessInfo struct contains the following members:
    #
    # * process_handle - The handle to the newly created process.
    # * thread_handle  - The handle to the primary thread of the process.
    # * process_id     - Process ID.
    # * thread_id      - Thread ID.
    #
    # If the 'close_handles' option is set to true (the default) then the
    # process_handle and the thread_handle are automatically closed for you
    # before the ProcessInfo struct is returned.
    #
    # If the 'with_logon' option is set, then the process runs the specified
    # executable file in the security context of the specified credentials.
    #
    # To simulate Process.wait you can use this approach:
    #
    #   sleep 0.1 while !Process.get_exitcode(info.process_id)
    #
    # If you really to use Process.wait, then you should use the
    # Process.spawn method instead of Process.create where possible.
    #
    def create(args)
      unless args.kind_of?(Hash)
        raise TypeError, 'hash keyword arguments expected'
      end

      valid_keys = %w[
        app_name command_line inherit creation_flags cwd environment
        startup_info thread_inherit process_inherit close_handles with_logon
        domain password
      ]

      valid_si_keys = %w[
        startf_flags desktop title x y x_size y_size x_count_chars
        y_count_chars fill_attribute sw_flags stdin stdout stderr
      ]

      # Set default values
      hash = {
        'app_name'       => nil,
        'creation_flags' => 0,
        'close_handles'  => true
      }

      # Validate the keys, and convert symbols and case to lowercase strings.
      args.each{ |key, val|
        key = key.to_s.downcase
        unless valid_keys.include?(key)
          raise ArgumentError, "invalid key '#{key}'"
        end
        hash[key] = val
      }

      si_hash = {}

      # If the startup_info key is present, validate its subkeys
      if hash['startup_info']
        hash['startup_info'].each{ |key, val|
          key = key.to_s.downcase
          unless valid_si_keys.include?(key)
            raise ArgumentError, "invalid startup_info key '#{key}'"
          end
          si_hash[key] = val
        }
      end

      # The +command_line+ key is mandatory unless the +app_name+ key
      # is specified.
      unless hash['command_line']
        if hash['app_name']
          hash['command_line'] = hash['app_name']
          hash['app_name'] = nil
        else
          raise ArgumentError, 'command_line or app_name must be specified'
        end
      end

      env = nil

      # The env string should be passed as a string of ';' separated paths.
      if hash['environment']
        env = hash['environment']

        unless env.respond_to?(:join)
          env = hash['environment'].split(File::PATH_SEPARATOR)
        end

        env = env.map{ |e| e + 0.chr }.join('') + 0.chr
        env.to_wide_string! if hash['with_logon']
      end

      # Process SECURITY_ATTRIBUTE structure
      process_security = nil

      if hash['process_inherit']
        process_security = SECURITY_ATTRIBUTES.new
        process_security[:nLength] = 12
        process_security[:bInheritHandle] = true
      end

      # Thread SECURITY_ATTRIBUTE structure
      thread_security = nil

      if hash['thread_inherit']
        thread_security = SECURITY_ATTRIBUTES.new
        thread_security[:nLength] = 12
        thread_security[:bInheritHandle] = true
      end

      # Automatically handle stdin, stdout and stderr as either IO objects
      # or file descriptors. This won't work for StringIO, however. It also
      # will not work on JRuby because of the way it handles internal file
      # descriptors.
      #
      ['stdin', 'stdout', 'stderr'].each{ |io|
        if si_hash[io]
          if si_hash[io].respond_to?(:fileno)
            handle = get_osfhandle(si_hash[io].fileno)
          else
            handle = get_osfhandle(si_hash[io])
          end

          if handle == INVALID_HANDLE_VALUE
            ptr = FFI::MemoryPointer.new(:int)

            if windows_version >= 6 && get_errno(ptr) == 0
              errno = ptr.read_int
            else
              errno = FFI.errno
            end

            raise SystemCallError.new("get_osfhandle", errno)
          end

          # Most implementations of Ruby on Windows create inheritable
          # handles by default, but some do not. RF bug #26988.
          bool = SetHandleInformation(
            handle,
            HANDLE_FLAG_INHERIT,
            HANDLE_FLAG_INHERIT
          )

          raise SystemCallError.new("SetHandleInformation", FFI.errno) unless bool

          si_hash[io] = handle
          si_hash['startf_flags'] ||= 0
          si_hash['startf_flags'] |= STARTF_USESTDHANDLES
          hash['inherit'] = true
        end
      }

      procinfo  = PROCESS_INFORMATION.new
      startinfo = STARTUPINFO.new

      unless si_hash.empty?
        startinfo[:cb]              = startinfo.size
        startinfo[:lpDesktop]       = si_hash['desktop'] if si_hash['desktop']
        startinfo[:lpTitle]         = si_hash['title'] if si_hash['title']
        startinfo[:dwX]             = si_hash['x'] if si_hash['x']
        startinfo[:dwY]             = si_hash['y'] if si_hash['y']
        startinfo[:dwXSize]         = si_hash['x_size'] if si_hash['x_size']
        startinfo[:dwYSize]         = si_hash['y_size'] if si_hash['y_size']
        startinfo[:dwXCountChars]   = si_hash['x_count_chars'] if si_hash['x_count_chars']
        startinfo[:dwYCountChars]   = si_hash['y_count_chars'] if si_hash['y_count_chars']
        startinfo[:dwFillAttribute] = si_hash['fill_attribute'] if si_hash['fill_attribute']
        startinfo[:dwFlags]         = si_hash['startf_flags'] if si_hash['startf_flags']
        startinfo[:wShowWindow]     = si_hash['sw_flags'] if si_hash['sw_flags']
        startinfo[:cbReserved2]     = 0
        startinfo[:hStdInput]       = si_hash['stdin'] if si_hash['stdin']
        startinfo[:hStdOutput]      = si_hash['stdout'] if si_hash['stdout']
        startinfo[:hStdError]       = si_hash['stderr'] if si_hash['stderr']
      end

      app = nil
      cmd = nil

      # Convert strings to wide character strings if present
      if hash['app_name']
        app = hash['app_name'].to_wide_string
      end

      if hash['command_line']
        cmd = hash['command_line'].to_wide_string
      end

      if hash['cwd']
        cwd = hash['cwd'].to_wide_string
      end

      if hash['with_logon']
        logon = hash['with_logon'].to_wide_string

        if hash['password']
          passwd = hash['password'].to_wide_string
        else
          raise ArgumentError, 'password must be specified if with_logon is used'
        end

        if hash['domain']
          domain = hash['domain'].to_wide_string
        end

        hash['creation_flags'] |= CREATE_UNICODE_ENVIRONMENT

        bool = CreateProcessWithLogonW(
          logon,                  # User
          domain,                 # Domain
          passwd,                 # Password
          LOGON_WITH_PROFILE,     # Logon flags
          app,                    # App name
          cmd,                    # Command line
          hash['creation_flags'], # Creation flags
          env,                    # Environment
          cwd,                    # Working directory
          startinfo,              # Startup Info
          procinfo                # Process Info
        )

        unless bool
          raise SystemCallError.new("CreateProcessWithLogonW", FFI.errno)
        end
      else
        inherit  = hash['inherit'] || false

        bool = CreateProcessW(
          app,                    # App name
          cmd,                    # Command line
          process_security,       # Process attributes
          thread_security,        # Thread attributes
          inherit,                # Inherit handles?
          hash['creation_flags'], # Creation flags
          env,                    # Environment
          cwd,                    # Working directory
          startinfo,              # Startup Info
          procinfo                # Process Info
        )

        unless bool
          raise SystemCallError.new("CreateProcess", FFI.errno)
        end
      end

      # Automatically close the process and thread handles in the
      # PROCESS_INFORMATION struct unless explicitly told not to.
      if hash['close_handles']
        CloseHandle(procinfo[:hProcess])
        CloseHandle(procinfo[:hThread])
      end

      ProcessInfo.new(
        procinfo[:hProcess],
        procinfo[:hThread],
        procinfo[:dwProcessId],
        procinfo[:dwThreadId]
      )
    end

    remove_method :kill

    # Kill a given process with a specific signal. This overrides the default
    # implementation of Process.kill. The differences mainly reside in the way
    # it kills processes, but this version also gives you finer control over
    # behavior.
    #
    # Internally, signals 2 and 3 will generate a console control event, using
    # a ctrl-c or ctrl-break event, respectively. Signal 9 terminates the
    # process harshly, given that process no chance to do any internal cleanup.
    # Signals 1 and 4-8 kill the process more nicely, giving the process a
    # chance to do internal cleanup before being killed. Signal 0 behaves the
    # same as the default implementation.
    #
    # When using signals 1 or 4-8 you may specify additional options that
    # allow finer control over how that process is killed and how your program
    # behaves.
    #
    # Possible options for signals 1 and 4-8.
    #
    # :exit_proc  => The name of the exit function called when signal 1 or 4-8
    #                is used. The default is 'ExitProcess'.
    #
    # :dll_module => The name of the .dll (or .exe) that contains :exit_proc.
    #                The default is 'kernel32'.
    #
    # :wait_time  => The time, in milliseconds, to wait for the process to
    #                actually die. The default is 5ms. If you specify 0 here
    #                then the process does not wait if the process is not
    #                signaled and instead returns immediately. Alternatively,
    #                you may specify Process::INFINITE, and your code will
    #                block until the process is actually signaled.
    #
    # Example:
    #
    #   Process.kill(1, 12345, :exit_proc => 'ExitProcess', :module => 'kernel32')
    #
    def kill(signal, *pids)
      raise SecurityError if $SAFE && $SAFE >= 2 # Match the spec

      # Match the spec, require at least 2 arguments
      if pids.length == 0
        raise ArgumentError, "wrong number of arguments (1 for at least 2)"
      end

      # Match the spec, signal may not be less than zero if numeric
      if signal.is_a?(Numeric) && signal < 0 # EINVAL
        raise SystemCallError.new(22)
      end

      # Match the spec, signal must be a numeric, string or symbol
      unless signal.is_a?(String) || signal.is_a?(Numeric) || signal.is_a?(Symbol)
        raise ArgumentError, "bad signal type #{signal.class}"
      end

      # Match the spec, making an exception for BRK/SIGBRK, if the signal name is invalid.
      # Older versions of JRuby did not include KILL, so we've made an explicit exception
      # for that here, too.
      if signal.is_a?(String) || signal.is_a?(Symbol)
        signal = signal.to_s.sub('SIG', '')
        unless Signal.list.keys.include?(signal) || ['KILL', 'BRK'].include?(signal)
          raise ArgumentError, "unsupported name '#{signal}'"
        end
      end

      # If the last argument is a hash, pop it and assume it's a hash of options
      if pids.last.is_a?(Hash)
        hash = pids.pop
        opts = {}

        valid = %w[exit_proc dll_module wait_time]

        hash.each{ |k,v|
          k = k.to_s.downcase
          unless valid.include?(k)
            raise ArgumentError, "invalid option '#{k}'"
          end
          opts[k] = v
        }

        exit_proc  = opts['exit_proc']  || 'ExitProcess'
        dll_module = opts['dll_module'] || 'kernel32'
        wait_time  = opts['wait_time']  || 5
      else
        wait_time  = 5
        exit_proc  = 'ExitProcess'
        dll_module = 'kernel32'
      end

      count = 0

      pids.each{ |pid|
        raise TypeError unless pid.is_a?(Numeric) # Match spec, pid must be a number
        raise SystemCallError.new(22) if pid < 0  # Match spec, EINVAL if pid less than zero

        sigint = [Signal.list['INT'], 'INT', 'SIGINT', :INT, :SIGINT, 2]

        # Match the spec
        if pid == 0 && !sigint.include?(signal)
          raise SystemCallError.new(22)
        end

        if signal == 0
          access = PROCESS_QUERY_INFORMATION | PROCESS_VM_READ
        elsif signal == 9
          access = PROCESS_TERMINATE
        else
          access = PROCESS_ALL_ACCESS
        end

        begin
          handle = OpenProcess(access, false, pid)

          if signal != 0 && handle == 0
            raise SystemCallError, FFI.errno, "OpenProcess"
          end

          case signal
            when 0
              if handle != 0
                count += 1
              else
                if FFI.errno == ERROR_ACCESS_DENIED
                  count += 1
                else
                  raise SystemCallError.new(3) # ESRCH
                end
              end
            when Signal.list['INT'], 'INT', 'SIGINT', :INT, :SIGINT, 2
              if GenerateConsoleCtrlEvent(CTRL_C_EVENT, pid)
                count += 1
              else
                raise SystemCallError.new("GenerateConsoleCtrlEvent", FFI.errno)
              end
            when Signal.list['BRK'], 'BRK', 'SIGBRK', :BRK, :SIGBRK, 3
              if GenerateConsoleCtrlEvent(CTRL_BREAK_EVENT, pid)
                count += 1
              else
                raise SystemCallError.new("GenerateConsoleCtrlEvent", FFI.errno)
              end
            when Signal.list['KILL'], 'KILL', 'SIGKILL', :KILL, :SIGKILL, 9
              if TerminateProcess(handle, pid)
                count += 1
              else
                raise SystemCallError.new("TerminateProcess", FFI.errno)
              end
            else
              thread_id = FFI::MemoryPointer.new(:ulong)

              mod = GetModuleHandle(dll_module)

              if mod == 0
                raise SystemCallError.new("GetModuleHandle: '#{dll_module}'", FFI.errno)
              end

              proc_addr = GetProcAddress(mod, exit_proc)

              if proc_addr == 0
                raise SystemCallError.new("GetProcAddress: '#{exit_proc}'", FFI.errno)
              end

              thread = CreateRemoteThread(handle, nil, 0, proc_addr, nil, 0, thread_id)

              if thread > 0
                WaitForSingleObject(thread, wait_time)
                count += 1
              else
                raise SystemCallError.new("CreateRemoteThread", FFI.errno)
              end
          end
        ensure
          CloseHandle(handle) if handle
        end
      }

      count
    end

    # Returns the exitcode of the process with given +pid+ or nil if the process
    # is still running. Note that the process doesn't have to be a child process.
    #
    # This method is very handy for finding out if a process started with Process.create
    # is still running. The usual way of calling Process.wait doesn't work when
    # the process isn't recognized as a child process (ECHILD). This happens for example
    # when stdin, stdout or stderr are set to custom values.
    #
    def get_exitcode(pid)
      handle = OpenProcess(PROCESS_QUERY_INFORMATION, false, pid)

      if handle == INVALID_HANDLE_VALUE
        raise SystemCallError.new("OpenProcess", FFI.errno)
      end

      begin
        buf = FFI::MemoryPointer.new(:ulong, 1)

        unless GetExitCodeProcess(handle, buf)
          raise SystemCallError.new("GetExitCodeProcess", FFI.errno)
        end
      ensure
        CloseHandle(handle)
      end

      exitcode = buf.read_int

      if exitcode == STILL_ACTIVE
        nil
      else
        exitcode
      end
    end
  end

  class << self
    private

    # Private method that returns the volume type, e.g. "NTFS", etc.
    def volume_type
      buf = FFI::MemoryPointer.new(:char, 32)
      bool = GetVolumeInformationA(nil, nil, 0, nil, nil, nil, buf, buf.size)
      bool ? buf.read_string : nil
    end

    # Private method that returns the Windows major version number.
    def windows_version
      ver = OSVERSIONINFO.new
      ver[:dwOSVersionInfoSize] = ver.size

      unless GetVersionExA(ver)
        raise SystemCallError.new("GetVersionEx", FFI.errno)
      end

      ver[:dwMajorVersion]
    end
  end
end
