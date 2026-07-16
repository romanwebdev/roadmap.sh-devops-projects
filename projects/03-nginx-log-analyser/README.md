# Nginx Log Analyser

A Bash script that analyses Nginx access logs and highlights the top IP addresses, requested paths, response status codes, and user agents.

## Technologies

Shell/Bash

## Requirements

- [x] Top 5 IP addresses with the most requests
- [x] Top 5 most requested paths
- [x] Top 5 response status codes
- [x] Top 5 user agents

## Usage

Run the script with:

```bash
bash log-analyser.sh
```

If you want to execute it directly:

```bash
chmod +x log-analyser.sh
./log-analyser.sh
```

## Output

```
Top 5 IP addresses with the most requests:
138.68.248.85 - 1087 requests
142.93.136.176 - 1087 requests
178.128.94.113 - 1087 requests
159.89.185.30 - 1086 requests
86.134.118.70 - 277 requests

Top 5 most requested paths:
/v1-health - 4560 requests
/ - 270 requests
/v1-me - 232 requests
/v1-list-workspaces - 127 requests
/v1-list-timezone-teams - 75 requests

Top 5 response status codes:
200 - 5740 requests
404 - 937 requests
304 - 621 requests
400 - 260 requests
403 - 23 requests

Top 5 user agents:
DigitalOcean Uptime Probe 0.22.0 (https://digitalocean.com) - 4347 requests
Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36 - 513 requests
Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/129.0.0.0 Safari/537.36 - 332 requests
Custom-AsyncHttpClient - 294 requests
Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36 - 282 requests
```

## Link

[roadmap.sh](https://roadmap.sh/projects/nginx-log-analyser)
