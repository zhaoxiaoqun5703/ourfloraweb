require 'rake'
# Use json-schema gem to validate input json
require 'json-schema'

namespace :species do
  # Validate basic outer objects (family and species)
  def object_schema
    {
    "type": "object"
    }
  end

  # Validate inner objects (species properties)
  def species_schema
    {
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
  end

  def import_json(filename)
    json_string = File.read(ENV['file'])
    # First, validate that there are family objects in the outer scope
    if JSON::Validator.validate(object_schema, json_string)
      json_object = JSON.parse(json_string)
      json_object.each do |family_name, family_object|
        if JSON::Validator.validate(object_schema, family_object)
          # If the family name is valid, create a new family object in the database
          if (family = Family.where(name: family_name).first).nil?
            family = Family.new
            family.name = family_name
          end

          family_object.each do |species_name, species_object|
            if JSON::Validator.validate(species_schema, species_object)
              # This is a valid species object
              species = Species.new
              species.genusSpecies = species_object["genusSpecies"]
              species.commonName = species_object["commonName"]
              species.authority = species_object["authority"]
              species.distribution = species_object["distribution"]
              species.indigenousName = species_object["indigenousName"]
              species.description = species_object["description"]
              species.information = species_object["information"]
              species.family = family
              species_object["mapPin"].split(/\; /).each do |location|
                location = location.gsub(/[\(|\)]/, '').split(/\,\ /)
                l = SpeciesLocation.new
                l.lat = location[0]
                l.lon = location[1]
                species.species_locations << l
              end
              species.save()
            else
              errors = JSON::Validator.fully_validate(species_schema, species_object)
              puts "INVALID SPECIES: #{species_name}"
              puts "Errors:"
              errors.each do |error|
                puts error
              end
            end # if JSON::Validator.validate(species_schema, species_object)
          end # family_object.each do |species_name, species_object|

          family.save()
        end # if JSON::Validator.validate(object_schema, family_object)
      end # json_object.each do |family_name, family_object|
    end # if JSON::Validator.validate(object_schema, json_string)
  end

  # Call task as rake import_species format=<json,xml etc> file=<filename>
  task :import_species => :environment do
    # Exit if the user hasn't specified a file location and format
    return unless ENV['file'] && ENV['format']
    if ENV['format'] == 'json'
      import_json ENV['file']
    end
  end # task :import_json do
end