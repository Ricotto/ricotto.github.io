#!/bin/bash

# ZephyrStatusCOX.sh
# rnepil 2024-03-10


# set timezone
TZ=US/Pacific

#  Create /home/<user>/Zephyr.html in advance


# functions ###########################################

function download_webData(){
  # Download URL output to variable for parsing
  webData=$(curl -s 'https://railrat.net/stations/COX/')
  lastupdateDate=$(date)
}

function HTMLtotext(){
  #
  webData=$(echo "$webData" | sed 's/more_vert//g')        # Remove more_vert reference
  webData=$(echo "$webData" | sed 's|&nbsp;| |g')         # Remove
  webData=$(echo "$webData" | sed 's/<[^>]*>//g')
}

function dbug_webData(){
  #
   echo ".. webData         ......................"
#  echo "$webData"
   echo ".. webDataArriving ......................"
   echo "$webDataArriving"
   echo ".. webDataDeparted ......................"
   echo "$webDataDeparted"
   echo ".. finalData ............................"
   echo "$finalData"
   echo "........................................."
   read pause
}

function clean_webData(){
  # Parse web output

     # Remove more_vert reference and other crap

#    webData=$(echo "$webData" | sed 's/\xc2\xa0/ /g')        # Remove
#    webData=$(echo "$webData" | tr -cd '\11\12\15\40-\176')  # Delete non-printable characters

     # Search and replace to make more user friendly
     webData=$(echo "$webData" | sed 's/on tm/ON TIME/')
     webData=$(echo "$webData" | sed 's/lt/LATE/g')
     webData=$(echo "$webData" | sed 's/Ar est./Estimated arrival:/')
     webData=$(echo "$webData" | sed 's/Ar act./Actual arrival:/')
     webData=$(echo "$webData" | sed 's/Dp sch./Scheduled departure:/')
     webData=$(echo "$webData" | sed 's/act./Actual:/')
     webData=$(echo "$webData" | sed 's/&rarr;/->/')
     webData=$(echo "$webData" | sed 's/Scheduled/ Scheduled/')

     webData=$(echo "$webData" | sed 's/\]E/\] E/')
     webData=$(echo "$webData" | sed 's/\]A/\] A/')
     webData=$(echo "$webData" | sed '/^[[:space:]]*$/d')                 # Remove empty lines

     # Arriving: Capture output between Arriving and Departed, do not include patterns
     webDataArriving=$(echo "$webData" | sed "/Arriving/,/Departed/!d;//d")

     # Departed: Capture output between Departed and Useful, do not include patterns
     webDataDeparted=$(echo "$webData" | sed "/Departed/,/Useful/!d;//d")

     # Concatenate Arriving and Departed
     finalData=$(echo -e "Arriving:\n$webDataArriving\n\nDeparted:\n$webDataDeparted")
}

function createHTML(){
  # touch index.html to initially create file

     webDataArriving=$(echo "$webDataArriving" | sed 's/\] E/\]\<br\>  E/')
     webDataArriving=$(echo "$webDataArriving" | sed 's/\] A/\]\<br\>  A/')
     webDataDeparted=$(echo "$webDataDeparted" | sed 's/\] E/\]\<br\>  E/')
     webDataDeparted=$(echo "$webDataDeparted" | sed 's/\] A/\]\<br\>  A/')

cat > /home/mumbo/ricotto.github.io/index.html << EOF
     <!DOCTYPE html>
     <html>
     <head>
       <title>California Zephyr</title>
     </head>
     <body>
     <pre>
        <h2>Updated: $lastupdateDate</h2>
        <h2>Arriving to Colfax:<br>$webDataArriving</h2>
#        <h2>Departed from Colfax:<br>$webDataDeparted</h2>
     </pre>
     </body>
   </html>
EOF
}

function pushoverFinal(){
     # Send output to PushOver
       curl -s -F "token=<token>" \
      -F "user=<user>" \
      -F "title=Colfax: California Zephyr" \
      -F "message=$finalData" https://api.pushover.net/1/messages.json
}

function outputFinal(){
     # Send output to console (for debug)
       echo " "
       echo "Updated: $lastupdateDate"
       echo "Arrivals:"
       echo "$webDataArriving"
       echo "Departures:"
       echo "$webDataDeparted"
}


# Main ==================================================================

# Call functions
  download_webData
  HTMLtotext
  clean_webData
# dbug_webData
# pushoverFinal
  outputFinal
  createHTML


