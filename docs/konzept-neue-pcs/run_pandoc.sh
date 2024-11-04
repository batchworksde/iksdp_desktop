#!/bin/sh

docker run --rm \
        --volume "$(pwd):/workdir" \
        schose/pandoc:latest pandoc konzept.de.md -f markdown -o konzept.de.pdf --toc --pdf-engine=xelatex --variable titlepage=true -F mermaid-filter --template  https://raw.githubusercontent.com/Wandmalfarbe/pandoc-latex-template/v2.0.0/eisvogel.tex --listings
