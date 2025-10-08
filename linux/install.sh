#!/bin/bash

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run this script as root."
  exit 1
fi

# Step 1: Initialize variables
source variables.sh
mkdir -p "/etc/halofort"

# Step 2: Install the executables
echo "Copying config files..."
for file in "./config"/*; do
  echo "Copying ${file}..."
  cp "${file}" "/etc/halofort/${file##*/}"
done

# Step 3: Install the executables
echo ""
echo "Installing the executables..."
for artifact in "${ARTIFACTS[@]}"; do
  echo ""
  echo "Installing ${artifact}..."
  cp "./artifacts/${artifact}" "/usr/local/bin/${artifact}"
  chmod +x "/usr/local/bin/${artifact}"

  SERVICE_FILE="/etc/systemd/system/${artifact}.service"
  echo "Creating systemd service file..."
  cat <<EOF > "$SERVICE_FILE"
  [Unit]
  Description=$artifact
  After=network.target

  [Service]
  ExecStart=/usr/local/bin/${artifact} ${PARAMETERS}
  Restart=always
  RestartSec=5
  StartLimitIntervalSec=60
  StartLimitBurst=3
  User=root
  Group=root

  [Install]
  WantedBy=multi-user.target
EOF

done

# Step 4: Reload systemd, enable, and start the service
echo ""
echo "Reloading systemd daemon..."
systemctl daemon-reload

# Step 5: Enable and start the service
echo ""
echo "Enabling and starting the service..."
for artifact in "${ARTIFACTS[@]}"; do
  systemctl enable "$artifact"
  systemctl start "$artifact"
done

echo ""
echo "Setup complete!"
