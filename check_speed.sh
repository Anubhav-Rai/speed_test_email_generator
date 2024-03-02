#!/bin/bash

# Set DISPLAY
export DISPLAY=":0"

# Attempt to set the DBUS_SESSION_BUS_ADDRESS environment variable
# This is for a user logged into the graphical environment
export DBUS_SESSION_BUS_ADDRESS=$(grep -z DBUS_SESSION_BUS_ADDRESS /proc/$(pgrep -u ar -n gnome-session | head -n 1)/environ | cut -d= -f2-)

# Define speed thresholds (in Mbps)
DOWNLOAD_THRESHOLD=200
UPLOAD_THRESHOLD=100

# Get the current date and time.
now=$(date +"%Y-%m-%d %H:%M:%S")

# Run speedtest-cli and capture its output.
result=$(speedtest-cli --simple)

# Extract download and upload speeds using grep and awk
download_speed=$(echo "$result" | grep "Download" | awk '{print $2}')
upload_speed=$(echo "$result" | grep "Upload" | awk '{print $2}')

# Append the date, time, and speedtest results to a file.
echo "Test conducted at: $now" >> /home/ar/anrai/cs/speedtest_cronjob/speedtest_results.txt
echo "$result" >> /home/ar/anrai/cs/speedtest_cronjob/speedtest_results.txt
echo "---------------------------------" >> /home/ar/anrai/cs/speedtest_cronjob/speedtest_results.txt

# For download speed warning
if (( $(echo "$download_speed < $DOWNLOAD_THRESHOLD" | bc -l) )); then
    notify-send "Speedtest Warning" "Download speed ($download_speed Mbps) is below threshold."
fi

# For upload speed warning
if (( $(echo "$upload_speed < $UPLOAD_THRESHOLD" | bc -l) )); then
    notify-send "Speedtest Warning" "Upload speed ($upload_speed Mbps) is below threshold."
fi

expected_speed=100 # Expected minimum speed in Mbps

if [ $(echo "$download_speed < $DOWNLOAD_THRESHOLD" | bc) -eq 1 ]; then
  # Send an alert email
  subject="Alert: Low Internet Speed Detected"
  body="Hi This is anubhav rai and this is my registered mail with the monile number 7015431317 having 300 Mbps plan. The current download speed is $download_speed Mbps, which is quite significantly below the expected 300 Mbps."
  recipient="121@in.airtel.com"
  recipient2="cmpptrscnc@gmail.com"

  echo "$body" | mail -s "$subject" "$recipient"
  echo "$body" | mail -s "$subject" "$recipient2"
fi
