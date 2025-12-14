#!/usr/bin/env bash

markdown_file="$1"

# Get the base name and directory
base_name=$(basename "$markdown_file" .md)
base_name=$(basename "$base_name" .markdown)
output_dir=$(dirname "$markdown_file")
output_file="$output_dir/$base_name.pdf"

# Display welcome message
gum style \
    --border double \
    --align center --width 60 --margin "1 2" --padding "1 2" \
    "📄 Markdown to PDF Converter" \
    "Converting: $(basename "$markdown_file")"

# Template selection
gum style --bold "Select a template for conversion:"

template=$(gum choose \
    "Academic" \
    "Eisvogel LaTeX " \
    "Eisvogel Beamer" \
    "Basic")

# Set pandoc options based on template selection
case "$template" in
    "Academic"*)
        pandoc_args="--defaults=academic"
        ;;
    "Eisvogel LaTeX"*)
        pandoc_args="--template=eisvogel.latex --pdf-engine=tectonic"
        ;;
    "Eisvogel Beamer"*)
        pandoc_args="--template=eisvogel.beamer --pdf-engine=tectonic -t beamer"
        ;;
    "Basic"*)
        pandoc_args="--pdf-engine=tectonic"
        ;;
esac

# Confirm conversion
gum style "Configuration:"
gum style --foreground 243 "Input:    $markdown_file"
gum style --foreground 243 "Output:   $output_file"
gum style --foreground 243 "Template: $template"
gum style --foreground 243 "Options:  $pandoc_args"

if ! gum confirm "Proceed with conversion?"; then
    gum style "Conversion cancelled."
    exit 0
fi

# Run pandoc conversion with spinner
gum style --bold "Converting..."

# Create a temporary file to capture error output
error_log=$(mktemp)

if gum spin --spinner dot --title "Processing document..." -- \
    bash -c "pandoc \"$markdown_file\" $pandoc_args -o \"$output_file\" 2>\"$error_log\""; then
    
    # Clean up error log if successful
    rm -f "$error_log"
    
    gum style \
        --border normal \
        --align center --width 50 --margin "1 0" --padding "1 2" \
        "✅ Conversion successful!" \
        "Output: $(basename "$output_file")"
    
    # Ask if user wants to open the PDF
    if gum confirm "Open the PDF?"; then
        if command -v open &> /dev/null; then
            open "$output_file"
        elif command -v xdg-open &> /dev/null; then
            xdg-open "$output_file"
        else
            gum style  "PDF created but no suitable viewer found."
        fi
    fi
else
    gum style \
        --border normal \
        --align center --width 50 --margin "1 0" --padding "1 2" \
        "❌ Conversion failed!"
    
    # Display the error output
    if [ -s "$error_log" ]; then
        echo ""
        gum style --bold --foreground 196 "Error details:"
        cat "$error_log"
    fi
    
    # Clean up error log
    rm -f "$error_log"
    exit 1
fi
