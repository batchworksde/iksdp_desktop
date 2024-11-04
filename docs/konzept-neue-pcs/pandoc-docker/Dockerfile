FROM node:18

RUN export DEBIAN_FRONTEND=noninteractive \
    && apt update && apt upgrade -y  \ 
    && apt install -y pandoc python3 wget


    #&& apt install -y google-chrome-stable fonts-ipafont-gothic fonts-wqy-zenhei fonts-thai-tlwg fonts-khmeros fonts-kacst fonts-freefont-ttf libxss1  --no-install-recommends 
    # && groupadd -r pptruser && useradd -rm -g pptruser -G audio,video pptruser

RUN apt install chromium texlive texlive-xetex texlive-fonts-recommended texlive-fonts-extra -y && apt-clean
RUN npm install --global mermaid-filter

WORKDIR /workdir

# test pandoc  -F mermaid-filter  -o test.pdf /workdir/konzept_cicd.md

# pandoc  -o example.pdf --pdf-engine=xelatex -F mermaid-filter /workdir/cicd_konzept.md

# pandoc /workdir/cicd_konzept.md -f markdown -o doc.pdf --toc -F mermaid-filter --variable titlepage=true --variable caption-justification=centering