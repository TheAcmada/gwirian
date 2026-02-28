require_relative "lib/gwirian/saas/version"

Gem::Specification.new do |spec|
  spec.name        = "gwirian-saas"
  spec.version     = Gwirian::Saas::VERSION
  spec.authors     = [ "Fred Rocher" ]
  spec.email       = [ "frocher@gwirian.com" ]
  spec.homepage    = "https://github.com/TheAcmada/gwirian"
  spec.summary     = "TheAcmada SaaS companion for Gwirian"
  spec.description = "Rails engine that bundles with Gwirian to offer the hosted version at https://app.gwirian.com"
  spec.license     = "O'Saasy"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/TheAcmada/gwirian"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,bin,config,lib}/**/*", "LICENSE.md", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 8.0.2"
  spec.add_dependency "paddle", "~> 2.9"
  spec.add_dependency "sentry-ruby"
  spec.add_dependency "sentry-rails"
end
