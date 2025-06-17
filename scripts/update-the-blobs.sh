#!/usr/bin/env bash

# GitHub Token support
GITHUB_TOKEN="${GITHUB_TOKEN:-}"
while [[ "$#" -gt 0 ]]; do
    case $1 in
    -g|--github-token)
      GITHUB_TOKEN="$2"; export GITHUB_TOKEN; shift 2 ;;
    -f|--force) force="TRUE"; shift ;;
    ?|h)
      echo "Usage: $(basename $0) [--force] [--github-token <token>]"
      exit 1
      ;;
    *) shift ;;
  esac
done

github_api() {
  local url="$1"
  if [[ -n "$GITHUB_TOKEN" ]]; then
    curl --silent -H "Authorization: Bearer $GITHUB_TOKEN" -L "$url"
  else
    curl --silent -L "$url"
  fi
}

get_latest_loki_release() {
  github_api "https://api.github.com/repos/grafana/loki/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | cut -d "v" -f 2
}

# shellcheck disable=SC2034
loki_version=$(get_latest_loki_release)

get_latest_jq_release() {
  github_api "https://api.github.com/repos/jqlang/jq/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | cut -d "-" -f 2
}

# shellcheck disable=SC2034
jq_version=$(get_latest_jq_release)

get_latest_promtail_release() {
  github_api "https://api.github.com/repos/grafana/loki/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | cut -d "v" -f 2
}

# shellcheck disable=SC2034
promtail_version=$(get_latest_promtail_release)

# shellcheck disable=SC2062
# shellcheck disable=SC2002
# shellcheck disable=SC2034
used_loki_version=$(cat config/blobs.yml | grep loki | cut -d "-" -f 3 |  cut -d ":" -f 1)

# shellcheck disable=SC2062
# shellcheck disable=SC2002
# shellcheck disable=SC2034
used_jq_version=$(cat config/blobs.yml | grep jq | cut -d "-" -f 3 |  cut -d ":" -f 1)

# shellcheck disable=SC2062
# shellcheck disable=SC2002
# shellcheck disable=SC2034
used_promtail_version=$(cat config/blobs.yml | grep promtail | cut -d "-" -f 3 |  cut -d ":" -f 1)

# shellcheck disable=SC2050
if [[ "$force" == "TRUE" ]]; then
  rm config/blobs.yml 2> /dev/null
  touch config/blobs.yml
fi

# shellcheck disable=SC2050
if [[ "$jq_version" != "$used_jq_version" || "$force" == "TRUE" ]]; then
  wget https://github.com/jqlang/jq/releases/download/jq-$jq_version/jq-linux64
  bosh add-blob jq-linux64 jq-linux64-$jq_version
  rm jq-linux64
  sed -i -e "s/jq-linux64-${used_jq_version}/jq-linux64-${jq_version}/g" packages/jq/spec
  bosh upload-blobs
fi

# shellcheck disable=SC2050
if [[ "$loki_version" != "$used_loki_version" || "$force" == "TRUE" ]]; then
  wget https://github.com/grafana/loki/releases/download/v$loki_version/loki-linux-amd64.zip
  unzip loki-linux-amd64.zip
  rm loki-linux-amd64.zip
  bosh add-blob loki-linux-amd64 loki-linux64-$loki_version
  rm loki-linux-amd64
  sed -i -e "s/loki-linux64-${used_loki_version}/loki-linux64-${loki_version}/g" packages/loki/spec
  bosh upload-blobs
fi

# shellcheck disable=SC2050
if [[ "$promtail_version" != "$used_promtail_version" || "$force" == "TRUE" ]]; then
  wget https://github.com/grafana/loki/releases/download/v$promtail_version/promtail-linux-amd64.zip
  unzip promtail-linux-amd64.zip
  rm promtail-linux-amd64.zip
  bosh add-blob promtail-linux-amd64 promtail-linux64-$promtail_version
  rm promtail-linux-amd64
  sed -i -e "s/promtail-linux64-${used_promtail_version}/promtail-linux64-${promtail_version}/g" packages/promtail/spec
  bosh upload-blobs
fi
