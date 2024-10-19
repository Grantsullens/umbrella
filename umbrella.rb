require "http"
require "json"
require "dotenv/load"

pp "What is your location?"
location = gets.chomp


gmapsresponse = HTTP
  .follow(strict: false)
  .get(
    "https://maps.googleapis.com/maps/api/geocode/json",
    {
      :params => {
        "address" => location,
        "key" => ENV.fetch("Maps_API"),
      },
    }
  )
gmapsresponse_parsed = JSON.parse(gmapsresponse)
gmapsresponse_parsed_results = gmapsresponse_parsed.fetch("results")
first_result = gmapsresponse_parsed_results.first

latitude = first_result.dig("geometry", "location", "lat")
longitude = first_result.dig("geometry", "location", "lng")

latitude = latitude.round(4)
longitude = longitude.round(4)

pirate_weather_api_key = ENV.fetch("Pirate_API")

# Assemble the full URL string by adding the first part, the API token, and the last part together
pirate_weather_url = "https://api.pirateweather.net/forecast/" + pirate_weather_api_key + "/#{latitude},#{longitude}"

# Place a GET request to the URL
pirate_response = HTTP.get(pirate_weather_url)


pirate_parsed_response = JSON.parse(pirate_response)


currently_hash = pirate_parsed_response.fetch("currently")

current_temp = currently_hash.fetch("temperature")
current_summary = currently_hash.fetch("summary")

puts "The current temperature is " + current_temp.to_s + "."
puts current_summary

hourly_hash = pirate_parsed_response.fetch("hourly")
hourly_data = hourly_hash.fetch("data")


first_12_hourly = hourly_data.first(12)

time_precip_array = first_12_hourly.map do |hourly_entry|
  time_unix = hourly_entry.fetch("time")
  precip_prob = hourly_entry.fetch("precipProbability")
    
    # Convert Unix timestamp to Time object in UTC
    time_converted = Time.at(time_unix).utc
    
    {
      Time: time_converted,
      precipProbability: precip_prob
    }
end


threshold = 0.1
hours_over_threshold = 0

time_precip_array.each do |entry|
  time = entry[:Time]
  precip_prob = entry[:precipProbability]
  human_readable_precip_prob = (precip_prob * 100).round(2)
  
  if precip_prob > threshold
    puts " At #{time}, there is a #{human_readable_precip_prob} % chance of precipitation."
    hours_over_threshold = hours_over_threshold + 1 
  else
  end
end

  if hours_over_threshold == 0
    pp "You probably won’t need an umbrella today."
  else
  end
