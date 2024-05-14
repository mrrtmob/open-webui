#!/bin/bash

image_name="open-webui"
container_name="open-webui"
host_port=3000
container_port=8080

# Extracting environment variables from command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -b|--base-url) base_url="$2"; shift ;;
        -a|--api-urls) api_urls="$2"; shift ;;
        -k|--api-keys) api_keys="$2"; shift ;;
        -n|--custom-name) custom_name="$2"; shift ;;
        -m|--models) models="$2"; shift ;;
        -w|--webui-name) webui_name="$2"; shift ;;
        -s|--secret-key) secret_key="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

docker build -t "$image_name" .
docker stop "$container_name" &>/dev/null || true
docker rm "$container_name" &>/dev/null || true

docker run -d -p "$host_port":"$container_port" \
    --add-host=host.docker.internal:host-gateway \
    -v /root/data:/app/backend/data \
    -e "OLLAMA_BASE_URL=$base_url" \
    -e "OPENAI_API_BASE_URLS=$api_urls" \
    -e "OPENAI_API_KEYS=$api_keys" \
    -e "CUSTOM_NAME=$custom_name" \
    -e "DEFAULT_MODELS=$models" \
    -e "WEBUI_NAME=$webui_name" \
    -e "WEBUI_SECRET_KEY=$secret_key" \
    --name "$container_name" \
    --restart always \
    "$image_name"

docker image prune -f

# ./run.sh -b http://127.0.0.1:11434 -a "https://api.openai.com/v1" -k "apikey" -n GG -m gpt-3.5-turbo -w GG -s ggwp