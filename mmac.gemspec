# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mmac/version'

Gem::Specification.new do |gem|
  gem.name          = "mmac"
  gem.version       = Mmac::VERSION
  gem.authors       = ["Thanh Nguyen"]
  gem.email         = ["congthanh991@gmail.com"]
  gem.description   = ["MMAC Project"]
  gem.summary       = ["MMAC Library"]
  gem.homepage      = ""
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.add_dependency 'ruby-progressbar'
end
