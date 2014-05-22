# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rroute/version'

Gem::Specification.new do |spec|
  spec.name          = "sinatra-rroute"
  spec.version       = Rroute::VERSION
  spec.authors       = ["nounch"]
  spec.email         = [""]
  spec.summary       =
    "Rails-style routes with names, namespaces and `path' helper."
  spec.description   = <<-DESCRIPTION
Sinatra-rraoute provides `gget'/`ppost'/`ddelete'/... methods which work
just like Sinatra's built-in `get'/`post'/`delete'/... methods, but which
map named routes to functions so that they can be referenced in redirects
etc.

The `path' helper will return a route for a certain route name and the
given values for this route and comes in handy in both, the
controller/model component of the application, and the view where you can
use it to render links, assets URLs, AJAX calls...

The nestable `nnamespace' method is useful for API versioning and does not
interfere with other namespace extensions for Sinatra.
    DESCRIPTION
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
