require_relative "lib/skiff/version"

Gem::Specification.new do |spec|
  spec.name        = "kamal-skiff"
  spec.version     = Skiff::VERSION
  spec.authors     = [ "David Heinemeier Hansson" ]
  spec.email       = "dhh@hey.com"
  spec.homepage    = "https://github.com/basecamp/kamal-skiff"
  spec.summary     = "Deploy static sites using nginx + SSI with Kamal."
  spec.license     = "MIT"
  spec.files = Dir["lib/**/*", "MIT-LICENSE", "README.md"]
  spec.executables = %w[ skiff ]

  spec.add_dependency "kamal", ">= 1.0"
  spec.add_dependency "thor", "~> 1.2"

  spec.add_development_dependency "debug"
  spec.add_development_dependency "mocha"
  spec.add_development_dependency "railties"
end
