require 'rubygems'

Gem::Specification.new do |spec|
  spec.name       = 'win32-process'
  spec.version    = '0.7.5'
  spec.license    = 'Artistic 2.0'
  spec.authors    = ['Daniel Berger', 'Park Heesob']
  spec.email      = 'djberg96@gmail.com'
  spec.homepage   = 'https://github.com/djberg96/win32-process'
  spec.summary    = 'Adds and redefines several Process methods for MS Windows'
  spec.test_files = Dir['test/*.rb']
  spec.files      = Dir['**/*'].reject{ |f| f.include?('git') }

  spec.extra_rdoc_files  = ['README', 'CHANGES', 'MANIFEST']

  spec.required_ruby_version = '> 1.9.0'
  spec.add_dependency('ffi', '>= 1.0.0')

  spec.add_development_dependency('rake')
  spec.add_development_dependency('test-unit', '>= 2.4.0')

  spec.description = <<-EOF
    The win32-process library implements several Process methods that are
    either unimplemented or dysfunctional in some way in the default Ruby
    implementation. Examples include Process.kill, Process.uid and
    Process.create.
  EOF
end
