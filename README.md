# 📚 Ebook Format Converter

[![Docker Pulls](https://img.shields.io/badge/docker-ready-blue.svg)](#)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A lightweight, automated Docker container that acts as a background conversion pipeline for your digital library. 

This tool continuously monitors an input directory for new ebook files and automatically converts them to a standardized format (default: EPUB) using Calibre's powerful `ebook-convert` engine. Once converted, the new file is moved to your output directory, and the original file is deleted to save space.

Perfect for preprocessing books before syncing them into self-hosted library managers like **BookOrbit**, **Grimmory**, **Calibre-Web**, or **OpenCloud/Nextcloud**.

---

## ✨ Features

* **Real-time Monitoring:** Uses `inotifywait` to instantly detect when a file finishes uploading or moving into the folder.
* **Smart Optimization:** If a file matching the target output format is uploaded, the script skips conversion and moves it directly to the output folder to save CPU cycles.
* **Highly Customizable:** Define exactly which file extensions to watch and what format to output via simple environment variables.
* **Broad Compatibility:** Natively handles DRM-free `.azw`, `.azw3`, `.mobi`, `.pdf`, `.docx`, and more.

## 🚀 Getting Started

### Prerequisites
* Docker installed on your host machine.
* (Optional) Docker Compose for easier management.

### 1. Build the Image

Clone this repository to your local machine and build the Docker image:

```bash
git clone https://github.com/tobiv/ebook-epubify.git
cd ebook-epubify
docker build -t ebook-epubify .
```

### 2. Run the Container

#### Option A: Docker Compose (Recommended)

Create or modify a `docker-compose.yml` file:

```yaml
services:
  ebook-converter:
    image: ebook-epubify
    container_name: ebook-epubify
    environment:
      - INPUT_FORMATS=azw,azw3,mobi,pdf,docx,txt,rtf,lit,lrf
      - OUTPUT_FORMAT=epub
      - PUID=1000
      - PGID=1000
    volumes:
      # Map your host folders to /input and /output
      - /path/to/your/upload_folder:/input
      - /path/to/your/destination_folder:/output
    restart: unless-stopped
```

Start the service:
```bash
docker compose up -d
```

#### Option B: Docker CLI

Run the container directly via the command line:

```bash
docker run -d \
  --name ebook-converter \
  -e INPUT_FORMATS="azw,azw3,mobi,pdf,cbz,cbr,docx,txt" \
  -e OUTPUT_FORMAT="epub" \
  -e PUID=1000 \
  -e PGID=1000 \
  -v /path/to/your/upload_folder:/input \
  -v /path/to/your/destination_folder:/output \
  --restart unless-stopped \
  ebook-epubify
```

---

## ⚙️ Configuration

You can customize the script's behavior using the following environment variables:

| Variable | Default Value | Description |
| :--- | :--- | :--- |
| `INPUT_FORMATS` | `azw,azw3,mobi,pdf,docx,txt,rtf,lit,lrf` | A comma-separated list of file extensions the script will listen for. Files with extensions not on this list will be completely ignored. |
| `OUTPUT_FORMAT` | `epub` | The target file format. Calibre supports extensive output formats including `epub`, `mobi`, `azw3`, `pdf`, and `txt`. |

---

## ⚠️ Important Note for Nextcloud/ownCloud Users

If you map this container's volumes directly into the backend data directories of an OpenCloud, Nextcloud, or ownCloud instance, the conversion will work perfectly on the filesystem. However, the Nextcloud web interface will not instantly see the new files because the internal database was bypassed.

To fix this, you must run the Nextcloud file scan command periodically, or trigger it via a cron job on your host server:

```bash
# Example command for Nextcloud
sudo -u www-data php /var/www/nextcloud/occ files:scan --path="user_id/files/destination_folder"
```
---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](https://github.com/tobvor/ebook-epubify/issues).

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details. Calibre is licensed under the GNU GPL v3.