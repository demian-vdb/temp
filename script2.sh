touch /home/vagrant/.pgpass
chown vagrant:vagrant /home/vagrant/.pgpass
echo *:*:*:synapse_user:password >> /home/vagrant/.pgpass
chmod 0600 /home/vagrant/.pgpass

#get ROOM_ID and the ACCESS_TOKEN from Admin
TOKEN=$(sudo -u vagrant -E psql -U synapse_user -d synapse --no-align --tuples-only -c " SELECT token FROM access_tokens WHERE user_id='@admin:theoracle.thematrix.local' AND used='t';")
ROOM_ID=$(sudo -u vagrant -E psql -U synapse_user -d synapse --no-align --tuples-only -c "SELECT room_id FROM rooms WHERE creator='@admin:theoracle.thematrix.local'")
#Create and configure the shutdown script

wget -P /usr/lib/systemd/system-shutdown https://github.com/demian-vdb/temp/raw/main/shutdown_script.sh

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

