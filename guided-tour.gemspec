# frozen_string_literal: true

require_relative "lib/guided_tour/version"

Gem::Specification.new do |spec|
  spec.name = "guided-tour"
  spec.version = GuidedTour::VERSION
  spec.authors = ["Benjamin Deutscher"]
  spec.email = ["ben@bdeutscher.org"]

  spec.summary = "Gem to guide users through the UI and explain things."
  spec.description = "When building UIs for 'non tech people' things tend to get difficult to explain since some people do not know terms like button, select, etc. guided-tour helps with that."
  spec.homepage = "https://guided-tour.bdeutscher.org"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/its-bede/guided-tour"
  spec.metadata["changelog_uri"] = "https://github.com/its-bede/guided-tourblob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "railties", ">= 7.1", "< 8.0"        # Core Rails functionality
  spec.add_dependency "actionview", ">= 7.1", "< 8.0"      # For view helpers
  spec.add_dependency "activesupport", ">= 7.1", "< 8.0"   # For general Rails utilities
  spec.add_dependency "rails-i18n", ">= 7.0", "< 8.0"      # For Stimulus integration
  spec.add_dependency "stimulus-rails"

  # JavaScript dependencies metadata
  spec.metadata["npm_package_name"] = "@guided_tour/controllers"

  # Development dependencies for testing
  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "jsbundling-rails"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
