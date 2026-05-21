#!/usr/bin/zsh -f

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

build() {
    nasm -f elf64 assembly.asm -o assembly.o

    ld assembly.o -o exe
    exit

}

case $1 in
"d" | "dump")
    dump "$2"
    ;;
"c" | "clean")
    clean
    ;;
*)
    build
    ;;
esac
