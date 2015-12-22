

SECTION .data		; Data section, initialized variables

	msg: db `\n`, 
	msgLen equ $-msg
	
	buffLen equ 80
	buff: times (buffLen+1) db 0
	
	opBuffLen equ 40
	opBuff: times (opBuffLen+1) db 0
	
	
	operations:
	db "+", 0
	 	dd fnAdd
	db "-", 0
		dd fnSub

	db "*", 0
		dd fnMul
	db "**", 0
		dd fnHiMul

	db "/", 0
		dd fnDiv
	db "%", 0
		dd fnMod
	db "//", 0 
		dd fnMod

	db "^", 0
		dd fnPow

	db "|", 0
		dd fnBwOr
	db "&", 0
		dd fnBwAnd
	db "$xor", 0
		dd fnBwXor
	
	db ",", 0
		dd 0
	db ")", 0
		dd 0
	db 0 
		dd 0 ; by "default"
	
	operationsLen equ $-operations
	operationsEnd equ $

SECTION .text                   ; Code section.
        global _start
 
_start:

writeMessage:
mov        eax, 4
mov        ebx, 1
mov        ecx, msg
mov        edx, msgLen
int        80h


mov ecx, 20     ; 80/4 ; bufer size for eraseBuffer
mov edi, buff   ; change the destination pointer to the beginning of buff
call eraseBuffer

read:                            ; read from stdin into the buffer.
mov        eax, 3
mov        ebx, 0
mov        ecx, buff
mov        edx, buffLen
int        80h


mov esi, buff
call readMathExpression






;add eax, 1
mov ecx, 20     ; 80/4 ; bufer size for eraseBuffer
mov edi, buff   ; change the destination pointer to the beginning of buff
call eraseBuffer

;inc eax; To prove that it is interpreted as a number, I increment it!

mov edi, buff
call writeNumber

echoInput:						; write to stdout from the buffer.
;.loopStart:
;cmp esi,0
;je  .loopEnd

mov        eax, 4
mov        ebx, 1
mov        ecx, buff
mov        edx, buffLen
int        80h

;dec esi
;jmp .loopStart

;.loopEnd:



jmp _start






eraseBuffer:    
		; edi: buffer pointer, ecx: buffer size
	
	push eax
	
	mov eax, 0       ; set the value of the buffer to zero
	;cld  0  ;set direction flag to 0, so to have forwars motion.
	rep stosd       ; set byte in string ecx (or cx, not sure) times.
	
	pop eax
ret



readMathExpression:
	; string pointer comes into esi
	; expected that the string finishes by 0
	

		;mov eax, 0
		
		mov ecx, 0 ; counting of open paranthesises
		
	.start:
		push 0
		push fnStartOfExpression
		
	.readSingle:
		;call skipSpaces
		mov al, [esi]
		cmp al, '('
		jne .readNumber
		;
	.openParanthesis:
		
		inc ecx
		inc esi
		
		jmp .start
	
	.readNumber:
		call readNumber
		mov edx, eax
		pop ebx
		pop eax
		call ebx
		push eax
		
	.readOp:
		call readOp
		cmp eax, 0
		je .notOp
		push eax
		jmp .readSingle
	
	.notOp:
		mov al, [esi]
		cmp al, ')'
		jne .finish
		cmp ecx, 0
		jle .finish
		inc esi
		;
	.closeParanthesis:
		pop edx
		pop ebx
		pop eax   ;;;;;;;;;
		call ebx
		push eax
		dec ecx
		jmp .readOp
	.finish:
	
		cmp ecx, 0
		ja .closeParanthesis
		
	.end:
		pop eax


ret



