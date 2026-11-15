#!/usr/bin/env bash
# Made by Sinfallas <sinfallas@gmail.com>
# Licence: GPL-2

set -euo pipefail

if [[ "$EUID" -eq 0 ]]; then
	printf '\033[0;31mERROR: NO debe ejecutarse como root.\033[0m\n' >&2
	exit 1
fi

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

readonly IMAGE_NAME="sinfallas/base-mobile-appium"
readonly BUILDER_NAME="container-builder"
readonly PLATFORMS="linux/arm64,linux/amd64"
readonly TRIVY_DB_REPOS="public.ecr.aws/aquasecurity/trivy-db:2,ghcr.io/aquasecurity/trivy-db:2,mirror.gcr.io/aquasec/trivy-db:2"
readonly TRIVY_JAVA_DB_REPOS="public.ecr.aws/aquasecurity/trivy-java-db:1,ghcr.io/aquasecurity/trivy-java-db:1,mirror.gcr.io/aquasec/trivy-java-db:1"

LOCAL_ONLY=0
if [[ "${1:-}" == "--local" ]]; then
	LOCAL_ONLY=1
fi
readonly LOCAL_ONLY

case "$(uname -m)" in
	x86_64|amd64)
		HOST_PLATFORM="linux/amd64"
		;;
	aarch64|arm64)
		HOST_PLATFORM="linux/arm64"
		;;
	*)
		printf '\033[0;31mERROR: Arquitectura de host no soportada: %s.\033[0m\n' "$(uname -m)" >&2
		exit 1
		;;
esac
readonly HOST_PLATFORM

ACTIVE_TEST_TAG=""

limpiar_recursos_temporales() {
	if [[ -n "$ACTIVE_TEST_TAG" ]]; then
		docker image rm -f "$ACTIVE_TEST_TAG" >/dev/null 2>&1 || true
	fi
	docker buildx rm -f "$BUILDER_NAME" >/dev/null 2>&1 || true
}

trap limpiar_recursos_temporales EXIT

if ! docker info >/dev/null 2>&1; then
	printf '\033[0;31mERROR: El demonio de Docker no está disponible o el usuario no tiene permisos.\033[0m\n' >&2
	exit 1
fi

if [[ ! -f "${SCRIPT_DIR}/example/package.json" || ! -f "${SCRIPT_DIR}/qa11x-tools/package-lock.json" ]]; then
	printf '\033[0;31mERROR: Faltan artefactos example/ o qa11x-tools/package-lock.json en %s.\033[0m\n' "$SCRIPT_DIR" >&2
	exit 1
fi

if [[ -t 1 ]]; then
	clear || true
fi

CURRENT_DATE="$(date -u +'%Y-%m-%dT%H:%M:%SZ')"
readonly CURRENT_DATE

