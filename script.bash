#!/usr/bin/env bash

# SPDX-License-Identifier: MIT
# Copyright © 2025 Matt Abbey

main() {

    if [[ -z "${EDITOR}" ]]; then
        echo '$EDITOR not set'
        exit 1
    else
        echo "Editing message with: ${EDITOR}"
    fi

    mkdir -p "${HOME}/.local/state/sigedit"
    local FILE_PATH="${HOME}/.local/state/sigedit/$(mktemp --dry-run "$(date +%Y%m%d%H%M%S)".XXXXXXXXXX)"
    readonly FILE_PATH

    "${EDITOR}" "${FILE_PATH}"

    echo -e "\n${FILE_PATH}"
    echo -e '\n-----BEGIN PGP SIGNED MESSAGE-----\n'
    cat "${FILE_PATH}"
    echo -e '\n------END PGP SIGNED MESSAGE------\n'

    read -rp 'Press ENTER to sign this message. '

    gpg --clear-sign --output "${FILE_PATH}.asc" "${FILE_PATH}"
    if [[ "${?}" -eq 0 ]]; then
        printf '\n'
        cat "${FILE_PATH}.asc"
        echo -e "\nMessage file saved as: ${FILE_PATH}.asc"
        exit 0
    else
        echo -e "\nMessage not signed. Message file is at '${FILE_PATH}' if you want to try again with 'gpg --clear-sign'"
        exit 1
    fi

}

main
