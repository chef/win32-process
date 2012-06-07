require File.join(File.expand_path(File.dirname(__FILE__)), 'process', 'functions')
require File.join(File.expand_path(File.dirname(__FILE__)), 'process', 'constants')
require File.join(File.expand_path(File.dirname(__FILE__)), 'process', 'structs')

module Process
  include Process::Functions
  include Process::Constants

  extend Process::Functions
  extend Process::Structs
  extend Process::Constants

  WIN32_PROCESS_VERSION = '0.7.0'

  class << self

    def job?
      pbool = FFI::MemoryPointer.new(:int)
      IsProcessInJob(GetCurrentProcess(), nil, pbool)
      pbool.read_int == 1 ? true : false
    end

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

          if handle == INVALID_HANDLE_VALUE
            raise SystemCallError, FFI.errno, "OpeProcess"
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

    def getpriority(kind, int)
      raise TypeError, kind unless kind.is_a?(Fixnum) # Match spec
      raise TypeError, int unless int.is_a?(Fixnum)   # Match spec
      int = Process.pid if int == 0                   # Match spec

      handle = OpenProcess(PROCESS_QUERY_INFORMATION, false, int)

      if handle == INVALID_HANDLE_VALUE
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

    def setpriority(kind, int, int_priority)
      raise TypeError unless kind.is_a?(Integer)          # Match spec
      raise TypeError unless int.is_a?(Integer)           # Match spec
      raise TypeError unless int_priority.is_a?(Integer)  # Match spec
      int = Process.pid if int == 0                       # Match spec

      handle = OpenProcess(PROCESS_SET_INFORMATION, false , int)

      if handle == INVALID_HANDLE_VALUE
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

      string_sid = tuser[8, (rlength.read_ulong - 8)]

      if sid
        string_sid
      else
        psid = FFI::MemoryPointer.new(:ulong)

        unless ConvertSidToStringSidA(string_sid, psid)
          raise SystemCallError, FFI.errno, "ConvertSidToStringSid"
        end

        buf = 0.chr * 80
        strcpy(buf, psid.read_ulong)
        buf.strip.split('-').last.to_i
      end
    end

    remove_method :getrlimit

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
        @job_name = 'ruby_' + Process.pid.to_s
        handle = CreateJobObjectA(nil, job_name)
        raise SystemCallError, FFI.errno, "CreateJobObject" if handle == 0
      end

      begin
        unless in_job
          unless AssignProcessToJobObject(handle, GetCurrentProcess())
            raise SystemCallError, FFI.errno, "AssignProcessToJobObject"
          end
        end

        # sizeof(struct JOBJECT_EXTENDED_LIMIT_INFORMATION)
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
        env.encode!('UTF-16LE') if hash['with_logon']
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
      # or file descriptors. This won't work for StringIO, however.
      ['stdin', 'stdout', 'stderr'].each{ |io|
        if si_hash[io]
          if si_hash[io].respond_to?(:fileno)
            handle = get_osfhandle(si_hash[io].fileno)
          else
            handle = get_osfhandle(si_hash[io])
          end

          if handle == INVALID_HANDLE_VALUE
            raise SystemCallError, FFI.errno, "get_osfhandle"
          end

          # Most implementations of Ruby on Windows create inheritable
          # handles by default, but some do not. RF bug #26988.
          bool = SetHandleInformation(
            handle,
            HANDLE_FLAG_INHERIT,
            HANDLE_FLAG_INHERIT
          )

          raise SystemCallError, FFI.errno, "SetHandleInformation" unless bool

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
        startinfo[:lpReserved]      = nil
        startinfo[:lpDesktop]       = si_hash['desktop']
        startinfo[:lpTitle]         = si_hash['title']
        startinfo[:dwX]             = si_hash['x']
        startinfo[:dwY]             = si_hash['y']
        startinfo[:dwXSize]         = si_hash['x_size']
        startinfo[:dwYSize]         = si_hash['y_size']
        startinfo[:dwXCountChars]   = si_hash['x_count_chars']
        startinfo[:dwYCountChars]   = si_hash['y_count_chars']
        startinfo[:dwFillAttribute] = si_hash['fill_attribute']
        startinfo[:dwFlags]         = si_hash['startf_flags']
        startinfo[:wShowWindow]     = si_hash['sw_flags']
        startinfo[:cbReserved2]     = 0
        startinfo[:lpReserved2]     = nil
        startinfo[:hStdInput]       = si_hash['stdin']
        startinfo[:hStdOutput]      = si_hash['stdout']
        startinfo[:hStdError]       = si_hash['stderr']
      end

      if hash['with_logon']
        app = nil
        cmd = nil

        logon  = (hash['with_logon'] + "\0").encode('UTF-16LE')
        domain = (hash['domain'] + "\0").encode('UTF-16LE')
        cwd    = (hash['cwd'] + "\0").encode('UTF-16LE')
        passwd = (hash['password'] + "\0").encode('UTF-16LE')

        if hash['app_name']
          app = (hash['app_name'] + "\0").encode('UTF-16LE')
        end

        if hash['command_line']
          cmd = (hash['command_line'] + "\0").encode('UTF-16LE')
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
          raise SystemCallError, FFI.errno, "CreateProcessWithLogonW"
        end
      else
        inherit = hash['inherit'] || false

        bool = CreateProcessA(
          hash['app_name'],       # App name
          hash['command_line'],   # Command line
          process_security,       # Process attributes
          thread_security,        # Thread attributes
          inherit,                # Inherit handles?
          hash['creation_flags'], # Creation flags
          env,                    # Environment
          hash['cwd'],            # Working directory
          startinfo,              # Startup Info
          procinfo                # Process Info
        )

        unless bool
          raise SystemCallError, FFI.errno, "CreateProcess"
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
  end

  private

  def volume_type
    buf = FFI::MemoryPointer.new(:char, 32)
    bool = GetVolumeInformationA(nil, nil, 0, nil, nil, nil, buf, buf.size)
    bool ? buf.read_string : nil
  end
end