validar_imagen() {
	local test_tag="$1"
	local host_uid
	local host_gid
	host_uid="$(id -u)"
	host_gid="$(id -g)"

	printf '\033[1;33m==> Validando %s en modo no-root, read-only y air-gapped...\033[0m\n' "$test_tag"
	docker run --rm "$test_tag" bash -euo pipefail -c '
		[[ "$(id -u)" -eq 10001 ]]
		node --version >/dev/null
		pnpm --version >/dev/null
		java -version >/dev/null 2>&1
		adb version >/dev/null
		aapt2 version >/dev/null 2>&1 || [[ -x /usr/local/bin/aapt2 ]]
		apksigner version >/dev/null 2>&1 || [[ -x /usr/local/bin/apksigner ]]
		appium --version >/dev/null
		wdio --version >/dev/null
		tsc --version >/dev/null
		[[ -s /opt/qa11x/sbom.cdx.json ]]

		if npm install >/dev/null 2>&1; then
			printf "ERROR: npm-shield no bloqueó npm install\n" >&2
			exit 1
		fi
	'

	docker run --rm \
		--network none \
		--read-only \
		--tmpfs /tmp:rw,exec,nosuid,nodev \
		-u "${host_uid}:${host_gid}" \
		-e HOME=/tmp \
		-v "${SCRIPT_DIR}/example:/app:ro" \
		-w /app \
		"$test_tag" \
		bash -euo pipefail -c '
			drivers_json="$(appium driver list --installed --json)"
			node -e "
				const d = JSON.parse(process.argv[1]);
				if (!d.uiautomator2 || !d.xcuitest) {
					console.error(\"Drivers Appium faltantes:\", Object.keys(d));
					process.exit(1);
				}
			" "$drivers_json"
			tsc --strict --noImplicitAny --noUnusedLocals --noUnusedParameters \
				--noImplicitReturns --erasableSyntaxOnly --allowImportingTsExtensions \
				--target ES2023 --module NodeNext --moduleResolution NodeNext \
				--typeRoots /opt/qa11x/node_modules/@types --types node --noEmit smoke.ts
			node --experimental-strip-types smoke.ts | grep -qx "mobile-appium-smoke-ok"
		'

	printf '\033[1;33m==> Auditando %s con Trivy (HIGH/CRITICAL = 0)...\033[0m\n' "$test_tag"
	docker run --rm \
		-v /var/run/docker.sock:/var/run/docker.sock:ro \
		-v qa11x_trivy_cache:/root/.cache/trivy \
		aquasec/trivy:latest image \
		--db-repository "${TRIVY_DB_REPOS}" \
		--java-db-repository "${TRIVY_JAVA_DB_REPOS}" \
		--severity HIGH,CRITICAL \
		--ignore-unfixed \
		--exit-code 1 \
		"$test_tag"
}

construir_imagen() {
	local dockerfile="$1"
	shift
	local primary_tag="$1"
	local test_tag="${IMAGE_NAME}:validate-${primary_tag}"
	local tags=()
	local tag

	if [[ ! -f "$dockerfile" ]]; then
		printf '\033[0;31mERROR: No se encontró %s en %s.\033[0m\n' "$dockerfile" "$SCRIPT_DIR" >&2
		exit 1
	fi

	for tag in "$@"; do
		tags+=(-t "${IMAGE_NAME}:${tag}")
	done

	ACTIVE_TEST_TAG="$test_tag"
	printf '\033[1;34m==> [1/3] Compilando %s en local (%s) para validación...\033[0m\n' "$dockerfile" "$HOST_PLATFORM"
	if [[ "$LOCAL_ONLY" -eq 1 ]]; then
		DOCKER_BUILDKIT=1 docker build \
			--pull \
			--build-arg "BUILD_DATE=${CURRENT_DATE}" \
			-t "$test_tag" \
			-f "$dockerfile" \
			.
	else
		docker buildx build \
			--builder="$BUILDER_NAME" \
			--platform="$HOST_PLATFORM" \
			--pull \
			--build-arg "BUILD_DATE=${CURRENT_DATE}" \
			--load \
			-t "$test_tag" \
			-f "$dockerfile" \
			.
	fi

	printf '\033[1;34m==> [2/3] Ejecutando pruebas smoke y Trivy sobre %s...\033[0m\n' "$test_tag"
	validar_imagen "$test_tag"

	if [[ "$LOCAL_ONLY" -eq 1 ]]; then
		for tag in "$@"; do
			docker tag "$test_tag" "${IMAGE_NAME}:${tag}"
		done
		docker image rm -f "$test_tag" >/dev/null 2>&1 || true
		ACTIVE_TEST_TAG=""
		printf '\033[1;32m==> [3/3] Modo --local completado sin push. Tags locales: %s\033[0m\n' "$*"
		return 0
	fi

	docker image rm -f "$test_tag" >/dev/null 2>&1 || true
	ACTIVE_TEST_TAG=""

	printf '\033[1;34m==> [3/3] Publicando %s multi-arch (%s) con tags: %s...\033[0m\n' "$dockerfile" "$PLATFORMS" "$*"
	docker buildx build \
		--builder="$BUILDER_NAME" \
		--platform="$PLATFORMS" \
		--pull \
		--build-arg "BUILD_DATE=${CURRENT_DATE}" \
		--push \
		"${tags[@]}" \
		-f "$dockerfile" \
		.
}

if [[ "$LOCAL_ONLY" -eq 0 ]]; then
	if ! docker buildx ls 2>/dev/null | grep -q 'linux/arm64'; then
		docker run --privileged --rm tonistiigi/binfmt --install all >/dev/null 2>&1 || true
	fi
	limpiar_recursos_temporales
	docker buildx create --name "$BUILDER_NAME" --driver docker-container --bootstrap --use
fi

construir_imagen Dockerfile26 26 latest

limpiar_recursos_temporales
if [[ "$LOCAL_ONLY" -eq 0 ]]; then
	docker builder prune -af
	docker buildx prune -af
fi

printf '\033[1;32mfinalizado...\033[0m\n'
