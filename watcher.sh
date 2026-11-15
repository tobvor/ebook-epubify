#!/bin/bash
INPUT_DIR="/input"
OUTPUT_DIR="/output"

# Set defaults if environment variables are not provided
INPUT_FORMATS=${INPUT_FORMATS:-"azw3,mobi,pdf,docx,txt,rtf,lit,lrf"}
OUTPUT_FORMAT=${OUTPUT_FORMAT:-"epub"}

echo "Watching $INPUT_DIR for formats: $INPUT_FORMATS"
echo "Target output format: $OUTPUT_FORMAT"

inotifywait -m -e close_write,moved_to --format "%w%f" "$INPUT_DIR" | while read -r FILE
do
  # Skip if the trigger was a directory being created
  if [ -d "$FILE" ]; then 
    continue
  fi

  # Extract filename and extension, converting extension to lowercase
  BASENAME=$(basename "$FILE")
  EXT="${BASENAME##*.}"
  EXT="${EXT,,}" 

  # Check if the file's extension exists in the INPUT_FORMATS list
  if [[ ",$INPUT_FORMATS," == *",$EXT,"* ]]; then
    FILENAME="${BASENAME%.*}"
    OUTPUT_FILE="$OUTPUT_DIR/$FILENAME.$OUTPUT_FORMAT"

    # Optimization: If the uploaded file is already the target format, just move it
    if [ "$EXT" == "$OUTPUT_FORMAT" ]; then
       echo "File is already $OUTPUT_FORMAT. Moving directly to output..."
       mv "$FILE" "$OUTPUT_FILE"
       continue
    fi

    echo "Converting $BASENAME to $OUTPUT_FORMAT..."
    ebook-convert "$FILE" "$OUTPUT_FILE"

    # Verify if conversion was successful
    if [ $? -eq 0 ]; then
      echo "Conversion successful. Deleting original file..."
      rm "$FILE"
    else
      echo "Conversion failed for $FILE. Original file kept for debugging."
    fi
  fi
done