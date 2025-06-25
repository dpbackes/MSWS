forecast_url='https://api.weather.gov/gridpoints/MKX/38,64/forecast'
curl_header='Content-Type: application/json'

forecast="$(curl "$forecast_url")" 
prob="$(jq '.properties.periods[0].probabilityOfPrecipitation.value' <<< "$forecast")"
desc="$(jq '.properties.periods[0].detailedForecast' <<< "$forecast")"
gif_message='
  {"content": "https://tenor.com/view/there-is-a-storm-coming-weather-hurricane-tornado-gif-11678470"
}'
detail_message="{\"content\": $desc}"

if [ "$prob" -gt 79 ] || [[ "$desc" == *"thunder"* ]]; then
  resp="$(curl "$HOOK_URL" -H "$curl_header" --data "$gif_message")"
  echo "$resp"
  resp="$(curl "$HOOK_URL" -H "$curl_header" --data "$detail_message")"
fi
