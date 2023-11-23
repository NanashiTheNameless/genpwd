#!/usr/bin/env bash

# Prompt user
echo "Please Enter your sudo password for installation!"

# Delete old version
if [ -f "/usr/bin/genpwd" ]; then
    sudo rm "/usr/bin/genpwd"
fi
if [ -f "/usr/bin/genpwd.sh" ]; then
    sudo rm "/usr/bin/genpwd.sh"
fi

# Download Latest Version
sudo wget -O "/usr/bin/genpwd" "https://raw.githubusercontent.com/CortezJEL/genpwd/main/genpwd.sh"

# Make latest version rnable
sudo chmod +x /usr/bin/genpwd

echo "Installation complete!"
