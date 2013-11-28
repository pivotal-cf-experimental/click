# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'click/version'

Gem::Specification.new do |spec|
  spec.name          = "click"
  spec.version       = Click::VERSION
  spec.authors       = ["Mark Rushakoff"]
  spec.email         = ["mark.rushakoff@gmail.com"]
  spec.description   = %q{A tool to help track down the source of a memory leak in a Ruby process}
  spec.summary       = %q{Track the changes in counts of live objects in your Ruby process.}
  spec.homepage      = "https://github.com/mark-rushakoff/click"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec", "~> 2.14"
end
