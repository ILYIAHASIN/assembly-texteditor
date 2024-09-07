section .data
    prompt db "Text Editor Menu:", 10
           db "1. Enter/Edit Text", 10
           db "2. Save to File", 10
           db "3. Display File Contents", 10
           db "4. Exit", 10
           db "Enter your choice: ", 0
    prompt_len equ $ - prompt

    input_prompt db "Enter text (max 1000 chars, end with Enter): ", 0
    input_prompt_len equ $ - input_prompt

    filename db "text_file.txt", 0
    save_msg db "Text saved to file.", 10, 0
    save_msg_len equ $ - save_msg

    read_error_msg db "Error reading file.", 10, 0
    read_error_msg_len equ $ - read_error_msg

section .bss
    choice resb 2
    text_buffer resb 1001
    file_buffer resb 1001

section .text
    global _start

_start:
    ; Main loop
    .menu_loop:
        ; Display menu
        mov eax, 4
        mov ebx, 1
        mov ecx, prompt
        mov edx, prompt_len
        int 0x80

        ; Read user choice
        mov eax, 3
        mov ebx, 0
        mov ecx, choice
        mov edx, 2
        int 0x80

        ; Process user choice
        mov al, [choice]
        cmp al, '1'
        je enter_text
        cmp al, '2'
        je save_to_file
        cmp al, '3'
        je display_file
        cmp al, '4'
        je exit_program

        jmp .menu_loop

enter_text:
    ; Display input prompt
    mov eax, 4
    mov ebx, 1
    mov ecx, input_prompt
    mov edx, input_prompt_len
    int 0x80

    ; Read user input
    mov eax, 3
    mov ebx, 0
    mov ecx, text_buffer
    mov edx, 1000
    int 0x80

    jmp .menu_loop

save_to_file:
    ; Open file for writing
    mov eax, 5
    mov ebx, filename
    mov ecx, 0x41    ; O_WRONLY | O_CREAT
    mov edx, 0666o   ; File permissions
    int 0x80

    ; Write to file
    mov ebx, eax     ; File descriptor
    mov eax, 4
    mov ecx, text_buffer
    mov edx, 1000
    int 0x80

    ; Close file
    mov eax, 6
    int 0x80

    ; Display save message
    mov eax, 4
    mov ebx, 1
    mov ecx, save_msg
    mov edx, save_msg_len
    int 0x80

    jmp .menu_loop

display_file:
    ; Open file for reading
    mov eax, 5
    mov ebx, filename
    mov ecx, 0       ; O_RDONLY
    int 0x80

    ; Read from file
    mov ebx, eax     ; File descriptor
    mov eax, 3
    mov ecx, file_buffer
    mov edx, 1000
    int 0x80

    ; Check for read error
    cmp eax, 0
    jl .read_error

    ; Display file contents
    mov edx, eax     ; Number of bytes read
    mov eax, 4
    mov ebx, 1
    mov ecx, file_buffer
    int 0x80

    jmp .close_file

    .read_error:
        mov eax, 4
        mov ebx, 1
        mov ecx, read_error_msg
        mov edx, read_error_msg_len
        int 0x80

    .close_file:
        ; Close file
        mov eax, 6
        int 0x80

    jmp .menu_loop

exit_program:
    ; Exit the program
    mov eax, 1
    xor ebx, ebx
    int 0x80
