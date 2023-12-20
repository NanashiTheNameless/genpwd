#!/usr/bin/env bash

# Prompt user
echo "Please Enter your sudo password!"

# Sudo echo so it always propts here
sudo echo

# Function to check and add directory to PATH in a given file
check_and_add_to_file() {
    local file=$1
    # Check if the file contains the directory in the PATH
    if grep -q "export PATH=.*$DIR" "$file"; then
        echo "$DIR is already in the PATH in $file"
    else
        echo "Adding $DIR to $file"
        echo "export PATH=\"$DIR:\$PATH\"" >> "$file"
    fi
}

# Determine os and set install directory
getdir() {
    # Grab os from uname
    SYSTEMTYPE=$(uname -s)

    # Define directory
    if [ "$SYSTEMTYPE" = "Darwin" ]; then
        # Define the directory to install to
        DIR="$HOME/.config/genpwd"
    else [ "$SYSTEMTYPE" = "Linux" ]; 
        # Define the directory to install to
        DIR="/usr/bin"
    fi
}

# Make install directory if it exists
makedir() {
    # Check if the directory exists, create if not
    if [ ! -d "$DIR" ]; then
        echo "$DIR does not exist. Creating directory..."
        mkdir -p "$DIR"
    fi
}

# Remove old version(s) if they exist
removeold() {
    # Delete old version
    if [ -f "$DIR/genpwd" ]; then
        sudo rm -f "$DIR/genpwd"
    else [ -f "$DIR/genpwd.sh" ]; 
        sudo rm -f "$DIR/genpwd.sh"
    fi
}

# Install latest version
installlatest() {
    # Download Latest Version
    sudo wget -O "$DIR/genpwd" "https://raw.githubusercontent.com/CortezJEL/genpwd/main/genpwd.sh"

    # Make latest version runable
    sudo chmod +x "$DIR/genpwd"
}

# Determine os and set install directory
getdir

# Check if the directory exists, create if not
makedir

# Delete old version
removeold

# Install latest version
installlatest

# Check and modify .zshrc
[ -f "$HOME/.zshrc" ] && check_and_add_to_file "$HOME/.zshrc"

# Check and modify .bashrc
[ -f "$HOME/.bashrc" ] && check_and_add_to_file "$HOME/.bashrc"

# Anounce completion
echo "Installation complete!"