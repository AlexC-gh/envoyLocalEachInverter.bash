#!/bin/bash
#
# user is "enovy"
# password is the last 6 digits of the envoy serial number
ENVOY_USER=$ENVOY_USER
ENVOY_PASSWORD=$ENVOY_PASSWORD
ENVOY_HOST=$ENVOY_HOST
ENVOY_API_ENDPOINT="api/v1/production/inverters"
INFLUX_DB=$INFLUX_DB
INFLUX_MEASUREMENT=$INFLUX_MEASUREMENT



inverterReadings=`curl -s --digest --user $ENVOY_USER:$ENVOY_PASSWORD "http://$ENVOY_HOST/$ENVOY_API_ENDPOINT"`
while read sn 
      read lastwatt
      read maxwatt
      read devtype 
      read lastReportDate; do

        #echo Serial: $sn
        #echo LastWatt: $lastwatt
        #echo MaxWatt: $maxwatt
        #echo DevType: $devType 
        #echo EpochDate: $lastReportDate
        #ns_date=$(date -d @$lastReportDate '+%s%N')
        #echo DB $INFLUX_DB
        #echo Measurement $INFLUX_MEASUREMENT
        #echo $ns_date
        
     influx -execute "insert $INFLUX_MEASUREMENT,sn=$sn lastReportWatts=$lastwatt,maxReportWatts=$maxwatt,devType=$devtype $ns_date" -database=$INFLUX_DB
   
done < <(jq -rc '.[]| .serialNumber,.lastReportWatts,.maxReportWatts,.devType,.lastReportDate'<<< "$inverterReadings")

