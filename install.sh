#!/usr/bin/env bash

# Set directory to install genpwd to
DIR="$HOME/.config/genpwd"

AGREE_FLAG=0
for __arg in "$@"; do
  if [[ "$__arg" == "--agree" ]]; then
    AGREE_FLAG=1
  fi
done

cat <<'LICENSE'
# 🏳️‍🌈 Opinionated Queer License v1.2

© Copyright [NamelessNanashi](<https://git.NamelessNanashi.dev/>)

## Permissions

The creators of this Work (“The Licensor”) grant permission
to any person, group or legal entity that doesn't violate the prohibitions below (“The User”),
to do everything with this Work that would otherwise infringe their copyright or any patent claims,
subject to the following conditions:

## Obligations

The User must give appropriate credit to the Licensor,
provide a copy of this license or a (clickable, if the medium allows) link to
[oql.avris.it/license/v1.2](<https://oql.avris.it/license/v1.2>),
and indicate whether and what kind of changes were made.
The User may do so in any reasonable manner,
but not in any way that suggests the Licensor endorses the User or their use.

## Prohibitions

No one may use this Work for prejudiced or bigoted purposes, including but not limited to:
racism, xenophobia, queerphobia, queer exclusionism, homophobia, transphobia, enbyphobia, misogyny.

No one may use this Work to inflict or facilitate violence or abuse of human rights,
as defined in either of the following documents:
[Universal Declaration of Human Rights](<https://www.un.org/en/about-us/universal-declaration-of-human-right>),
[European Convention on Human Rights](<https://prd-echr.coe.int/web/echr/european-convention-on-human-rights>)
along with the rulings of the [European Court of Human Rights](<https://www.echr.coe.int/>).

No law enforcement, carceral institutions, immigration enforcement entities, military entities or military contractors
may use the Work for any reason. This also applies to any individuals employed by those entities.

No business entity where the ratio of pay (salaried, freelance, stocks, or other benefits)
between the highest and lowest individual in the entity is greater than 50 : 1
may use the Work for any reason.

No private business run for profit with more than a thousand employees
may use the Work for any reason.

Unless the User has made substantial changes to the Work,
or uses it only as a part of a new work (eg. as a library, as a part of an anthology, etc.),
they are prohibited from selling the Work.
That prohibition includes processing the Work with machine learning models.

## Sanctions

If the Licensor notifies the User that they have not complied with the rules of the license,
they can keep their license by complying within 30 days after the notice.
If they do not do so, their license ends immediately.

## Warranty

This Work is provided “as is”, without warranty of any kind, express or implied.
The Licensor will not be liable to anyone for any damages related to the Work or this license,
under any kind of legal claim as far as the law allows.
LICENSE

if [[ $AGREE_FLAG -eq 1 ]]; then
  echo "Agreement provided via --agree."
else
  if [ -t 0 ] && [ -r /dev/tty ]; then
    printf "\nDo you agree to the license terms above? [y/N]: " > /dev/tty
    read -r REPLY < /dev/tty || REPLY=""
  else
    printf "\nDo you agree to the license terms above? [y/N]: "
    read -r REPLY || REPLY=""
  fi

  case "$REPLY" in
    [yY]|[yY][eE][sS]) echo "Agreed." ;;
    *)                 echo "Not agreed."; exit 1 ;;
  esac
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
        axel -H 'DNT: 1' -H 'Sec-GPC: 1' -q -o "$DIR/genpwd" "https://github.com/NanashiTheNameless/genpwd/raw/refs/heads/main/genpwd.sh"
    else
        # Check if wget is installed
        command -v wget >/dev/null 2>&1 || { echo >&2 "wget is required but it's not installed. Aborting." ; exit 1 ; }
        echo "Now downloading latest version of genpwd with wget!"
        echo "-----------------------------------------------------------------------------"
        echo 'Try Installing axel for faster download speed! (And easier syntax than wget!)'
        echo "-----------------------------------------------------------------------------"
        # Download with wget as a fallback
        wget -H 'DNT: 1' -H 'Sec-GPC: 1' -q -O "$DIR/genpwd" "https://github.com/NanashiTheNameless/genpwd/raw/refs/heads/main/genpwd.sh"
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
