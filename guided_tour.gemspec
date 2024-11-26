require_relative "lib/guided_tour/version"

Gem::Specification.new do |spec|
  spec.name        = "guided_tour"
  spec.version     = GuidedTour::VERSION
  spec.authors     = [ "Benjamin Deutscher" ]
  spec.email       = [ "ben@bdeutscher.org" ]
  spec.summary = "Gem to guide users through the UI and explain things."
  spec.description = "When building UIs for 'non tech people' things tend to get difficult to explain since some people do not know terms like button, select, etc. guided-tour helps with that."
  spec.homepage = "https://github.com/its-bede/guided-tour"
  spec.license = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/its-bede/guided-tour"
  spec.metadata["changelog_uri"] = "https://github.com/its-bede/guided-tourblob/main/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 7.1", "< 9.0"
  spec.add_dependency "rails-i18n", ">= 7.0", "< 9.0"
  spec.add_dependency "stimulus-rails"

  # Development dependencies for testing
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "capybara"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "jsbundling-rails"
end
