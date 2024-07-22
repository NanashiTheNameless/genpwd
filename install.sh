#!/usr/bin/env bash

# DO NOT USE "HasSudo=false" IN THE FILE it will break users being able to override

# Check if user is in the sudo or wheel group
# And attempt to validate sudo access by running `sudo -v`
# Note: We're using `sudo -v` in a way that doesn't produce output to avoid needing to capture it
if [ -n "$(groups $USER | grep -E 'sudo|wheel|sudoers')" ] || sudo -v >/dev/null 2>&1; then
    HasSudo=true
fi

# Check if the user has access to sudo or has explicitly indicated they have sudo access
if [ "$HasSudo" = true ]; then
    # Prompt user for their sudo password if any conditions are met
    {
    echo "Please Enter your sudo password if prompted!"
    sudo -v > /dev/null
    }
else
    # Inform the user they need sudo access to run the installer
    { 
    echo 'This installer needs to be run on a system with sudo, please ensure you have access to sudo and it is installed before continuing!'
    echo 'This check is not perfect, if you do have access to sudo and see this message, type "HasSudo=true ; " before the install command'
    echo 'You can also manually install genpwd by downloading the binary from the github. https://github.com/NanashiTheNameless/genpwd/blob/main/genpwd.sh'
    exit 1
    }
fi


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
    elif [ "$SYSTEMTYPE" = "Linux" ]; then
        # Define the directory to install to
        DIR="/usr/bin"
    else
        { echo 'Could not determine what OS you are running, please manually install genpwd by downloading the binary from the github. https://github.com/NanashiTheNameless/genpwd/blob/main/genpwd.sh' ; exit 1 ; }
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

    if command -v axel &> /dev/null; then
        # Download with axel
        sudo axel -q -o "$DIR/genpwd" "https://raw.githubusercontent.com/NanashiTheNameless/genpwd/main/genpwd.sh"
    else
        # Check if wget is installed
        command -v wget >/dev/null 2>&1 || { echo >&2 "wget is required but it's not installed. Aborting." ; exit 1 ; }
        echo "------------------------------------------------"
        echo "Try Installing axel for faster download speed!"
        echo "------------------------------------------------"
        # Download with wget as a fallback
        sudo wget -q -O "$DIR/genpwd" "https://raw.githubusercontent.com/NanashiTheNameless/genpwd/main/genpwd.sh"
    fi

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
