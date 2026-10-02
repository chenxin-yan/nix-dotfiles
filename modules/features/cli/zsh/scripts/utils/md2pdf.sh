#!/usr/bin/env bash

markdown_file="$1"

if [[ ! -f "$markdown_file" ]]; then
    echo "Usage: md2pdf <file.md>" >&2
    exit 1
fi

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
    "Basic") || exit 0

# Set pandoc options based on template selection
case "$template" in
    "Academic"*)
        pandoc_args=(--defaults=academic)
        ;;
    "Eisvogel LaTeX"*)
        pandoc_args=(--defaults=eisvogel)
        ;;
    "Eisvogel Beamer"*)
        pandoc_args=(--template=eisvogel.beamer --pdf-engine=tectonic -t beamer)
        ;;
    "Basic"*)
        pandoc_args=(--pdf-engine=tectonic)
        ;;
esac

# Confirm conversion
gum style "Configuration:"
gum style --foreground 243 "Input:    $markdown_file"
gum style --foreground 243 "Output:   $output_file"
gum style --foreground 243 "Template: $template"
gum style --foreground 243 "Options:  ${pandoc_args[*]}"

if ! gum confirm "Proceed with conversion?"; then
    gum style "Conversion cancelled."
    exit 0
fi

# Run pandoc conversion with spinner
gum style --bold "Converting..."

# Filenames stay separate argv entries so they are never parsed as shell code.
if gum spin --show-error --spinner dot --title "Processing document..." -- \
    pandoc "$markdown_file" "${pandoc_args[@]}" -o "$output_file"; then
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
    exit 1
fi
