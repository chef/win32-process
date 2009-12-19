require 'rubygems'

spec = Gem::Specification.new do |gem|
  gem.name       = 'win32-process'
  gem.version    = '0.6.2'
  gem.license    = 'Artistic 2.0'
  gem.authors    = ['Daniel Berger', 'Park Heesob']
  gem.email      = 'djberg96@gmail.com'
  gem.homepage   = 'http://www.rubyforge.org/projects/win32utils'
  gem.platform   = Gem::Platform::RUBY
  gem.summary    = 'Adds and redefines several Process methods for MS Windows'
  gem.test_files = Dir['test/*.rb']
  gem.has_rdoc   = true
  gem.files      = Dir['**/*'].reject{ |f| f.include?('CVS') }

  gem.rubyforge_project = 'win32utils'
  gem.extra_rdoc_files  = ['README', 'CHANGES', 'MANIFEST']

  gem.add_dependency('windows-pr', '>= 1.0.5')
  gem.add_development_dependency('test-unit', '>= 2.0.3')
  gem.add_development_dependency('sys-proctable')

  gem.description = <<-EOF
    The win32-process library implements several Process methods that are
    either unimplemented or dysfunctional in some way in the default Ruby
    implementation. Examples include Process.kill, Process.waitpid,
    Process.create and an experimental Process.fork method.
  EOF
end
