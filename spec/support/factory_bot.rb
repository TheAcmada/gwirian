RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
end

# Load engine factories only when running in SaaS mode (e.g. saas/spec/factories)
if defined?(Gwirian) && Gwirian.saas?
  saas_factories = Rails.root.join("saas/spec/factories")
  if saas_factories.directory?
    FactoryBot.definition_file_paths << saas_factories.to_s
    FactoryBot.reload
  end
end
