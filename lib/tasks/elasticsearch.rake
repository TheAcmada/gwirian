namespace :elasticsearch do
  desc "Creates the Elasticsearch index and imports all models"
  task reindex: :environment do
    #########################################################
    puts "Recreating index for Feature model..."
    Feature.__elasticsearch__.client.indices.delete index: Feature.index_name rescue nil
    Feature.__elasticsearch__.client.indices.create(
      index: Feature.index_name,
      body: { settings: Feature.settings.to_hash, mappings: Feature.mappings.to_hash }
    )
    Feature.import force: true
    puts "Finished indexing all features."

    #########################################################
    puts "Recreating index for ScenarioExecution model..."
    ScenarioExecution.__elasticsearch__.client.indices.delete index: ScenarioExecution.index_name rescue nil
    ScenarioExecution.__elasticsearch__.client.indices.create(
      index: ScenarioExecution.index_name,
      body: { settings: ScenarioExecution.settings.to_hash, mappings: ScenarioExecution.mappings.to_hash }
    )
    ScenarioExecution.import force: true
    puts "Finished indexing all scenario executions."
  end
end
