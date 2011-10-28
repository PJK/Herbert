# encoding: utf-8
$:.push File.expand_path("../lib", __FILE__)
require "herbert/version"

Gem::Specification.new do |s|
  s.name        = "herbert"
  s.version     = Herbert::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Pavel Kalvoda"]
  s.email       = ["me@pavelkalvoda.com","pavel@drinkwithabraham.com"]
  s.homepage    = "https://github.com/PJK/Herbert"
  s.summary     = %q{Sinatra-based toolset for creating JSON API servers backed by Mongo & Memcached}
  s.description = <<-desc
Herbert makes development of JSON REST API servers ridiculously simple.
It provides a set of useful helpers and conventions to speed up development.
Input validation, logs and advanced AJAX support are baked in.
Herbert is very lightweight and transparent, which makes it easy to use & modify.
	desc

	s.add_dependency("sinatra","= 1.2.6")
	s.add_dependency("memcache-client")
	s.add_dependency("mongo")
	s.add_dependency("syslogger")
	s.add_dependency("kwalify","= 0.7.2")
	s.add_dependency("activesupport")
	s.add_dependency("bson_ext",">= 1.3.1")
  s.add_dependency("rake")

  s.add_development_dependency("test-unit")
	
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
