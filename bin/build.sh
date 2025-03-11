#!/usr/bin/env bash
set -ueo pipefail
: "${TEXLIVE_CONT_NAME:="texlive-resume-${USER}"}"
: "${TEXLIVE_CONT_COMMAND:="sleep 5555"}"
# shellcheck disable=1091
MY_BIN="$(readlink -f "$0")"
MY_PATH="$(dirname "${MY_BIN}")"
if [[ "$(
  /usr/bin/env podman inspect "${TEXLIVE_CONT_NAME}" -f "
    {{- range .Mounts -}}
      {{- if eq .Destination \"/workdir\" -}}
        {{- .Source -}}{{- break -}}
      {{- end -}}
    {{- end -}}
  " 2>/dev/null || true
)" != "$(pwd)" ]]; then
  echo "path changed, destroying container…"
  /usr/bin/env podman rm -f "${TEXLIVE_CONT_NAME}" 2>/dev/null || true
fi
if [[ "$(
  /usr/bin/env podman container inspect -f '{{.State.Status}}' \
    "${TEXLIVE_CONT_NAME}" 2>/dev/null || true
)" != "running" ]]; then
  # shellcheck disable=2086
  /usr/bin/env \
    podman run -it -d --name="${TEXLIVE_CONT_NAME}" --rm \
    -v "$(pwd):/workdir" ghcr.io/raven428/container-images/texlive-myminimal:latest \
    ${TEXLIVE_CONT_COMMAND}
  /usr/bin/env
  podman exec "${TEXLIVE_CONT_NAME}" bash -c "rm -rfv \
  /usr/local/texlive/*/texmf-dist/fonts/type1/adobe"
fi
for texfile in "${MY_PATH}/../"*.tex; do
  podman exec -w /workdir "${TEXLIVE_CONT_NAME}" xelatex "$(basename "${texfile}")"
done
