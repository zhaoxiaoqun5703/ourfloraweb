require 'rake'
# Use json-schema gem to validate input json and ruby objects
require 'json-schema'

namespace :trails do
  
  # Validate json object on this schema
  def object_schema
    {
      "$schema": "http://json-schema.org/draft-04/schema#",
    }
  end

  # Validate trail objects on this schema
  def trail_schema
    {
      "$schema": "http://json-schema.org/draft-04/schema#",
      "title": "Trail",
      "type": "string",
      "description": 'A string containing a semicolon + space delimited ("; ") list of species names, e.g "Non-Flowering Plants": "Asplenium australasicum; Pteridium esculentum; Cyathea cooperi; Afrocarpus falcatus; Araucaria bidwillii;"'
    }
  end

  def import_json(filename)
    json_string = File.read(ENV['file'])
    # Validate that there are trail objects using the schema
    if JSON::Validator.validate(object_schema, json_string)
      # Parse the JSON into an object
      json_object = JSON.parse(json_string)
      json_object.each do |trail_name, trail_string|
        if JSON::Validator.validate(trail_schema, trail_string)
          # Create the new trail
          trail = Trail.new
          trail.name = trail_name
          trail.save
          # Split the species on the trail into an array
          trail_species = trail_string.split /\;\ /
          # Loop through and look up each species, adding it to the trail if it exists
          trail_species.each do |genusSpecies|
            # If a species was found, add it to the trail
            if (species = Species.where(genusSpecies: genusSpecies).first)
              trail.species << species
            end
          end
          trail.save
        else
          errors = JSON::Validator.fully_validate(trail_schema, trail_string)
          puts "INVALID Trail: #{trail_name}"
          puts "Errors:"
          errors.each do |error|
            puts error
          end
        end
      end # json_object.each do |trail_name, trail_string|
    end # if JSON::Validator.validate(object_schema, json_string)
  end

  # Call task as rake import_trails format=<json,xml etc> file=<filename>
  task :import => :environment do
    # Exit if the user hasn't specified a file location and format
    return unless ENV['file'] && ENV['format']
    if ENV['format'] == 'json'
      import_json ENV['file']
    end
  end # task :import_json do
end