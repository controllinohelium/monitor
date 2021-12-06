#!/bin/bash

# MONITOR A
# PKTFWD
# Check what Packet Forwarder is doing and attempt rescues

# CHECK IF PKTFWD IS OK
if sudo systemctl status lora_pkt_fwd.service | grep -q 'active'; then
  echo "PKTFWD - STATUS OK"
else

# STATUS 1
  echo "PKTFWD - STATUS 1 - Not running, trying to restart"
  docker stop miner
  sudo systemctl disable lora_pkt_fwd.service
  sudo systemctl enable lora_pkt_fwd.service
  sudo systemctl start lora_pkt_fwd.service
  docker start miner
  
# STATUS 2
  if sudo systemctl status lora_pkt_fwd.service | grep -q 'active'; then
    echo "PKTFWD - OK - After STATUS 1 Restart"
  else
    echo "PKTFWD - STATUS 2 - Still not running after restart attempt. Trying once again with a bit more force..."
    docker stop miner
    sudo systemctl disable lora_pkt_fwd.service
    sudo systemctl daemon-reload
    sudo systemctl enable lora_pkt_fwd.service
    sudo systemctl daemon-reload
    sudo systemctl start lora_pkt_fwd.service
    docker start miner
    
# STATUS 3
    if sudo systemctl status lora_pkt_fwd.service | grep -q 'active'; then
    echo "PKTFWD - OK - After STATUS 2 Restart"
    else
      echo "PKTFWD - STATUS 3 - Packet forwarder having difficulties to start up. Remove and reinstall initiated..."
      echo "TODO"
    fi
    
  fi
  
fi

