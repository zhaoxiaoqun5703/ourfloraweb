require 'find'
require 'digest/md5'

BAD_IMAGE_HASH = "7d092050f834b961a287e264087e6d53"

module FloraImportJson
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

  def import_species_json(filename, image_dir = null)
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

              # If there was an image dir specified, try to use paperclip to import those images
              if image_dir
                # Loop through the specified directory and find a sub directory with the current species name
                Dir.entries(ENV['image_dir']).select do |d|
                  if (File.directory? "#{ENV['image_dir']}/#{d}")
                    # If the directory name is the same as the species
                    if d == species.genusSpecies
                      # Search for all images in subdirectories
                      img_file_paths = []
                      Find.find("#{ENV['image_dir']}/#{d}") do |path|
                        img_file_paths << path if path =~ /.*\.(jpeg)|(jpg)|(png)|(gif)$/
                      end
                      # If we found 1 or more images, create new image objects with paperclip
                      img_file_paths.each do |image_path|
                        # If the file matches a blacklist file (e.g the old "image missing" file) then skip it
                        unless Digest::MD5.hexdigest(File.read(image_path)) == BAD_IMAGE_HASH
                          image = Image.new
                          image.image = File.open(image_path)
                          species.images << image
                        else
                          puts "Skipping old 'image missing' image"
                        end
                      end
                    end
                  end
                end
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

  # Validate trail objects on this schema
  def trail_schema
    {
      "$schema": "http://json-schema.org/draft-04/schema#",
      "title": "Trail",
      "type": "string",
      "description": 'A string containing a semicolon + space delimited ("; ") list of species names, e.g "Non-Flowering Plants": "Asplenium australasicum; Pteridium esculentum; Cyathea cooperi; Afrocarpus falcatus; Araucaria bidwillii;"'
    }
  end

  def import_trails_json(filename)
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
          trail_species = trail_string.split(/\;\ /)
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
end