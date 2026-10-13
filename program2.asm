bits 32
section .data
    a   dd 5678901
    b   dd 6789012
    c   dd 7890123
    d   dd 8901234
    e   dd 9012345
    f   dd 10123456
    const_23 dd 23

section .bss
    res_quotient    resd 1
    res_remainder   resd 1

section .text
    global _start

_start:
    mov eax, [c]
    mov ecx, 4
    mul ecx
    mov ebx, eax

    mov eax, [d]
    sar eax, 1

    sub ebx, eax
    add ebx, [const_23]

    mov eax, [a]
    mul eax

    dec eax
    mov esi, eax

    mov eax, ebx
    cdq
    idiv esi

    mov [res_quotient], eax
    mov [res_remainder], edx

    mov eax, 1
    xor ebx, ebx
    int 0x80
