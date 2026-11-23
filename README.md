> 🌐 **Language:** **English** (Canonical) | [🇪🇸 Español](README.es.md)

[![Descargas de Docker](https://img.shields.io/docker/pulls/sinfallas/base-mobile-appium?style=flat&logo=docker&color=blue)](https://hub.docker.com/r/sinfallas/base-mobile-appium)
 
# base-mobile-appium

Warning: `npm` mutating commands (`install`, `ci`, `update`) are blocked by `npm-shield.sh`. Use `pnpm` or pre-baked tools in `/opt/qa11x`.

Hardened non-root Docker base image (`sinfallas/base-mobile-appium:26`) for Mobile QA (`QA-11X v3.0`), designed strictly as an ephemeral **W3C Runner + Appium 3 Driver Bridge** (without an embedded QEMU/KVM Android emulator).

## Pre-baked Toolchain

* **Runtime:** Node.js `26` (`slim`), `pnpm`, `TypeScript`, and `npm-shield.sh`
* **Java & Android SDK:** OpenJDK `21` Headless JRE, `platform-tools` (`adb`), `build-tools;35.0.0` (`aapt2`, `apksigner`, `zipalign`), `platforms;android-35`
* **Mobile W3C & Screenplay:** Appium `3.x` with pre-installed drivers (`uiautomator2`, `xcuitest`) under `APPIUM_HOME=/opt/appium-home`
* **Test Runner:** WebdriverIO `v9` (`webdriverio`, `@wdio/cli`, `@wdio/local-runner`, `@wdio/mocha-framework`, `@wdio/spec-reporter`, `@wdio/appium-service`, `@wdio/allure-reporter`)
* **Supply Chain & Non-Root:** Lockfile deterministic build (`qa11x-tools/package-lock.json`), SHA-256 verified Android CLI tools, CycloneDX SBOM (`/opt/qa11x/sbom.cdx.json`), default `USER 10001:10001` compatible with `-u "$(id -u):$(id -g)"` and `--read-only`.

## Local Validation & Build

```bash
# Build locally, run air-gapped read-only smoke tests + Trivy (HIGH/CRITICAL = 0), no push:
./build --local
```

## Get This Image

* https://hub.docker.com/r/sinfallas/base-mobile-appium

Copyright (C) 2026 Jesus Palencia <sinfallas@gmail.com> (Creado en Tecno Consultores)
