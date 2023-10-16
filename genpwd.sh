#!/bin/bash
# Function to display help message
display_help() {
    echo "Usage: ${0##*/} [-s] [-n number_of_passwords] [-l min_word_length] [-m max_word_length] [-r max_retries] [--regen]"
    echo "Generate random passwords based on words and numbers."
    echo "Options:"
    echo "  -s  Enable 'Super Mode' which will create longer passwords."
    echo "  -n  Number of passwords to generate (default is 1)."
    echo "  -l  Minimum length of the words (default is 4)."
    echo "  -m  Maximum length of the words (default is the current minimum length + 3)."
    echo "  -r  Maximum number of retries for each word (default is 30)."
    echo "  --regen  Download the latest words file."
}

# Initialize default values
longer="false"
times_to_run="1"
min_word_length="4"
max_word_length="$((min_word_length + 3))"
max_retries="30"
regen="false"
storage_path="$HOME/.config/genpwd"
words_file="$storage_path/genpwd-words.txt"

# Check for --regen option among the arguments
for arg in "$@"; do
  if [ "$arg" == "--regen" ]; then
    regen="true"
    break
  fi
done

# If words file doesn't exist or --regen is true, download it using wget
if ! [ -r $words_file ] || [ "$regen" = true ]; then
    # Create the directory if it doesn't exist
    if [ ! -d "$storage_path" ]; then
      mkdir -p "$storage_path"
    fi
    # Determine the reason for downloading
    if [ "$regen" = true ]; then
        echo "Downloading new words file..."
    else
        echo "Downloading words file..."
    fi
    wget -O "$words_file" "https://raw.githubusercontent.com/first20hours/google-10000-english/master/google-10000-english-no-swears.txt"
    # Check if the download was successful
    if [ $? -ne 0 ]; then
        echo "Download failed."
        exit 1
    fi
    echo "Download complete."
    exit 0
fi

# Exit after completing --regen
if [ "$regen" = true ]; then
    exit 0
fi

# Parse command line arguments for standard flags
while getopts ":sn:l:m:r:h" opt; do
  case $opt in
    s)
        longer="true"
      ;;
    n) 
      if [[ "$OPTARG" =~ ^[0-9]+$ ]]; then
        times_to_run="$OPTARG"
      else
        echo "Error: -n requires a numeric argument." >&2
        exit 1
      fi
      ;;
    l) 
      if [[ "$OPTARG" =~ ^[0-9]+$ ]]; then
        min_word_length="$OPTARG"
      else
        echo "Error: -l requires a numeric argument." >&2
        exit 1
      fi
      ;;
    m) 
      if [[ "$OPTARG" =~ ^[0-9]+$ ]]; then
        max_word_length="$OPTARG"
      else
        echo "Error: -m requires a numeric argument." >&2
        exit 1
      fi
      ;;
    r) 
      if [[ "$OPTARG" =~ ^[0-9]+$ ]]; then
        max_retries="$OPTARG"
      else
        echo "Error: -r requires a numeric argument." >&2
        exit 1
      fi
      ;;
    h) 
      display_help; exit 0
      ;;
    \?) echo "Invalid option -$OPTARG" >&2; exit 1
    ;;
    esac
done

# Check the option validity
if [ "$min_word_length" -gt "$max_word_length" ]; then
    echo "Invalid option: Minimum word length ("$min_word_length") must be less or equal to than Maximum word length ("$max_word_length")." >&2; exit 1
fi
if [ $max_retries -le 0 ]; then
    echo "Invalid option: Minimum retries ("$max_retries") must be greater than 0." >&2; exit 1
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
    echo "Error: Could not find a suitable word after "$max_retries" retries." >&2
    exit 1
}

# Fetch all words from the words file into an array
mapfile -t word_array < "$words_file"

# Check if the words array is empty
if [ "${#word_array[@]}" -eq 0 ]; then
    echo "Error: Words file is empty or not accessible." >&2
    exit 1
fi

# Loop to run the script the specified number of times
for ((i=1; i<=times_to_run; i++)); do
    if [ "$longer" = "true" ]; then
    
        # Generate three random words
        words1=$(get_word_from_file)
        words2=$(get_word_from_file)
        words3=$(get_word_from_file)
        
        # Generate two random numbers
        numbers1=$(shuf -i 10-999 -n 1)
        numbers2=$(shuf -i 10-999 -n 1)
        
        # Echo the random string
        echo ""
        echo "$words1$numbers1$words2$numbers2$words3"
        echo ""
    else
    
        # Generate two random words
        words1=$(get_word_from_file)
        words2=$(get_word_from_file)
        
        # Generate a random number
        numbers1=$(shuf -i 10-999 -n 1)
        
        # Echo the random string
        echo ""
        echo "$words1$numbers1$words2"
        echo ""
    fi
done
exit 0
