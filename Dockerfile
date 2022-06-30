# Get the latest, official Leap image
FROM opensuse/leap
# Install system dependencies
RUN zypper up -y && zypper in -y \
 git make \
 libxslt-tools libxml2-tools ImageMagick python3-lxml xmlgraphics-fop \
 docbook_4 docbook_5 docbook-xsl-stylesheets docbook-xsl-stylesheets docbook5-xsl-stylesheets ruby2.5-rubygem-asciidoctor
# Setup the working directory
WORKDIR /opt/daps
# Fetch the executables provided from daps' Github repo
# aliasing to the main executable en passant
RUN git clone https://github.com/openSUSE/daps.git -b main --single-branch . && \
 ./configure --sysconfdir=/etc && \
 ./bin/daps-check-deps && \
 echo 'alias daps="/opt/daps/bin/daps"' >> ~/.bashrc

# build from this directory with:
# - podman build . -t daps-min
# run with:
# - podman run -it daps-min