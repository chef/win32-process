require_relative "lib/win32/process/version"

Gem::Specification.new do |spec|
  spec.name       = "win32-process"
  spec.version    = Win32::Process::VERSION
  spec.license    = "Artistic-2.0"
  spec.authors    = ["Daniel Berger", "Park Heesob"]
  spec.email      = "djberg96@gmail.com"
  spec.homepage   = "https://github.com/chef/win32-process"
  spec.summary    = "Adds and redefines several Process methods for Microsoft Windows"
  spec.test_files = Dir["test/*.rb"]
  spec.files      = `git ls-files -z`.split("\x0").reject { |f| f.match(/^(\..*|Gemfile|Rakefile|examples|test|CHANGELOG.md|README.md)/) }

  spec.required_ruby_version = ">= 2.7" # required for the use of Integer
  spec.add_dependency("ffi", ">= 1.0.0")

  spec.description = <<-EOF
    The win32-process library implements several Process methods that are
    either unimplemented or dysfunctional in some way in the default Ruby
    implementation. Examples include Process.kill, Process.uid and
    Process.create.
  EOF
end
