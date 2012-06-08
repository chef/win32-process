require 'rubygems'

Gem::Specification.new do |spec|
  spec.name       = 'win32-process'
  spec.version    = '0.7.0'
  spec.license    = 'Artistic 2.0'
  spec.authors    = ['Daniel Berger', 'Park Heesob']
  spec.email      = 'djberg96@gmail.com'
  spec.homepage   = 'http://www.rubyforge.org/projects/win32utils'
  spec.summary    = 'Adds and redefines several Process methods for MS Windows'
  spec.test_files = Dir['test/*.rb']
  spec.files      = Dir['**/*'].reject{ |f| f.include?('git') }

  spec.rubyforge_project = 'win32utils'
  spec.extra_rdoc_files  = ['README', 'CHANGES', 'MANIFEST']

  spec.add_dependency('ffi', '>= 1.0.0')
  spec.add_development_dependency('test-unit', '>= 2.4.0')

  spec.description = <<-EOF
    The win32-process library implements several Process methods that are
    either unimplemented or dysfunctional in some way in the default Ruby
    implementation. Examples include Process.kill, Process.waitpid,
    Process.create and an experimental Process.fork method.
  EOF
end
