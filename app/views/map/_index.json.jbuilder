json.cache! @species do
  json.array! @species do |species|
    json.id species.id
    json.genusSpecies species.genusSpecies
    json.commonName species.commonName
    json.indigenousName species.indigenousName
    json.authority species.authority
    json.distribution species.distribution
    json.information species.information
    json.description species.description
    json.html_link_description auto_link(species.description)
    json.created_at species.created_at
    json.updated_at species.updated_at
    json.family species.family
    json.images species.images do |image|
      json.image_url image.image.url(:original)
      json.image_url_tiny image.image.url(:tiny)
      json.image_url_small image.image.url(:thumb)
    end
    json.species_locations species.species_locations
  end
end