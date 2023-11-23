#!/usr/bin/env bash

# Prompt user
echo "Please Enter your sudo password!"

# sudo echo so it always propts here
sudo echo

# Delete old version
if [ -f "/usr/bin/genpwd" ]; then
    sudo rm "/usr/bin/genpwd"
fi
if [ -f "/usr/bin/genpwd.sh" ]; then
    sudo rm "/usr/bin/genpwd.sh"
fi

# Define the directory to check
DIR="/usr/bin"

# Check if the directory exists, create if not
if [ ! -d "$DIR" ]; then
    echo "$DIR does not exist. Creating directory..."
    mkdir -p "$DIR"
fi

# Download Latest Version
sudo wget -O "/usr/bin/genpwd" "https://raw.githubusercontent.com/CortezJEL/genpwd/main/genpwd.sh"

# Make latest version rnable
sudo chmod +x /usr/bin/genpwd

# Function to check and add directory to PATH in a given file
check_and_add_to_file() {
    local file=$1
    # Check if the file contains the directory in the PATH
    if grep -q "export PATH=.*$DIR" "$file"; then
        echo "$DIR is already in the PATH in $file"
    else
        echo "Adding $DIR to $file"
        echo "export PATH=\"$DIR:\$PATH\"" >> $file
    fi
}

# Check and modify .zshrc
[ -f "$HOME/.zshrc" ] && check_and_add_to_file "$HOME/.zshrc"

# Check and modify .bashrc
[ -f "$HOME/.bashrc" ] && check_and_add_to_file "$HOME/.bashrc"

echo "Installation complete!"