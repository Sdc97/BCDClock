;Program: BCD Clock ASM file
;Author: Steven Calvert and Subham Thakulla Kshetri
;Date: 06/03/19
;Class: CSCI 150
;Description: Assembly helper file, has procedure to
;	transform a TimeInfo struct into a 4 character clock,
;	and has the tickClock procedure which uses other assembly
;	only procedures to advance the clock by one second and
;	update all other relevant information.
;
; The following code is written by us.

INCLUDE Irvine32.inc
.data

.code


;	setClock Procedure
;	Receives: clock[] array to store characters,
;	tmPtr pointer to TimeInfo object
;	Outputs: Nothing
;	Description: Uses the information stored in
;	the TimeInfo object to fill the clock[] array
;	in BCD format.
setClock PROC C
	push ebp
	mov ebp,esp
	pushad
	mov edi,[ebp+12] ;Address of the timeInfo struct
	mov esi,[ebp+8] ;Address of clock
	
	mov ecx,3
L1:
	mov ebx,10
	mov edx,0
	mov eax,DWORD PTR [edi]
	div ebx
	shl eax,4
	add eax,edx
	mov BYTE PTR [esi],al
	inc esi
	add edi,4
	loop L1

	mov eax, DWORD PTR [edi]
	mov BYTE PTR [esi],al

	popad
	pop ebp
	ret
setClock ENDP

;	tickClock Procedure
;	Recieves: clock[] in BCD format
;	Outputs: Nothing
;	Description: increments the clock by one second,
;	using incrementClockValue to ensure that no digits
;	go above their maximum.
tickClock PROC C
	push ebp
	mov ebp,esp
	pushad
	mov ebx, 0
	mov esi,[ebp+8]
	add esi,2
	
	mov ecx, 2
L1:
	movzx edx, BYTE PTR [esi] ; EDX holds the value
	mov eax, edx ; Copy to eax
	and eax, 0Fh ; Get lower 4 bits of, "ones"
	push eax
	push 9 ; Max value of ones
	call incrementClockValue
	mov ebx,edx ;copy seconds into ebx
	and ebx, 0F0h ;Keep upper half
	add ebx,eax	;New updated value
	mov BYTE PTR [esi], bl ; Update value in memory
	cmp al,0
	jne done

	movzx edx, BYTE PTR [esi] ; EDX holds the value
	mov eax, edx ; Copy to eax
	and eax, 0F0h ; Get upper 4 bits, "tens
	shr eax, 4 ; Shift into lower 4 position
	push eax
	push 5 ; Max value of tens
	call incrementClockValue
	shl eax, 4 ; Shift tens back
	mov ebx,edx ;copy original into ebx
	and ebx, 0Fh ;Keep lower half
	add ebx,eax	;New updated value
	mov BYTE PTR [esi], bl ; Update value in memory
	cmp al,0
	jne done
	dec esi
	loop L1 ; Done with seconds and minutes

	mov ecx,0
	mov ebx,0
	; Now handle hours, and AM PM if applicable
	movzx edx, BYTE PTR [esi] ; Copy hours to edx
	shld cx,dx,12 ; Grab upper four bits, tens
	mov ebx,edx ; Copy value to ebx
	and ebx, 0Fh ;Keep lower 4 bits.
	push ebx
	cmp cl, 1
	jne less ;If tens is 1, max is 2, otherwise max is 9
	push 2
	jmp cont
less:
	push 9
cont:
	call incrementClockValue ; eax holds incremented value
	mov ecx, edx ; Copy value back
	and ecx, 0F0h ; Keep upper half
	add ecx, eax ; New clock value
	mov BYTE PTR [esi], cl ; Update value in memory
	cmp cl,12h ;If hours hits 12, change AM PM value
	jne keepAMPM
	add esi,3
	push esi
	sub esi, 3
	call toggleAMPM
keepAMPM:
	cmp al, 0
	jne done

	mov ebx,0
	; Lastly, handle cases where hours need to be incremented past 12, or to 10
	movzx edx, BYTE PTR [esi] ; Copy hours to edx
	shld bx,dx,12 ; Grab hours from edx
	push ebx
	push 1
	call incrementClockValue
	mov ecx, edx ; Copy value back
	and ecx, 0Fh ; Keep lower half
	shl eax, 4
	add ecx, eax ; New clock value
	mov BYTE PTR [esi], cl ; Update value in memory
	cmp al,0
	jne done

	mov al,1
	mov BYTE PTR [esi], al

done:
	popad
	pop ebp
	ret
tickClock ENDP

;	incrementClockValue Procedure
;	Recieves: BCDbits, maxValue
;	Outputs: BCDBits in al incremented appropriately
;	Description: helps determine if a digit is above
;	the max value for its place, increments a value by one.
incrementClockValue PROC
	push ebp
	mov ebp,esp
	push ebx
	movzx eax, BYTE PTR [ebp+12] ; 4 bits to be modified.
	mov ebx, [ebp+8] ; Max value
	inc eax
	cmp eax, ebx
	ja reset ; If incremented value > max value, reset to 0
	pop ebx
	pop ebp
	ret 8

reset:
	mov eax, 0
	pop ebx
	pop ebp
	ret 8

incrementClockValue ENDP

toggleAMPM PROC
	push ebp
	mov ebp,esp
	push esi
	mov esi, [ebp+8]
	cmp BYTE PTR [esi], 'A'
	jne other
	mov BYTE PTR [esi], 'P'
	jmp done
other:
	mov BYTE PTR [esi], 'A'
done:
	pop esi
	pop ebp
	ret 4
toggleAMPM ENDP

END 