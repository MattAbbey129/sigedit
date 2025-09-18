#!/usr/bin/env bash

# SPDX-License-Identifier: MIT
# Copyright © 2025 Matt Abbey

check_if_editor_is_set() {
    if [[ -z "${EDITOR}" ]]; then
        echo '$EDITOR not set'
        exit 1
    else
        echo "Editing message with: ${EDITOR}"
    fi
}

generate_file_path() {
    mkdir -p "${HOME}/.local/state/sigedit"
    echo "${HOME}/.local/state/sigedit/$(mktemp --dry-run "$(date +%Y%m%d%H%M%S)".XXXXXXXXXX)"
}

main() {

    check_if_editor_is_set

    local FILE_PATH="$(generate_file_path)"
    readonly FILE_PATH

    local MESSAGE_FINISHED=false
    while ! ${MESSAGE_FINISHED}; do
        # Open editor and edit message.
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

            if [[ -z "${MESSAGE_ACTION}" || "${MESSAGE_ACTION}" == 's' || "${MESSAGE_ACTION}" == 'sign' ]]; then
                local MESSAGE_FINISHED=true
                echo -e 'Signing message...\n'
                break # from this 'while true' loop
            elif [[ "${MESSAGE_ACTION}" == 'e' || "${MESSAGE_ACTION}" == 'edit' ]]; then
                echo 'Editing message...'
                break # from this 'while true' loop
            elif [[ "${MESSAGE_ACTION}" == 'c' || "${MESSAGE_ACTION}" == 'cancel' ]]; then
                exit 0
            elif [[ "${MESSAGE_ACTION}" == 'd' || "${MESSAGE_ACTION}" == 'delete' ]]; then
                local DELETION_ACTION=''
                read -rp 'Are you sure you want to cancel and delete this message? [y/N] ' DELETEION_ACTION
                if [[ "${DELETEION_ACTION}" == 'y' ]]; then
                    rm "${FILE_PATH}" && echo 'Message deleted'
                    exit 0
                else
                    echo 'Not deleting message'
                fi
            else
                echo "Unknown action: ${MESSAGE_ACTION}"
            fi
        done
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
