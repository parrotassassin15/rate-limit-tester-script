#!/bin/bash

# get user input
URL=$1

# if url is not set output usage
if [ -z "$URL" ]; then
    echo "[!] Usage: rate-limit-tester.sh <domain>"
    exit 0
fi

# variables
TOTAL_REQUESTS=500
TIME_LIMIT=50
START_TIME=$(date +%s)
REQUEST_COUNT=0
END_TIME=$((START_TIME + TIME_LIMIT))
RATE_LIMITED=false

# set colors for terminal and results ouput 
red=$(tput setaf 1)
white=$(tput setaf 7)
green=$(tput setaf 2)
blue=$(tput setaf 4)

# array to store response codes
declare -a RESPONSE_CODES

# loop to send requests
while [ $REQUEST_COUNT -lt $TOTAL_REQUESTS ] && [ $(date +%s) -lt $END_TIME ]; do
    RESPONSE_CODE=$(curl -o /dev/null -s -w "%{http_code}" "$URL")
    RESPONSE_CODES+=("$RESPONSE_CODE")
    REQUEST_COUNT=$((REQUEST_COUNT + 1))
    echo "Request $REQUEST_COUNT sent with response code: $RESPONSE_CODE"

    # check if online 
    if [ "$RESPONSE_CODE" == "000" ]; then
        echo "${red}[!] Check if you are online, cannot connect properly"
        exit 0
    fi
    
    # check if rate limiting is detected (response code 429)
    if [ "$RESPONSE_CODE" == "429" ]; then
        RATE_LIMITED=true
        echo "${red}Rate limit implemented (response code 429 detected). Stopping test...${white}"
        break
    fi
done

END_TIME_ACTUAL=$(date +%s)

# output results
echo "------------------- RESULTS ---------------------"
echo "${blue}[-] Results for: $URL${white}"
echo "${green}[-] Total requests sent: $REQUEST_COUNT${white}"
echo "${white}[-] Start time: $(date -d @$START_TIME)${white}"
echo "${white}[-] End time: $(date -d @$END_TIME_ACTUAL)${white}"
ELAPSED_TIME=$((END_TIME_ACTUAL - START_TIME))
echo "[-] Elapsed time: $ELAPSED_TIME seconds"

if [ "$RATE_LIMITED" = true ]; then
    echo "${green}[+] Rate limiting was implemented${white}"
else
    echo "${red}[!] Rate limit not implemented${white}"
fi
