require 'rake'
# Use json-schema gem to validate input json
require 'json-schema'

# Validate basic outer objects (family and species)
object_schema = {
  "type": "object"
}

# Validate inner objects (species properties)
species_schema = {
  "$schema": "http://json-schema.org/draft-04/schema#",  
  "title": "Family",  
  "description": "Biological family classification",  
  "type": "object",
  "required": ["commonName", "genusSpecies"],
  "properties": {
    "commonName": {
      "description": "The common name of these species, e.g Chinese Tallow Tree",
      "type": "string"
    },
    "authority": {
      "description:": "The authorship under which this species falls, e.g (L.) Roxb.",
      "type": "string"
    },
    "distribution": {
      "description": "The physical distribution of this species, e.g | Eastern Asia. |  Campus data: C'Down n = 3, D'ton n = 1. | ",
      "type": "string"
    },
    "indigenousName": {
      "description": "The indigenous name for the species, if applicable",
      "type": "string"
    },
    "information": {
      "description": "Any additional information on the species",
      "type": "string"
    },
    "genusSpecies": {
      "description": "Sapium sebiferum",
      "type": "string"
    },
    "mapPin": {
      "description": "A semicolon seperated, bracketed list of lat,lng coordinates for locations of this species, e.g (-33.885298, 151.188563); (-33.886023, 151.187140);",
      "type": "string"
    },
    "description": {
      "description": "The long description for this species.",
      "type": "string"
    }
  }
}

# Call task as rake import_json file=<filename>
task :import_json do
  return unless ENV['file']
  json_string = File.read(ENV['file'])
  # First, validate that there are family objects in the outer scope
  if JSON::Validator.validate(object_schema, json_string)
    json_object = JSON.parse(json_string)
    json_object.each do |family_name, family_object|
      if JSON::Validator.validate(object_schema, family_object)
        family_object.each do |species_name, species_object|
          if JSON::Validator.validate(species_schema, species_object)
          else
            errors = JSON::Validator.fully_validate(species_schema, species_object)
            puts "INVALID SPECIES: #{species_name}"
            puts "Errors:"
            errors.each do |error|
              puts error
            end
          end
        end
      end
    end
  end
  # binding.pry
end