readOp:
		;buffer pointer comes into esi
		;op number, and latter function pointer, will come out of eax

		call skipSpaces
		push ebx
		push ecx
		push edx
		
		mov eax, 0
	
		push esi
		mov edi, operations
		
		
	.opListSectionStart:
		mov cl, 0 ; used to show if the strings have been matching until now
		pop esi
		push esi
		
	.opListSectionReadChar:
		
		mov al, [esi]
		mov bl, [edi]
		
		cmp bl, 0
		je .opListSectionEnd
		
		inc esi
		inc edi
		
		cmp al,bl
		je .l1
			mov cl, 1
		.l1:
		jmp .opListSectionReadChar
		
		
	.opListSectionEnd:
		cmp cl, 0
		je .rightOp
	.wrongOp:
		inc edi
		add edi, 4 ;yeah, I could totally put those two comands together.
		cmp edi, operationsEnd
		jb .opListSectionStart
		;
	.opListEnd:
		mov al, 255
		jmp .end
		
	.rightOp:
		inc edi
		mov eax, [edi]
		cmp eax, 0
		je .endOfExp
		pop edx; get rid of the beggining pointer
		jmp .end
		
	.endOfExp:
		pop esi; take back the pointer that came in at beginning
		;
	.end:
		pop edx
		pop ecx
		pop ebx


ret






skipSpaces:
			; buffer pointer comes into esi
		
		push eax
		
	.start:
		mov al, [esi]
	
		cmp al, ' '
		jne .end
		
		inc esi
		
		jmp .start
		
	.end:
		pop eax
ret



writeNumber:
	; string pointer comes in edi
	; number comes in eax
		
		push eax
		push ebx
		push ecx
		push edx
		
	.checkIfSigned:
		cmp eax, 0
		jge .startBreakingUp
		mov byte [edi], '-'
		inc edi
		neg eax
		
		
	.startBreakingUp:
		
		
		mov ecx, 0 ;counter
		mov ebx, 10 ;variable to divide by 10
		
	.breakUpNumber:	
		mov edx, 0
		div ebx  ;divide by 10
		push edx
		inc ecx
		cmp eax, 0
		jne .breakUpNumber
	
	.writeNumber:
	
		cmp ecx, 0
		je .end
		
		pop eax
		add al, '0'
		stosb
		
		dec ecx
		jmp .writeNumber
	
	
	.end:
		pop edx
		pop ecx
		pop ebx
		pop eax
	
ret

	


readNumber:

	; string pointer comes in esi
	; number comes out of eax. pointer will come out of esi
		
		
		push ebx
		push ecx
		push edx
		push edi
		
		call skipSpaces
		xor ecx,ecx
		
	.getDigits:

		mov eax, 0
		mov al, [esi]
		call digitToNumber
		cmp al, 255
		je .startMakingNumber
		push eax
		inc ecx
		inc esi
		jmp .getDigits
	
	.startMakingNumber:
		
		mov ebx, 1
		mov edi, 0

	.makingNumbersLoop:	
		cmp ecx,0
		je .end
		pop eax
		mul ebx
		add edi, eax
		mov eax, 10
		mul ebx
		mov ebx, eax
		
		dec ecx
		jmp .makingNumbersLoop

	.end:
	
		mov eax, edi 
		
		pop edi
		pop edx
		pop ecx
		pop ebx

ret
;;;;;;;;;;;;;;


	
	
digitToNumber: 

; digit comes in al, number comes out of al, it is 255 if error
	cmp al, '0'
	jl .error
	cmp al, '9'
	jg .error
	
	sub al, '0'
	ret	
	
.error:
mov al,255
ret

;;;;;;	





;;;;;;;;;;;;;;;;;;;
fnStartOfExpression:
	mov eax, edx
ret

;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;Operators;;;;;;;;;;;;;;


fnAdd: 
	add eax, edx
ret

fnSub: 
	sub eax, edx
ret

fnMul:
	imul edx
ret


fnDiv:
	push ebx
	mov ebx, edx
	cdq
	idiv ebx
	pop ebx
ret


fnMod:
	push ebx
	mov ebx, edx
	cdq
	idiv ebx
	mov eax, edx
	pop ebx
ret

fnHiMul:
	imul edx
	mov eax, edx

ret

fnPow:
	push ebx
	push ecx
	push esi
	push edi
	
	mov ebx, eax
	mov eax, 1
	mov ecx, edx
	.multLoop:
	cmp ecx, 0
	jle .end
	
	imul ebx
	
	dec ecx
	jmp .multLoop
	.end:
	
	pop edi
	pop esi
	pop ecx
	pop ebx
ret

fnBwAnd:
	
	and ax, dx
ret

fnBwOr:

	or ax, dx
	
ret

fnBwXor:

	xor ax, dx
	
ret

