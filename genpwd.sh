#!/usr/bin/env bash
# Function to display help message
display_help() {
    echo "Usage: ${0##*/} [-h] [--regen] [--update] [-s] [-e] [-c] [-n number_of_passwords] [-l min_word_length] [-m max_word_length] [-r max_retries]"
    echo "Generate random passwords based on words and numbers."
    echo "Options:"
    echo "  --regen  Download the latest words file."
    echo "  --update  Download to the latest genpwd release."
    echo "  -h  Show this help message."
    echo "  -s  Enable 'Super Mode' which will create longer passwords."
    echo "  -e  Enable 'Evil Mode' which will create stupidly long passwords."
    echo "  -c  Enable 'Cowsay Mode' which will echo your password in a cowsay bubble."
    echo "  -n  Number of passwords to generate (default is 1)."
    echo "  -l  Minimum length of the words (default is 4)."
    echo "  -m  Maximum length of the words (default is the current minimum length + 4)."
    echo "  -r  Maximum number of retries for each word (default is 60)."
    echo '  -x  "X-Tra mode" (makes passwords that are more optimized for randomness).'
}

# Initialize default values
longer="false"
evil="false"
cowsay="false"
times_to_run="1"
min_word_length="4"
max_word_length="$((min_word_length + 4))"
max_retries="60"
regen="false"
update="false"
storage_path="$HOME/.config/genpwd"
words_file="$storage_path/genpwd-words.txt"

# To use a different word list link it here (make sure it is a raw file)
words_file_link="https://raw.githubusercontent.com/xajkep/wordlists/master/dictionaries/english_a-z_-_no_special_chars.txt"

# function to download words file
download_words_file() {
  # Create the directory if it doesn't exist
  if [ ! -d "$storage_path" ]; then
    mkdir -p "$storage_path"
  fi
   
  # Ensure Permissions on storage path
  if [ ! -w "$storage_path" ]; then
    { echo "Error: No write permission in the storage path." ; exit 1 ; }
  fi

  # Delete old words file if it exists
  if [ -f "$words_file" ]; then
    rm -f "$words_file"
  fi

  # Determine the reason for downloading
  if [ "$regen" = true ]; then
      echo "Downloading new words file..."
   else
      echo "Downloading words file..."
  fi

  if command -v axel &> /dev/null; then
      # Download with axel
      axel -q -o "$words_file" "$words_file_link"
  else
      # Check if wget is installed
      command -v wget >/dev/null 2>&1 || { echo >&2 "wget is required but it's not installed. Aborting." ; exit 1 ; }
      echo "------------------------------------------------"
      echo "Try Installing axel for faster download speed!"
      echo "------------------------------------------------"
      # Download with wget as a fallback
      wget -q -O "$words_file" "$words_file_link"
  fi

  # Check if the download was successful
  if [ $? -ne 0 ]; then
    { echo "Download failed." ; exit 1 ; }
  fi
    { echo "Download complete." ; exit 0 ; }
}

# Check for --regen option among the arguments
for arg in "$@"; do
  if [ "$arg" == "--regen" ]; then
    regen="true"
    download_words_file
    break
  fi
done

# If words file doesn't exist download it using wget
if ! [ -r $words_file ]; then
download_words_file
fi

# Check for --update option among the arguments
for arg in "$@"; do
  if [ "$arg" == "--update" ]; then
    update="true"
    # Check if curl is installed
    command -v curl >/dev/null 2>&1 || { echo >&2 "curl is required but it's not installed. Aborting." ; exit 1 ; }
    curl -q -H 'Cache-Control: no-cache, no-store' -H 'Pragma: no-cache' -s -L https://raw.githubusercontent.com/NanashiTheNameless/genpwd/main/install.sh | bash
    break
  fi
done


# Exit after completing --regen or --update
if [ "$regen" = true ] || [ "$update" = true ]; then
    exit 0
fi

# Parse command line arguments for standard flags
while getopts ":secn:l:m:r:xh" opt; do
  case $opt in
    s)
        longer="true"
      ;;
    e)
        evil="true"
      ;;
    c)
        cowsay="true"
      ;;
    n) 
      if [[ "$OPTARG" =~ ^[0-9]+$ ]]; then
        times_to_run="$OPTARG"
      else
        { echo "Error: -n requires a numeric argument." >&2 ; exit 1 ; }
      fi
      ;;
    l) 
      if [[ "$OPTARG" =~ ^[0-9]+$ ]]; then
        min_word_length="$OPTARG"
        max_word_length="$((min_word_length + 4))"
      else
        { echo "Error: -l requires a numeric argument." >&2 ; exit 1 ; }
      fi
      ;;
    m) 
      if [[ "$OPTARG" =~ ^[0-9]+$ ]]; then
        max_word_length="$OPTARG"
      else
        { echo "Error: -m requires a numeric argument." >&2 ; exit 1 ; }
      fi
      ;;
    r) 
      if [[ "$OPTARG" =~ ^[0-9]+$ ]]; then
        max_retries="$OPTARG"
      else
        { echo "Error: -r requires a numeric argument." >&2 ; exit 1 ; }
      fi
      ;;
    h) 
      display_help ; exit 0
      ;;
    x) 
         xtra="true"
      ;;
    \?) { echo "Invalid option '-$OPTARG' (If you need help you can try running '${0##*/} -h')" >&2 ; exit 1 ; }
    ;;
    esac
done

