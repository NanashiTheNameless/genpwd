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
        echo "Removing old version $DIR/genpwd"
        \rm -f "$DIR/genpwd"
    elif [ -f "$DIR/genpwd.sh" ]; then
        echo "Removing old version $DIR/genpwd.sh"
        \rm -f "$DIR/genpwd.sh"
    elif [ -f "/usr/bin/genpwd" ]; then
        echo "Removing old version /usr/bin/genpwd"
        sudo \rm /usr/bin/genpwd
    elif [ -f "/usr/bin/genpwd.sh" ]; then
        echo "Removing old version /usr/bin/genpwd.sh"
        sudo \rm /usr/bin/genpwd.sh
    fi

}

# Install latest version
installlatest() {
    if command -v axel &> /dev/null; then
        # Download with axel
        echo "Now downloading latest version of genpwd with axel!"
        axel -q -o "$DIR/genpwd" "https://github.com/NanashiTheNameless/genpwd/raw/refs/heads/No-Swear/genpwd.sh"
    else
        # Check if wget is installed
        command -v wget >/dev/null 2>&1 || { echo >&2 "wget is required but it's not installed. Aborting." ; exit 1 ; }
        echo "Now downloading latest version of genpwd with wget!"
        echo "-----------------------------------------------------------------------------"
        echo 'Try Installing axel for faster download speed! (And easier syntax than wget!)'
        echo "-----------------------------------------------------------------------------"
        # Download with wget as a fallback
        wget -q -O "$DIR/genpwd" "https://github.com/NanashiTheNameless/genpwd/raw/refs/heads/No-Swear/genpwd.sh"
    fi

    # Make latest version runable
    if [ ! -x "$DIR/genpwd" ]; then
        echo "$DIR/genpwd is not executable. Attempting to add execute permission."
        chmod +x "$DIR/genpwd"
        if [ ! -x "$DIR/genpwd" ]; then
            echo "$DIR/genpwd is not executable after trying to add permissions, now trying with sudo."
            sudo chmod +x "$DIR/genpwd"
            if [ ! -x "$DIR/genpwd" ]; then
                echo "$DIR/genpwd is still not executable after trying to add permissions with sudo. Something is very wrong, This likely needs to be fixed manually!"
                echo "Try running \"sudo chmod +x $DIR/genpwd\" or \"chmod +x $DIR/genpwd\" as root"
                echo "(GenPWD will still be added to your \$PATH variable)"
                handlepath
                exit 1
            else
                echo "$DIR/genpwd is now executable."
            fi
        else
            echo "$DIR/genpwd is now executable."
        fi
    else
        echo "$DIR/genpwd is already executable."
    fi
}

# Handle the Implementation of PATH
handlepath() {
    # Check and modify .zshrc
    [ -f "$HOME/.zshrc" ] && check_and_add_to_file "$HOME/.zshrc"

    # Check and modify .bashrc
    [ -f "$HOME/.bashrc" ] && check_and_add_to_file "$HOME/.bashrc"
}

# Check if the directory exists, create if not
makedir

# Delete old version
removeold

# Install latest version
installlatest

# Handle the Implementation of PATH
handlepath

# Announce completion
echo "Installation complete!"
