#!/usr/bin/zsh -f
set -Eeo pipefail

help() {
    echo -e "$1 \t\t\tbuild the executable."
    echo -e "$1 \tb|debug \tbuild with debug symbols."
    echo -e "$1 \tc|clean \tremove executable & objects."
    echo -e "$1 \td|dump \t\tobject dump."
    echo -e "$1 \td|dump i|intel \tobject dump with intel syntax."
    echo -e "$1 \th|help \t\tprint this help."
}

dump() {
    if [[ "$1" == "intel" ]] || [[ "$1" == "i" ]]; then
        objdump -d -Mintel exe
    else
        objdump -d exe
    fi
    exit
}

clean() {
    rm assembly.o exe
    exit
}

debug() {
    nasm -f elf64 -g -F dwarf assembly.asm -o assembly.o
    ld assembly.o -o exe
    exit
}
build() {
    nasm -f elf64 assembly.asm -o assembly.o
    ld assembly.o -o exe
    exit
}

case $1 in
"b" | "debug")
    debug
    ;;
"c" | "clean")
    clean
    ;;
"d" | "dump")
    dump "$2"
    ;;
"h" | "help")
    help "$0"
    exit
    ;;
"")
    build
    ;;
*)
    help "$0"
    exit 1
    ;;
esac
