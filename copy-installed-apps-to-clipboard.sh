#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Installed apps summary
# @raycast.mode silent

# Optional parameters:
# @raycast.icon 🤖

# Documentation:
# @raycast.description Copies installed app names to clipboard and shows install stats by year.
# @raycast.author jonbstrong
# @raycast.authorURL https://raycast.com/jonbstrong

folders=("/Applications" "$HOME/Applications")
year_now=$(date +%Y)
year_prev=$((year_now - 1))

count_now=0
count_prev=0

# Find and sort app names
all_apps=$(find "${folders[@]}" -maxdepth 1 -name "*.app")
app_names=$(echo "$all_apps" | sed 's:.*/::; s:.app$::' | sort)
echo "$app_names" | pbcopy
total_count=$(echo "$app_names" | wc -l | tr -d ' ')

# Count apps by year
while IFS= read -r app; do
  mod_year=$(date -r "$(stat -f "%m" "$app")" +%Y)
  [[ "$mod_year" == "$year_now" ]] && ((count_now++))
  [[ "$mod_year" == "$year_prev" ]] && ((count_prev++))
done <<< "$all_apps"

# Build notification message
message="🔢 Total apps: ${total_count}
📆 Installed in $year_now: $count_now
📆 Installed in $year_prev: $count_prev"

# Show notification
osascript -e "display notification \"$message\" with title \"Raycast script: apps copied → clipboard\" sound name \"Glass\""