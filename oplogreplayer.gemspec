# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'oplogreplayer/version'

Gem::Specification.new do |spec|
  spec.name          = "mongo-oplogreplayer"
  spec.version       = Oplogreplayer::VERSION
  spec.authors       = ["brettcave"]
  spec.email         = ["brett@cave.za.net"]
  spec.summary       = %q{Replays the oplog from a mongo replica set}
  spec.description   = %q{Reads the oplog from a replica set and replays it to another mongo instance / rs.}
  spec.homepage      = "https://github.com/brettcave/mongo-oplogreplay"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.5"
  spec.add_development_dependency "rake", "~> 10.3"
  spec.add_development_dependency "rspec", "~> 2.6"
  spec.add_development_dependency "cucumber"
  spec.add_development_dependency "aruba"

  spec.add_dependency "mongoriver", "~> 0.3.1"
  spec.add_dependency "mongo", "~> 1.10"
  spec.add_dependency "thor", "~> 0.18"
end
