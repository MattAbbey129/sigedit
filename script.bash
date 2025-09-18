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

    if [[ ! -f "${FILE_PATH}" ]]; then
        echo 'Message not saved'
        exit 1
    elif [[ -z "$(cat ${FILE_PATH})" || -z "$(cat ${FILE_PATH} | tr -d '[:space:]')" ]]; then
        echo 'Message is empty'
        exit 1
    fi

    echo -e "\n${FILE_PATH}"
    echo -e '\n-----BEGIN PGP SIGNED MESSAGE-----\n'
    cat "${FILE_PATH}"
    echo -e '\n------END PGP SIGNED MESSAGE------\n'

    echo 'Type the action to perform and press ENTER, or press CTRL+C to cancel'
    echo '(Pressing ENTER without making a selection will default to: sign)'

    local MESSAGE_ACTION=''

    while true; do
        printf '\n'
        read -rp '[ s/sign | e/edit | c/cancel | d/delete ] ' MESSAGE_ACTION
    done

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
