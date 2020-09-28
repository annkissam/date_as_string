# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "date_as_string/version"

Gem::Specification.new do |spec|
  spec.name        = "date_as_string"
  spec.version     = DateAsString::VERSION::STRING
  spec.authors     = ["Eric Sullivan"]
  spec.email       = ["eric.sullivan@annkissam.com"]
  spec.homepage    = "https://github.com/annkissam/date_as_string"
  spec.summary     = %q{Convert from Date to String and vice versa by attaching _string suffix to an ActiveRecord field}
  spec.description = %q{Treat an ActiveRecord Date column as a String}
  spec.license     = 'MIT'

  spec.files         = `git ls-files`.split("\n")
  spec.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  spec.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "rspec"
  spec.add_development_dependency "rake"
end
