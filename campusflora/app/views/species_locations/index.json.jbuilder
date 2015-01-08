json.array!(@species_locations) do |species_location|
  json.extract! species_location, :id
  json.url species_location_url(species_location, format: :json)
end
