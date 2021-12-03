#!/bin/bash

# Monitor for Dashboard

if sudo pm2 status | grep -q 'online'; then
  echo "Dashboard online, all good."
else
  echo "Dashboard offline, starting..."
  cd /home/pi/hotspot_diagnostics
  sudo pm2 start index.js
  sudo pm2 save
fi

# Montior for Lora Pkt Fwd

if sudo systemctl status lora_pkt_fwd.service | grep -q 'active'; then
  echo "Packet forwarder online, all good."
else
  echo "Packet forwarder offline, starting..."
  docker stop miner
  sudo systemctl enable lora_pkt_fwd.service
  sudo systemctl start lora_pkt_fwd.service
  docker start miner
fi
