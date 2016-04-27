org 7C00h

cli ; Disable interrupts

; Reset some registers
xor ax, ax
mov ds, ax
mov es, ax
cld
mov [drive_number], dl

; Set graphics mode
mov ah, 00h
mov al, 13h
int 10h

; Get drive parameters
mov di, 0
mov ah, 08h
mov dl, [drive_number]
int 13h
and cl, 3fh
mov [max_sector], cl
mov [max_head], dh

; Set extra segment to temporary location
mov ax, 01000h
mov es, ax
mov bx, 0

; Set initial sector
mov byte [cur_cylinder], 0
mov byte [cur_head], 0
mov byte [cur_sector], 2
mov dl, [drive_number]
; Read sector
read_sector:
mov ah, 02h
mov al, 1
mov ch, [cur_cylinder]
mov cl, [cur_sector]
mov dh, [cur_head]
mov bp, 2
perform_read:
push ax
int 13h
jnc read_done
; Retry on error
sub bp, 1
jc read_done
xor ax, ax
int 13h
pop ax
jmp perform_read
read_done:
; Increment values
inc cl
cmp cl, [max_sector]
jbe sector_no_overflow
mov cl, 1
inc dh
sector_no_overflow:
mov [cur_sector], cl
cmp dh, [max_head]
jbe head_no_overflow
mov dh, 0
inc ch
mov [cur_cylinder], ch
head_no_overflow:
mov [cur_head], dh
add bx, 512
cmp bx, 64000
jb read_sector

; Copy data from temporary location to video memory
mov ax, 1000h
mov ds, ax
mov ax, 0a000h
mov es, ax
mov si, 0
mov di, 0
mov cx, 64000
rep movsb

hlt ; Stop here

; Fill with null
times 510-($-$$) db 0

; Bootable flag
dw 0xAA55

; Variables
max_sector equ 7000h
max_head equ 7001h
cur_cylinder equ 7002
cur_sector equ 7003h
cur_head equ 7004h
drive_number equ 7005h
