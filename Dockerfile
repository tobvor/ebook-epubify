FROM ubuntu:26.04

LABEL maintainer="Tobias Vornholt t.vornholt@mailbox.org"

ENV DEBIAN_FRONTEND=noninteractive

# Define default formats (can be overridden at runtime)
ENV INPUT_FORMATS="azw3,mobi,pdf,docx,txt,rtf,lit,lrf"
ENV OUTPUT_FORMAT="epub"

# Set defaults for user mapping
ENV PUID=1000
ENV PGID=1000

RUN apt-get update && \
    apt-get install -y calibre inotify-tools bash && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY watcher.sh /usr/local/bin/watcher.sh
RUN chmod +x /usr/local/bin/watcher.sh

RUN mkdir -p /input /output

CMD ["/usr/local/bin/watcher.sh"]