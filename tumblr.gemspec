## tumblr.gemspec
#

Gem::Specification::new do |spec|
  spec.name = "tumblr"
  spec.version = "2.0.0"
  spec.platform = Gem::Platform::RUBY
  spec.summary = "tumblr"
  spec.description = "a command line utility and library for the excellent tumblr blogging platform"

  spec.files = ["bin", "bin/tumblr", "lib", "lib/tumblr.rb", "Rakefile", "README", "tumblr.gemspec"]
  spec.executables = ["tumblr"]
  
  spec.require_path = "lib"

  spec.has_rdoc = true
  spec.test_files = nil
  spec.add_dependency 'fattr'
  spec.add_dependency 'main'
  spec.add_dependency 'httpclient'

  spec.extensions.push(*[])

  spec.rubyforge_project = "codeforpeople"
  spec.author = "Ara T. Howard"
  spec.email = "ara.t.howard@gmail.com"
  spec.homepage = "http://github.com/ahoward/tumblr/tree/master"
end
