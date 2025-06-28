# 📦 Raycast Script: Installed Apps Summary

This Raycast script lists all installed macOS apps, copies the names to your clipboard, and shows a notification summarizing how many were installed in the current and previous year.

## 💡 Why This Is Useful

Ever find yourself wondering *“Do I already have an app installed that can do this?”*

I use this script when I need to do something like:
- Batch rename files  
- Convert videos to audio  
- Extract text from PDFs  
- Or do any random task I think I might already have an app for (but can't remember)...

Instead of digging through Finder, I run this script to generate a full list of my installed apps — it gets copied to the clipboard instantly. Then I paste that list into ChatGPT and ask:

> “Which of these apps can [do the task]?”

It’s a great way to rediscover what’s already on your system and avoid unnecessary downloads.

---

## 📋 What It Does

- Scans apps in `/Applications` and `~/Applications`
- Copies app names to your clipboard (alphabetically sorted)
- Displays a notification showing:
  - ✅ Total number of apps
  - 📆 How many were modified (installed) **this year**
  - 📆 How many were modified **last year**

---

## 🛠 How to Set It Up in Raycast

### 1. Open Raycast

- In settings, click the **+** button 
- Select **"Create Script Command"**

### 2. Fill in the Details

| Field             | Value                                                  |
|------------------|--------------------------------------------------------|
| **Template**      | Bash                                                   |
| **Mode**          | Silent                                                 |
| **Title**         | Installed Apps Summary                                 |
| **Description**   | Copies installed app names to clipboard and shows stats |
| **Package Name**  | *(Optional — e.g., `Utilities`)*                       |

Click **"Create Script Command"** to generate the file.

---

### 3. Replace the Script Contents

Oprn the new script in a text editor. Replace its contents with the following:

```bash
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

# Show notification
message="${total_count} total apps
📆 Installed in $year_now: $count_now
📆 Installed in $year_prev: $count_prev"

osascript -e "display notification \"$message\" with title \"Raycast: Apps copied\" sound name \"Glass\""
