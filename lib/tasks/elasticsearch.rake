namespace :elasticsearch do
  desc "Creates the Elasticsearch index and imports all coding rules"
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
  end
end
