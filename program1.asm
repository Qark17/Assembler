section .text
    global _start

_start:
    mov EAX, 1
    mov EBX, 2

    mov EDX, EAX
    mov EAX, EBX
    mov EBX, EDX
    mov EDX, 0

    xchg EAX, EBX

    push EAX
    push EBX
    pop EAX
    pop EBX

    lea EDX, [EAX]
    lea EAX, [EBX]
    lea EBX, [EDX]
    mov EDX, 0

    mov EAX, 0         
    mov EBX, 0


    mov CX, 1
    mov DX, 2

    mov AX, CX
    mov CX, DX
    mov DX, AX
    mov AX, 0

    xchg CX, DX

    xor CX, DX
    xor DX, CX
    xor CX, DX

    push CX
    push DX
    pop CX
    pop DX

    mov CX, 0         
    mov DX, 0



    mov AL, 1
    mov BL, 2

    mov DL, AL
    mov AL, BL
    mov BL, DL
    mov DL, 0

    xchg AL, BL

    xor AL, BL
    xor BL, AL
    xor AL, BL

    mov AL, 0         
    mov BL, 0

    int 0x80
