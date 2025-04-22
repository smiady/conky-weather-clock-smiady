#!/bin/bash

source weather_functions.sh

API_URL=https://api.openweathermap.org/data/2.5/forecast
FILE_FORECAST_JSON=cache/weather_forecast.json

download_weather $API_URL $FILE_FORECAST_JSON

WEATHER_FORECAST=()

function get_weather_forecast() {
	for (( i = 0; i < 4; ++i )); do
		DATE=$(date -d '+'$(( i + 1 ))'days' '+%Y-%m-%d')
		
		FILTERED_WEATHER_DATA=$(jq '[.list[] | select(.dt_txt | startswith("'$DATE'"))] | sort_by(.main.temp) | reverse | .[0] | .weather[0].icon, .main.temp' $FILE_FORECAST_JSON)
		readarray -t FILTERED_WEATHER_DATA_ARRAY <<< "$FILTERED_WEATHER_DATA"
		
		ICON=${FILTERED_WEATHER_DATA_ARRAY[0]:1:-1}
		TEMP=$(echo ${FILTERED_WEATHER_DATA_ARRAY[1]} | awk '{print int($1+0.5)}')
		DAY=$(date -d '+'$(( i + 1 ))'days' '+%a')
		
		if (( i == 0 )); then
			DAY=tmw
		else
			DAY=$(map_day $DAY)
		fi
		
		WEATHER_FORECAST[$i]=$ICON' '$TEMP' '$DAY
	done
}

function print_weather_forecast() {
	WEATHER_FORECAST_LENGTH=${#WEATHER_FORECAST[@]}
	BLOCK_WIDTH=$((400/WEATHER_FORECAST_LENGTH))
	RETURN=""
	TEXT=""
	GO_TO=0
	
	if [[ $1 == 1 ]]; then
		RETURN='${color}${voffset 10}'
	elif [[ $1 == 2 ]]; then
		RETURN='${voffset -5}'
	fi
	
	for (( i = 0; i < $WEATHER_FORECAST_LENGTH; ++i )); do
		read -a VALUES <<< "${WEATHER_FORECAST[$i]}"

		ICON=$(map_icon ${VALUES[0]})
		TEMPERATURE=${VALUES[1]}
		DAY=${VALUES[2]}

		if [[ $1 == 1 ]]; then
			GO_TO=$((BLOCK_WIDTH * i + BLOCK_WIDTH / 2 - 9))
			TEXT='${font WeatherGothamCity:pixelsize=22}'$ICON
		elif [[ $1 == 2 ]]; then
			GO_TO=$((BLOCK_WIDTH * i + BLOCK_WIDTH / 2 - (${#TEMPERATURE} + 3 + ${#DAY}) * 2 - 10))
			TEXT='${font Bariol Clock:pixelsize=16}${color1}'$TEMPERATURE'°C ${color}'$DAY
		fi
	
		RETURN=$RETURN'${goto '$GO_TO'}'$TEXT
	done
	
	echo $RETURN
}

function map_day() {
	case $1 in
		Mon) echo 'mo' ;;
		Tue) echo 'tu' ;;
		Wed) echo 'we' ;;
		Thu) echo 'th' ;;
		Fri) echo 'fr' ;;
		Sat) echo 'sa' ;;
		Sun) echo 'su' ;;
		
		*) echo $1
	esac	
}

get_weather_forecast

print_weather_forecast 1
print_weather_forecast 2
