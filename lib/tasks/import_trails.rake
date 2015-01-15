require 'rake'
# Use json-schema gem to validate input json and ruby objects
require 'json-schema'
# Include importer in /lib/import
require './lib/import/flora_import_json.rb'
include FloraImportJson

namespace :trails do

  # Call task as rake import_trails format=<json,xml etc> file=<filename>
  task :import => :environment do
    # Exit if the user hasn't specified a file location and format
    return unless ENV['file'] && ENV['format']
    if ENV['format'] == 'json'
      import_trails_json ENV['file']
    end
  end # task :import_json do
end