# Check the option validity
if [ "$min_word_length" -gt "$max_word_length" ]; then
    { echo "Invalid option: Minimum word length ("$min_word_length") must be less or equal to than Maximum word length ("$max_word_length")." >&2 ; exit 1 ; }
fi
if [ $max_retries -le 0 ]; then
    { echo "Invalid option: Minimum retries ("$max_retries") must be greater than 0." >&2 ; exit 1 ; }
fi

# Function to get a random word from the words file
get_word_from_file() {
    local word
    local retry_count=0

    while [ "$retry_count" -lt "$max_retries" ]; do
        # Get a random word from the array
        word="${word_array[$(shuf -i 0-$(( ${#word_array[@]} - 1 )) -n 1)]}"
        
        # Check the word length and return
        if [ "${#word}" -ge "$min_word_length" ] && [ "${#word}" -le "$max_word_length" ]; then
            echo "$word"
            return 0
        fi

        retry_count="$((retry_count + 1))"
    done
    { echo "Error: Could not find a suitable word after "$max_retries" retries." >&2 ; exit 1 ; }
}

# Fetch all words from the words file into an array
mapfile -t word_array < "$words_file"

# Check if the words array is empty
if [ "${#word_array[@]}" -eq 0 ]; then
    { echo "Error: Words file is empty or not accessible." >&2 ; exit 1 ; }
fi

# Loop to run the script the specified number of times
for ((i=1; i<=times_to_run; i++)); do

    if [ "$xtra" = "true" ]; then
      if [ "$cowsay" = "true" ]; then
      # Check if cowsay is installed
          command -v cowsay >/dev/null 2>&1 || { echo >&2 "cowsay is required but it's not installed. Aborting." ; exit 1 ; }
          # Echo the cowsay random string
          echo ""
          echo "$(cowsay $(tr -cd "[:graph:]" < /dev/urandom | head -c $(($min_word_length + 20)) | sed -e 's|\`|~|g' -e 's|\$(|\\$(|g' -e 's|~||g' | sed 's/^.\(.*\)/\1/';))"
          echo ""
      else
          echo ""
          echo -e "$(tr -cd "[:graph:]" < /dev/urandom | head -c $(($min_word_length + 20)) | sed -e 's|\`|~|g' -e 's|\$(|\\$(|g' -e 's|~||g' | sed 's/^.\(.*\)/\1/';)"
          echo ""
      fi

    elif [ "$evil" = "true" ]; then

        # Generate nine random words
        words1=$(get_word_from_file)
        words2=$(get_word_from_file)
        words3=$(get_word_from_file)
        words4=$(get_word_from_file)
        words5=$(get_word_from_file)
        words6=$(get_word_from_file)
        words7=$(get_word_from_file)
        words8=$(get_word_from_file)
        words9=$(get_word_from_file)
        
        # Generate eight random numbers
        numbers1=$(shuf -i 1-999999 -n 1)
        numbers2=$(shuf -i 1-999999 -n 1)
        numbers3=$(shuf -i 1-999999 -n 1)
        numbers4=$(shuf -i 1-999999 -n 1)
        numbers5=$(shuf -i 1-999999 -n 1)
        numbers6=$(shuf -i 1-999999 -n 1)
        numbers7=$(shuf -i 1-999999 -n 1)
        numbers8=$(shuf -i 1-999999 -n 1)
        
        if [ "$cowsay" = "true" ]; then
          # Check if cowsay is installed
          command -v cowsay >/dev/null 2>&1 || { echo >&2 "cowsay is required but it's not installed. Aborting." ; exit 1 ; }
          # Echo the cowsay random string
          echo ""
          echo "$(cowsay $words1$numbers1$words2$numbers2$words3$numbers3$words4$numbers4$words5$numbers5$words6$numbers6$words7$numbers7$words8$numbers8$words9)"
          echo ""
        else
          # Echo the random string
          echo ""
          echo "$words1$numbers1$words2$numbers2$words3$numbers3$words4$numbers4$words5$numbers5$words6$numbers6$words7$numbers7$words8$numbers8$words9"
          echo ""
        fi
        
    elif [ "$longer" = "true" ]; then
    
        # Generate three random words
        words1=$(get_word_from_file)
        words2=$(get_word_from_file)
        words3=$(get_word_from_file)
        
        # Generate two random numbers
        numbers1=$(shuf -i 1-99999 -n 1)
        numbers2=$(shuf -i 1-99999 -n 1)
        
        if [ "$cowsay" = "true" ]; then
          # Check if cowsay is installed
          command -v cowsay >/dev/null 2>&1 || { echo >&2 "cowsay is required but it's not installed. Aborting." ; exit 1 ; }
          # Echo the cowsay random string
          echo ""
          echo "$(cowsay $words1$numbers1$words2$numbers2$words3)"
          echo ""
        else
          # Echo the random string
          echo ""
          echo "$words1$numbers1$words2$numbers2$words3"
          echo ""
        fi

    else
        
        # Generate two random words
        words1=$(get_word_from_file)
        words2=$(get_word_from_file)
        
        # Generate a random number
        numbers1=$(shuf -i 1-9999 -n 1)

        if [ "$cowsay" = "true" ]; then
          # Check if cowsay is installed
          command -v cowsay >/dev/null 2>&1 || { echo >&2 "cowsay is required but it's not installed. Aborting." ; exit 1 ; }
          # Echo the cowsay random string
          echo ""
          echo "$(cowsay $words1$numbers1$words2)"
          echo ""
        else
          # Echo the random string
          echo ""
          echo "$words1$numbers1$words2"
          echo ""
        fi
    fi
done
exit 0
