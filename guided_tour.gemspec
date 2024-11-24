require_relative "lib/guided_tour/version"

Gem::Specification.new do |spec|
  spec.name        = "guided_tour"
  spec.version     = GuidedTour::VERSION
  spec.authors     = [ "Benjamin Deutscher" ]
  spec.email       = [ "ben@bdeutscher.org" ]
  spec.summary = "Gem to guide users through the UI and explain things."
  spec.description = "When building UIs for 'non tech people' things tend to get difficult to explain since some people do not know terms like button, select, etc. guided-tour helps with that."
  spec.homepage = "ttps://github.com/its-bede/guided-tour"
  spec.license = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/its-bede/guided-tour"
  spec.metadata["changelog_uri"] = "https://github.com/its-bede/guided-tourblob/main/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "railties", ">= 7.1"                 # Core Rails functionality
  spec.add_dependency "actionview", ">= 7.1", "< 8.0"      # For view helpers
  spec.add_dependency "activesupport", ">= 7.1", "< 9.0"   # For general Rails utilities
  spec.add_dependency "rails-i18n", ">= 7.0", "< 8.0"      # For Stimulus integration
  spec.add_dependency "stimulus-rails"

  # Development dependencies for testing
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "jsbundling-rails"
end
