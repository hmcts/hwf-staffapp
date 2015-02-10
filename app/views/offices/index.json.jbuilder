json.array!(@offices) do |office|
  json.extract! office, :id, :name
  json.url office_url(office, format: :json)
end
