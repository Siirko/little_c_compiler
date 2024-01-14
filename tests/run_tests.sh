#!/bin/bash

CMAT_PATH="$PWD/bin"
mars_command="java -jar Mars.jar me sm nc"

test_file() {
    # print where we are
    file="$1"
    filename=$(basename -- "$file")
    folder=$(dirname -- "$file")
    # if folder == errors grab output
    OUTPUT_PATH="$file"
    if [[ "$folder" == *"errors"* ]] ; then
        # "$CMAT_PATH"/cmat -f "$file" -o /dev/null &> "$OUTPUT_PATH".out
        # redirect output to stderr and stdout
        "$CMAT_PATH"/cmat -f "$file" -o /dev/null > "$OUTPUT_PATH".out 2>&1
        "$CMAT_PATH"/cmat -f "$file" -o /dev/null
        res=$(diff "$OUTPUT_PATH".out "$OUTPUT_PATH".res)
        if [ -z "$res" ] ; then
            echo -e "\e[1;32mTest passed\e[0m"
        else
            echo -e "\e[1;31mTest failed\e[0m"
            echo -e "\e[1;31mDiff:\e[0m"
            echo "$res"
        fi
    else
        "$CMAT_PATH"/cmat -f "$file" -o "$OUTPUT_PATH".asm
        $mars_command "$OUTPUT_PATH".asm &> "$OUTPUT_PATH".out
        $mars_command "$OUTPUT_PATH".asm
        res=$(diff "$OUTPUT_PATH".out "$OUTPUT_PATH".res)
        if [ -z "$res" ] ; then
            echo -e "\e[1;32mTest passed\e[0m"
        else
            echo -e "\e[1;31mTest failed\e[0m"
            echo -e "\e[1;31mDiff:\e[0m"
            echo "$res"
        fi
        rm "$OUTPUT_PATH".asm
    fi
    echo -e "\n\n"
}

function traverse() {
    # $1 hasnt folder tests exit
    for file in "$1"/*
    do
        if [ ! -d "${file}" ] ; then
            # if file has .c extension
            if [[ "$file" == *.c ]] ; then
                # write with color
                echo -e "\e[1;32mTesting file: ${file}\e[0m"
                test_file "${file}"
            fi
        else
            # echo "entering recursion with: ${file}"
            traverse "${file}"
        fi
    done
}

function clear_out(){
    for file in "$1"/*
    do
        if [ ! -d "${file}" ] ; then
            # if file has .c extension
            if [[ "$file" == *.out ]] ; then
                # write with color
                echo -e "\e[1;32mClearing file: ${file}\e[0m"
                rm "${file}"
            fi
        else
            # echo "entering recursion with: ${file}"
            clear_out "${file}"
        fi
    done
}

# Appel initial de la fonction pour commencer le parcours
# traverse "./tests"

if [[ "$1" == "clear_out" ]] ; then
    clear_out "./tests"
else
    traverse "./tests"
fi