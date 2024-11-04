#!/bin/bash

docker run -ti --rm \
       --volume "$(pwd):/app" \
       schose/pandoc_mac:latest pandoc konzept.en.md -f markdown -o konzept.en.pdf --toc --pdf-engine=xelatex --variable titlepage=true -F mermaid-filter --template  https://raw.githubusercontent.com/Wandmalfarbe/pandoc-latex-template/v2.0.0/eisvogel.tex --listings

       docker run -ti --rm \
       --volume "$(pwd):/app" \
       schose/pandoc_mac:latest pandoc konzept.it.md -f markdown -o konzept.it.pdf --toc --pdf-engine=xelatex --variable titlepage=true -F mermaid-filter --template  https://raw.githubusercontent.com/Wandmalfarbe/pandoc-latex-template/v2.0.0/eisvogel.tex --listings