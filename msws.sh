state_file="$STATE_DIR/.last_msws"
today="$(date +%Y-%m-%d)"
forecast_url='https://api.weather.gov/gridpoints/MKX/38,64/forecast'

if [[ -f "$state_file" ]] && grep -q "$today" "$state_file"; then
  echo "✅ Already posted today ($today). Skipping."
  exit 0
fi

forecast="$(curl "$forecast_url")" 
prob="$(jq '.properties.periods[0].probabilityOfPrecipitation.value' <<< "$forecast")"
desc="$(jq '.properties.periods[0].detailedForecast' <<< "$forecast")"

curl_header='Content-Type: application/json'
gif_message='
  {"content": "https://tenor.com/view/there-is-a-storm-coming-weather-hurricane-tornado-gif-11678470"}
'
detail_message="{\"content\": $desc}"

if [ "$prob" -gt 79 ] || [[ "$desc" == *"thunder"* ]]; then
  echo "There is a storm coming!"
  curl "$HOOK_URL" -H "$curl_header" --data "$gif_message"
  curl "$HOOK_URL" -H "$curl_header" --data "$detail_message"
  echo "$today" > "$state_file"  # ✅ Record the alert was sent today
else
  echo "🌤 There is not a storm coming."
fi
