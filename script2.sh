touch /home/vagrant/.pgpass
chown vagrant:vagrant /home/vagrant/.pgpass
echo *:*:*:synapse_user:password >> /home/vagrant/.pgpass
chmod 0600 /home/vagrant/.pgpass

#get ROOM_ID and the ACCESS_TOKEN from Admin
TOKEN=$(sudo -u vagrant -E psql -U synapse_user -d synapse --no-align --tuples-only -c " SELECT token FROM access_tokens WHERE user_id='@admin:theoracle.thematrix.local' AND used='t';")
ROOM_ID=$(sudo -u vagrant -E psql -U synapse_user -d synapse --no-align --tuples-only -c "SELECT room_id FROM rooms WHERE creator='@admin:theoracle.thematrix.local'")

#Create and configure the shutdown script
touch /usr/lib/systemd/system-shutdown/shutdown_script.sh

echo '#!/bin/bash
sudo /home/vagrant/synapse/env/bin/synctl start /home/vagrant/synapse/homeserver.yaml
curl --header "Authorization: Bearer '$TOKEN'" \
     --header "Content-Type: application/json" \
     --request POST \
     --data '\''{
        "msgtype": "m.text",
        "body": "Server is shutting down in 30 seconds"
     }'\'' \
     http://localhost:8008/_matrix/client/r0/rooms/\'$ROOM_ID'/send/m.room.message' > /usr/lib/systemd/system-shutdown/shutdown_script.sh

chmod u+x /usr/lib/systemd/system-shutdown/shutdown_script.sh

touch /etc/systemd/system/execute-before-shutdown.service

echo '[Unit]
Description=My Script
DefaultDependencies=no
Before=shutdown.target

[Service]
ExecStart=/bin/bash -c "sleep 15 && /usr/lib/systemd/system-shutdown/shutdown_script.sh"

[Install]
WantedBy=shutdown.target' > /etc/systemd/system/execute-before-shutdown.service


systemctl daemon-reload
systemctl enable execute-before-shutdown.service

echo "Acces_token: $TOKEN"
echo "Room_ID: $ROOM_ID"
echo ""

cat /usr/lib/systemd/system-shutdown/shutdown_script.sh

