# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "herbert/version"

Gem::Specification.new do |s|
  s.name        = "herbert"
  s.version     = Herbert::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Pavel Kalvoda"]
  s.email       = ["me@pavelkalvoda.com","pavel@drinkwithabraham.com"]
  #s.homepage    = ""
  s.summary     = %q{Sinatra-based toolset for creating JSON API servers backed by Mongo & Memcached}
  s.description = <<-desc
Herbert makes development of JSON REST API servers ridiculously simple.
It provides a bunch of useful helpers and conventions to speed up development.
Herbert is very lightweight and transparent, making it easy to use & modify.
desc

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
