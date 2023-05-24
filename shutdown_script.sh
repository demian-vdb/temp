#!/bin/bash
DATETIME=$(date +"%H:%M %B %d %Y")
sudo /home/vagrant/synapse/env/bin/synctl start /home/vagrant/synapse/homeserver.yaml
curl --header "Authorization: Bearer syt_YWRtaW4_wXfxEsRjDDMJumFOtAtu_3mFLdK" \
     --header "Content-Type: application/json" \
     --request POST \
     --data "{
        \"msgtype\": \"m.text\",
        \"body\": \"The server went down at $DATETIME\"
     }" \
     http://localhost:8008/_matrix/client/r0/rooms/\!IbGCewvIruVvEWzKmG:theoracle.thematrix.local/send/m.room.message