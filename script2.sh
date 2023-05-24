touch /home/vagrant/.pgpass
chown vagrant:vagrant /home/vagrant/.pgpass
echo *:*:*:synapse_user:password >> /home/vagrant/.pgpass
chmod 0600 /home/vagrant/.pgpass

#get ROOM_ID and the ACCESS_TOKEN from Admin
TOKEN=$(sudo -u vagrant -E psql -U synapse_user -d synapse --no-align --tuples-only -c " SELECT token FROM access_tokens WHERE user_id='@Admin:theoracle.thematrix.local' AND used='t';")
ROOM_ID=$(sudo -u vagrant -E psql -U synapse_user -d synapse --no-align --tuples-only -c "SELECT room_id FROM rooms WHERE creator='@Admin:theoracle.thematrix.local'")

#Create and configure the shutdown script
touch /usr/lib/systemd/system-shutdown/shutdown_script.sh

echo '#!/bin/bash
sleep 15

curl --header "Authorization: Bearer '$TOKEN'" \
     --header "Content-Type: application/json" \
     --request POST \
     --data '\''{
        "msgtype": "m.text",
        "body": "Server is shutting down in 30 seconds"
     }'\'' \
     http://localhost:8008/_matrix/client/r0/rooms/'$ROOM_ID'/send/m.room.message

sleep 30
' > /usr/lib/systemd/system-shutdown/shutdown_script.sh

chmod u+x /usr/lib/systemd/system-shutdown/shutdown_script.sh

touch /etc/systemd/system/execute-before-shutdown.service

echo '[Unit]
Description=Execute custom script before system poweroff
DefaultDependencies=no
Before=shutdown.target 

[Service]
Type=oneshot
ExecStart=/usr/lib/systemd/system-shutdown/shutdown_script.sh
TimeoutStartSec=0

[Install]
WantedBy=shutdown.target' > /etc/systemd/system/execute-before-shutdown.service


systemctl daemon-reload
systemctl enable execute-before-shutdown.service

