# win32-process Changelog

<!-- usage documentation: http://expeditor-docs.es.chef.io/configuration/changelog/ -->
<!-- latest_release 0.10.0 -->
## [win32-process-0.10.0](https://github.com/chef/win32-process/tree/win32-process-0.10.0) (2022-04-19)

#### Merged Pull Requests
- Testing Ruby 3.1 support [#39](https://github.com/chef/win32-process/pull/39) ([johnmccrae](https://github.com/johnmccrae))
<!-- latest_release -->
<!-- release_rollup since=0.8.3 -->
= 0.8.3 - 16-Dec-2015
* Fixed a declaration in the CreateProcessWithLoginW function prototype. Thanks
  go to ksubrama for the spot.
* Only define attach_pfunc if not already defined to avoid potential warnings.
<!-- release_rollup -->
<!-- latest_stable_release -->
= 0.8.2 - 15-Oct-2015
* Fixed a declaration bug in the CreateProcess function prototype, and replaced
  all instances of :bool with :int in function prototypes, along with
  corresponding core code changes. Thanks go to Kartik Null Cating-Subramanian
  for the spot.

= 0.8.1 - 3-Sep-2015
* The gem is now signed.
* Updated Rakefile and gemspec to support signing.
* Added a win32-process.rb stub for your convenience.

= 0.8.0 - 29-Apr-2015
* Added the Process.snapshot method that lets you gather information for
  the heap, threads, modules, and processes.

= 0.7.5 - 3-Mar-2015
* Use require_relative where possible.
* Fixed a bug in Process.setrlimit. Note that this method has been marked
  as experimental until further notice.
* Minor updates to gemspec and Rakefile.
* Added known issue for JRuby and SIGBRK to the README.

= 0.7.4 - 21-Oct-2013
* Fixed the INVALID_HANDLE_VALUE constant for 64-bit versions of Ruby.
* Added Rake as a development dependency.

= 0.7.3 - 25-Sep-2013
* Added the Process.get_exitcode method. Thanks go to mthiede for the patch.
* The Process.kill method raises a SecurityError if the $SAFE level is 2
  or higher. This was done to match the spec.
* Fixed a bug in our custom Process.uid method that affected 64-bit Ruby.
* A note was added to use the Process.spawn method instead of Process.create
  method where practical.

= 0.7.2 - 8-Apr-2013
* Fixed a 64 bit issue caused by the fact that HANDLE's were set as ulong
  instead of intptr_t. Thanks go to Crossverse the spot.
* Added some typedefs in the underlying FFI code for Windows data types.

= 0.7.1 - 3-Jan-2013
* The _get_errno function is apparently not exported on on Windows XP or
  earlier. On those platforms, FFI.errno is now used instead. Thanks go
  to Lars Christensen for the report.

= 0.7.0 - 22-Aug-2012
* Converted to use FFI instead of win32-api.
* Now requires Ruby 1.9.x or later.
* Removed the experimental Process.fork function. This obviated the necessity
  of custom implementations of other methods, like Process.waitpid, so those
  no longer have custom implementations either. These also proved to be
  somewhat problematic with Ruby 1.9.x anyway.
* Removed the custom Process.ppid method because Ruby 1.9.x now supports it.
* The Process.kill method now supports the :exit_proc, :dll_module and
  :wait_time options for signals 1 and 4-8.

= 0.6.5 - 27-Dec-2010
* Fixed getpriority and setpriority so that the underlying process handle is
  always closed. Thanks go to Rafal Michalski	for the spot and patch.
* Updated getpriority and setpriority so that there are no longer any
  default arguments. This now matches the MRI spec.
* Updated Process.create so that illegal options now raise an ArgumentError
  instead of a Process::Error.
* Fixed a bug in an error message in the Process.create method where the actual
  error message was getting lost.
* Refactored the test suite to use test-unit 2.x features, and make tests a
  little more robust in general.

= 0.6.4 - 13-Nov-2010
* Altered the wait, wait2, waitpid and waitpid2 methods to match the current
  MRI interface, i.e. they accept and optional pid and flags, though the
  latter is ignored. Thanks go to Robert Wahler for the spot.
* Renamed the example scripts to avoid any potential confusion with actual
  test scripts and cleaned them up a bit.
* Added Rake tasks to run the example programs.
* Updated the MANIFEST.

= 0.6.3 - 9-Nov-2010
* Fixed a bug in the Process.kill method where the remote thread created
  was not being properly closed. Thanks go to Ben Nagy for the spot.
* Added the Process.job? method that returns whether or not the current process
  is already in a job.
* Added the Process.setrlimit method. Like the Process.getrlimit method it
  only supports a limited subset of resources.
* Rakefile tweaks.

= 0.6.2 - 19-Dec-2009
* Fixed an issue where stdin, stdout and stderr might not be inheritable
  even if the inherit option was set. Thanks go to Michael Buselli for the
  spot and the patch.
* Added a basic implementation of Process.getrlimit.
* Added the Process.get_affinity method.
* Added test-unit 2.x and sys-proctable as development dependencies.
* Added the :uninstall and :build_gem Rake tasks to the Rakefile.
* Bumped required version of windows-pr to 1.0.6.

= 0.6.1 - 16-Jul-2009
* Added the Process.uid method. This method returns a user id (really, the RID
  of the SID) by default, but can also take an optional parameter to return
  a binary SID instead at the user's discretion.
* Added working implementations of Process.getpriority and Process.setpriority.
  Note they they only work for processes, not process groups or users.
* Set license to Artistic 2.0, and updated the gemspec.

= 0.6.0 - 31-Oct-2008
* The mandatory argument for Process.create has been switched from 'app_name'
  to 'command_line', to be more in line with underlying CreateProcess API.
  Note that 'command_line' will default to 'app_name' if only the latter is
  set, but both may be set individually. Keep in mind that 'app_name' must
  be a full path to the executable. Thanks go to Jeremy Bopp for the patch.
* Removed the deprecated ProcessError constant. Use Process::Error instead.
* Explicitly include and extend the Windows::Thread module now. Thanks go to
  Qi Lu for the spot.
* Slightly more robust internal code handling for some of the other methods,
  typically related to ensuring that HANDLE's are closed.
* Example programs are now included with the gem.

= 0.5.9 - 14-Jun-2008
* Added a proper implementation of Process.ppid.

= 0.5.8 - 24-Mar-2008
* Fixed a bug in Process.create where the handles in the PROCESS_INFORMATION
  struct were not closed, regardless of the 'close_handles' option. Thanks
  go to Lars Christensen for the spot and the patch.

= 0.5.7 - 27-Mar-2008
* Fixed issues with thread_inherit and process_inherit in the Process.create
  method. This in turn required an update to windows-pr. Thanks go to Steve
  Shreeve for the spot.
* Fixed a potential issue with startf_flags and stdin/stdout/stderr handling.
  Thanks again go to Steve Shreeve for the spot and the patch.
* Fixed the code so that it no longer emits redefinition warnings.
* Fixed a bug in the Rake install task (for non-gem installations).

== 0.5.6 - 13-Mar-2008
* Fixed a bug in the Process.waitpid2 method where it wasn't returning the
  proper exit code. Thanks go to Jeremy Bopp for the spot and the patch.
* In the spirit of DWIM, if the 'stdin', 'stdout' or 'stderr' keys are
  encountered in the startup_info hash, then the inherit flag is automatically
  set to true and the startf_flags key is automatically OR'd with the
  STARTF_USESTDHANDLES value. Thanks go to Sander Pool for the inspiration.

== 0.5.5 - 12-Dec-2007
* The Process.create method now automatically closes the process and thread
  handles in the ProcessInfo struct before returning, unless you explicitly
  tell it not to via the 'close_handles' option.
* The Process.create method now supports creating a process as another user
  via the 'with_logon', 'password' and 'domain' options.

== 0.5.4 - 23-Nov-2007
* Changed ProcessError to Process::Error.
* Now requires windows-pr 0.7.3 or later because of some reorganization in
  that library with regards to thread functions.
* Better cleanup of HANDLE's in a couple methods when failure occurs.
* Added an additional require/include necessitated by a change in the method
  organization in the windows-pr library.

== 0.5.3 - 29-Jul-2007
* Added a Rakefile with tasks for installation and testing.
* Removed the install.rb file (now handled by the Rakefile).
* Updated the README and MANIFEST files.

== 0.5.2 - 22-Jan-2007
* The startup_info parameter for the Process.create method now accepts
  'stdin', 'stdout', and 'stderr' as valid parameters, which you can pass
  a Ruby IO object or a fileno in order to redirect output from the created
  process.

== 0.5.1 - 24-Aug-2006
* Fixed a bug in the Process.create method where the return value for
  CreateProcess() was being evaluated incorrectly.  Thanks go to David Haney
  for the spot.
* Added a slightly nicer error message if an invalid value is passed to the
  Process.create method.
* Removed an extraneous '%' character from an error message.

== 0.5.0 - 29-Jul-2006
* The Process.create method now returns a ProcessInfo struct instead of the
  pid.  Note that you can still grab the pid out of the struct if needed.
* The Process.create method now allows the process_inherit and
  thread_inherit options which determine whether a process or thread
  object's handles are inheritable, respectively.
* The wait and wait2 methods will now work if GetProcessId() isn't defined
  on your system.
* The 'inherit?' hash option was changed to just 'inherit' (no question mark).
* Minor doc correction - the 'inherit' option defaults to false, not true.

== 0.4.2 - 29-May-2006
* Fixed a typo/bug in Process.kill for signal 3, where I had accidentally
  used CTRL_BRK_EVENT instead of the correct CTRL_BREAK_EVENT.  Thanks go
  to Luis Lavena for the spot.

== 0.4.1 - 13-May-2006
* Fixed a bug where spaces in $LOAD_PATH would cause Process.fork to fail.
  Thanks go to Justin Bailey for the spot and patch.
* Added a short synopsis to the README file.

== 0.4.0 - 7-May-2006
* Now pure Ruby, courtesy of the Win32API package.
* Now comes with a gem.
* Modified Process.kill to send a signal to the current process if pid 0
  is specified, as per the current 1.8 behavior.
* Process.create now accepts the 'environment' key/value, where you can
  pass a semicolon-separated string as the environment for the new process.
* Moved the GUI related options of Process.create to subkeys of the
  'startup_info' key.  See documentation for details.
* Replaced Win32::ProcessError with just ProcessError.

== 0.3.3 - 16-Apr-2006
* Fixed a bug in Process.create with regards to creation_flags.  Thanks go
  to Tophe Vigny for the spot.

== 0.3.2 - 12-Aug-2005
* Fixed a bug in Process.kill where a segfault could occur.  Thanks go to
  Bill Atkins for the spot.
* Changed VERSION to WIN32_PROCESS_VERSION, because it's a module.
* Made the CHANGES, README and doc/process.txt documents rdoc friendly.
* Removed the process.rd file.

== 0.3.1 - 9-Dec-2004
* Modified Process.fork to return an actual PID instead of a handle.  This
  means that it should work with Process.kill and other methods that expect
  an actual PID.
* Modified Process.kill to understand the strings "SIGINT", "INT", "SIGBRK",
  "BRK", "SIGKILL" and "KILL".  These correspond to signals 2, 3 and 9,
  respectively.
* Added better $LOAD_PATH handling for Process.fork.  Thanks go to Aslak
  Hellesoy for the spot and the patch.
* Replaced all instances of rb_sys_fail(0) with rb_raise().  This is because
  of a strange bug in the Windows Installer that hasn't been nailed down yet.
  This means that you can't rescue Errno::ENOENT any more, but will have to
  rescue StandardError.  This only affects Process.kill.
* The signals that were formerly 1 and 2 and now 2 and 3.  I did this because
  I wanted the same signal number for SIGINT as it is on *nix.
* Added a test_kill.rb script under the examples directory.
* Other minor cleanup and corrections.

== 0.3.0 - 25-Jul-2004
* Added the create() method.
* Moved the example programs to doc/examples.
* Updated the docs, and toned down claims of fork's similarity to the Unix
  version.
* Minor updates to the test suite.

== 0.2.1 - 17-May-2004
* Made all methods module functions, except fork, rather than singleton
  methods.
* Minor doc changes.

== 0.2.0 - 11-May-2004
* Removed the Win32 module/namespace.  You no longer 'include Win32' and you
  no longer need to prefix Process with 'Win32::'.
* The fork() method is now a global function as well as a method of the
  Process module.  That means you can call 'fork' instead of 'Process.fork'
  if you like.
* Doc updates to reflect the above changes.

== 0.1.1 - 6-Mar-2004
* Fixed bug where spaces in the directory name caused the fork() method to
  fail (Park).
* Normalized tc_process.rb somewhat to make it easier to run outside of the
  test directory if desired.
* Fixed up tc_process.rb a bit.

== 0.1.0 - 19-Feb-2004
* Initial release