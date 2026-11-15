#!/usr/bin/env bash
set -euo pipefail

EFFECTIVE_APPIUM_HOME="${APPIUM_HOME:-/opt/appium-home}"
if [[ ! -w "$EFFECTIVE_APPIUM_HOME" ]]; then
	TMP_APPIUM_HOME="${TMPDIR:-/tmp}/.appium-home-$(id -u)"
	if [[ ! -f "${TMP_APPIUM_HOME}/node_modules/.cache/appium/extensions.yaml" ]]; then
		mkdir -p "${TMP_APPIUM_HOME}/node_modules/.cache"
		if [[ -f "${EFFECTIVE_APPIUM_HOME}/package.json" ]]; then
			cp -f "${EFFECTIVE_APPIUM_HOME}/package.json" "${TMP_APPIUM_HOME}/package.json"
		fi
		if [[ -d "${EFFECTIVE_APPIUM_HOME}/node_modules/.cache" ]]; then
			cp -R "${EFFECTIVE_APPIUM_HOME}/node_modules/.cache/." "${TMP_APPIUM_HOME}/node_modules/.cache/"
		fi
		for entry in "${EFFECTIVE_APPIUM_HOME}/node_modules"/* "${EFFECTIVE_APPIUM_HOME}/node_modules"/.[!.]*; do
			[[ -e "$entry" ]] || continue
			name="$(basename "$entry")"
			[[ "$name" == ".cache" ]] && continue
			ln -snf "$entry" "${TMP_APPIUM_HOME}/node_modules/${name}"
		done
	fi
	export APPIUM_HOME="$TMP_APPIUM_HOME"
fi

exec /opt/qa11x/node_modules/.bin/appium "$@"
