json.array!(@species_pictures) do |species_picture|
  json.extract! species_picture, :id
  json.url species_picture_url(species_picture, format: :json)
end
