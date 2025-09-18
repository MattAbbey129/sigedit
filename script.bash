#!/usr/bin/env bash

# SPDX-License-Identifier: MIT
# Copyright © 2025 Matt Abbey

main() {

    mkdir -p "${HOME}/.local/state/sigedit"
    local FILE_PATH="${HOME}/.local/state/sigedit/$(mktemp --dry-run "$(date +%Y%m%d%H%M%S)".XXXXXXXXXX)"
    readonly FILE_PATH

    "${EDITOR}" "${FILE_PATH}"

    cat "${FILE_PATH}"

    read -rp 'Press ENTER to sign this message. '

    gpg --clear-sign --output "${FILE_PATH}.asc" "${FILE_PATH}"
    cat "${FILE_PATH}.asc"

}

main
