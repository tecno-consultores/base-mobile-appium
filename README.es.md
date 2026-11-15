> 🌐 **Idioma:** [🇺🇸 English](README.md) | **Español** (Espejo 1:1)

# base-mobile-appium

Advertencia: los comandos mutables de `npm` (`install`, `ci`, `update`) están bloqueados por `npm-shield.sh`. Usa `pnpm` o las herramientas prehorneadas en `/opt/qa11x`.

Imagen base Docker endurecida no-root (`sinfallas/base-mobile-appium:26`) para QA Móvil (`QA-11X v3.0`), diseñada estrictamente como **Runner + Driver Bridge W3C** efímero (sin emulador QEMU/KVM Android embebido).

## Herramientas Prehorneadas

* **Runtime:** Node.js `26` (`slim`), `pnpm`, `TypeScript` y `npm-shield.sh`
* **Java y Android SDK:** OpenJDK `21` Headless JRE, `platform-tools` (`adb`), `build-tools;35.0.0` (`aapt2`, `apksigner`, `zipalign`), `platforms;android-35`
* **W3C Móvil y Screenplay:** Appium `3.x` con drivers preinstalados (`uiautomator2`, `xcuitest`) bajo `APPIUM_HOME=/opt/appium-home`
* **Runner de Pruebas:** WebdriverIO `v9` (`webdriverio`, `@wdio/cli`, `@wdio/local-runner`, `@wdio/mocha-framework`, `@wdio/spec-reporter`, `@wdio/appium-service`, `@wdio/allure-reporter`)
* **Cadena de Suministro y No-Root:** Compilación determinista con lockfile (`qa11x-tools/package-lock.json`), herramientas Android verificadas por SHA-256, SBOM CycloneDX (`/opt/qa11x/sbom.cdx.json`), usuario por defecto `USER 10001:10001` compatible con `-u "$(id -u):$(id -g)"` y `--read-only`.

## Validación y Compilación Local

```bash
# Compilar en local, ejecutar pruebas smoke aisladas read-only + Trivy (HIGH/CRITICAL = 0), sin push:
./build --local
```

## Obtener esta Imagen

* https://hub.docker.com/r/sinfallas/base-mobile-appium

Copyright (C) 2026 Jesus Palencia <sinfallas@gmail.com> (Creado en Tecno Consultores)
