#!/usr/bin/env bash

# Set directory to install genpwd to
DIR="$HOME/.config/genpwd"

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
        \rm -f "$DIR/genpwd"
    elif [ -f "$DIR/genpwd.sh" ]; then
        \rm -f "$DIR/genpwd.sh"
    elif [ -f "/usr/bin/genpwd" ]; then
        sudo \rm /usr/bin/genpwd
    elif [ -f "/usr/bin/genpwd.sh" ]; then
        sudo \rm /usr/bin/genpwd.sh
    fi

}

# Install latest version
installlatest() {

    if command -v axel &> /dev/null; then
        # Download with axel
        sudo axel -q -o "$DIR/genpwd" "https://github.com/NanashiTheNameless/genpwd/raw/refs/heads/main/genpwd.sh"
    else
        # Check if wget is installed
        command -v wget >/dev/null 2>&1 || { echo >&2 "wget is required but it's not installed. Aborting." ; exit 1 ; }
        echo "------------------------------------------------"
        echo "Try Installing axel for faster download speed!"
        echo "------------------------------------------------"
        # Download with wget as a fallback
        sudo wget -q -O "$DIR/genpwd" "https://github.com/NanashiTheNameless/genpwd/raw/refs/heads/main/genpwd.sh"
    fi

    # Make latest version runable
    sudo chmod +x "$DIR/genpwd"

}

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
