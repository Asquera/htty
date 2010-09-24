# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name        = "htty"
  s.version     = File.read("VERSION")
  s.platform    = Gem::Platform::RUBY
  s.authors     = []
  s.email       = []
  s.homepage    = "http://rubygems.org/gems/htty"
  s.summary     = "htty is tty for http"
  s.description = "some longer description"

  s.add_development_dependency "bundler", ">= 1.0.0"

  s.files        = `git ls-files`.split("\n")
  s.executables  = `git ls-files`.split("\n").map{|f| f =~ /^bin\/(.*)/ ? $1 : nil}.compact
  s.require_path = 'lib'
end
