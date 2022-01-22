#!/bin/bash

# MONITOR A - PKTFWD
echo "PKTFWD - Check what Packet Forwarder is doing and attempt rescues if something is off."

# CHECK IF PKTFWD IS ALIVE
if sudo systemctl status lora_pkt_fwd.service | grep -q 'active'; then
  echo "PKTFWD - OK"
else

# STATUS 1
  echo "PKTFWD - STATUS 1 - Not running, attempting to restart..."
  docker stop miner
  sudo systemctl disable lora_pkt_fwd.service
  sudo systemctl enable lora_pkt_fwd.service
  sudo systemctl start lora_pkt_fwd.service
  docker start miner
  sleep 10
  
# STATUS 2
  if sudo systemctl status lora_pkt_fwd.service | grep -q 'active'; then
    echo "PKTFWD - OK - After STATUS 1 Restart"
  else
    echo "PKTFWD - STATUS 2 - Still not running after restart attempt. Trying once again with slightly more force..."
    docker stop miner
    sudo systemctl disable lora_pkt_fwd.service
    sudo systemctl daemon-reload
    sudo systemctl enable lora_pkt_fwd.service
    sudo systemctl daemon-reload
    sleep 1
    sudo systemctl start lora_pkt_fwd.service
    docker start miner
    sleep 15
    
# STATUS 3
    if sudo systemctl status lora_pkt_fwd.service | grep -q 'active'; then
    echo "PKTFWD - OK - After STATUS 2 Restart"
    else
      echo "PKTFWD - STATUS 3 - Packet forwarder having difficulties to start up. Removal and re-install started..."
      sudo systemctl disable lora_pkt_fwd.service
      sudo rm /etc/systemd/system/lora_pkt_fwd.service
      sudo cp /home/pi/monitor/replacements/lora_pkt_fwd.service /etc/systemd/system
      echo "PKTFWD - STATUS 3 - Removed and replaced service file. Lets start it up..."
      sudo systemctl enable lora_pkt_fwd.service
      sudo systemctl start lora_pkt_fwd.service
      sleep 1
      if sudo systemctl status lora_pkt_fwd.service | grep -q 'active'; then
      echo "PKTFWD - OK - After STATUS 3 Removal and re-install"
      else
        echo "PKTFWD - ERROR - Selfhealing failed, please contact our Maintenance Team at helium@controllino.com together with your MAC Adress to do a remote check-up on your device."
      fi
      
    fi
  fi
fi

# MONITOR B - MINER
echo "MINER - Check what the Grande Dame is doing and give it some kicks if it is picky."

# CHECK IF MINER IS ALIVE
if docker ps | grep -q 'miner'; then
  echo "MINER - OK"
else
  
# STATUS 1
echo "MINER - STATUS 1 - Not running, attempting to restart..."
# TODO
fi

# MONITOR C - CLEAR SPACE
if [ "$(df -h /home/pi/miner_data/ | tail -1 | awk '{print $5}' | tr -d '%')" -ge 70 ]; then
    sudo rm -rf /home/pi/miner_data/*
    sudo /home/pi/gateway_addons/instasync.sh force
fi





