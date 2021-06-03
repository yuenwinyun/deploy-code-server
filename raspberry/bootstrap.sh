#!/bin/bash

WIFI_ID="${WIFI_ID:-''}"
WIFI_PASSWORD="${WIFI_PASSWORD:-''}"
USB_DRIVE="${1:-''}"

# enable ssh
touch "$USB_DRIVE/ssh"

network_config=$(
  cat <<-END
network={
  ssid=$WIFI_ID
  psk=$WIFI_PASSWORD
}
END
)

echo "$network_config" >>"$USB_DRIVE/wpa_supplicant.conf"
