#!/usr/bin/env bash
set -euo pipefail

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
mkdir -p "$tmp_dir/bin"
cat > "$tmp_dir/bin/curl" <<'SCRIPT'
#!/usr/bin/env bash
cat <<'JSON'
{"current_condition":[{"FeelsLikeC":"24","humidity":"21","temp_C":"29","weatherDesc":[{"value":"Sunny"}],"winddir16Point":"N","windspeedKmph":"20"}],"nearest_area":[{"areaName":[{"value":"Regina"}]}],"weather":[{"date":"2026-08-27","maxtempC":"32","mintempC":"18","hourly":[{"weatherDesc":[{"value":"Rain"}]}]},{"date":"2026-08-28","maxtempC":"30","mintempC":"17","hourly":[{"weatherDesc":[{"value":"Cloudy"}]}]},{"date":"2026-08-29","maxtempC":"26","mintempC":"16","hourly":[{"weatherDesc":[{"value":"Clear"}]}]}]}
JSON
SCRIPT
chmod +x "$tmp_dir/bin/curl"

output=$(PATH="$tmp_dir/bin:$PATH" bash "$(dirname "$0")/system-overlay/usr/local/bin/flux-weather")
jq -e '.text == "☀ 29°" and (.tooltip | contains("REGINA") and contains("FEELS") and contains("FRI") and contains("SAT"))' <<< "$output" >/dev/null
PYTHONPYCACHEPREFIX="$tmp_dir/pycache" python3 -m py_compile "$(dirname "$0")/system-overlay/usr/local/bin/flux-weather-popup"
jq -e '.["custom/weather"] | .["on-click"] == "flux-weather-popup" and .tooltip == false' \
  "$(dirname "$0")/system-overlay/etc/skel/.config/waybar/config.jsonc" >/dev/null

echo "flux-weather checks passed"
