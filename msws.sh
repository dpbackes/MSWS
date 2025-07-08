#! /usr/bin/env bash

state_file="$STATE_DIR/.last_msws"
forecast_url='https://api.weather.gov/gridpoints/MKX/38,64/forecast'
alert_url='https://api.weather.gov/alerts/active?status=actual&message_type=alert&event=Blizzard%20Warning,Ice%20Storm%20Warning,Severe%20Thunderstorm%20Warning,Severe%20Thunderstorm%20Watch,Storm%20Warning,Storm%20Watch,Tornado%20Watch,Tornado%20Warning,Winter%20Storm%20Warning,Winter%20Storm%20Watch,Winter%20Weather%20Advisory&point=43.074%2C-89.384&urgency=Immediate,Expected,Future&certainty=Observed,Likely,Possible'

# test alert url
# alert_url='https://api.weather.gov/alerts/active?status=actual&message_type=alert&urgency=Immediate,Expected,Future&certainty=Observed,Likely,Possible'

forecast="$(curl "$forecast_url")" 
alerts="$(curl "$alert_url")" 
prob="$(jq '.properties.periods[0].probabilityOfPrecipitation.value' <<< "$forecast")"
desc="$(jq '.properties.periods[0].detailedForecast' <<< "$forecast")"
alert_count="$(jq '.features | length' <<< "$alerts")"

curl_header='Content-Type: application/json'
gif_message='
  {"content": "https://tenor.com/view/there-is-a-storm-coming-weather-hurricane-tornado-gif-11678470"}
'
detail_message="{\"content\": $desc}"

if [ "$prob" -gt 79 ] || [[ "$alert_count" -gt 0 ]]; then
  if [[ -f "$state_file" ]]; then
    # don't alert if we haven't had a check that wasn't an alert yet
    echo "✅ Already posted. Skipping."
    exit 0
  fi
  echo "There is a storm coming!"
  curl "$HOOK_URL" -H "$curl_header" --data "$gif_message"
  curl "$HOOK_URL" -H "$curl_header" --data "$detail_message"
  echo "alert_fired" > "$state_file"  # ✅ Record the alert was sent
else
  echo "🌤 There is not a storm coming."
  rm -f "$state_file" #the previously established alert is over
fi
