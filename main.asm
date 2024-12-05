.386
.model flat, stdcall
.stack 4096
ExitProcess PROTO, dwExitCode: DWORD
INCLUDE Irvine32.inc

;HELP ME!

.data
	;Menu data
	menuTitle	  BYTE 13, 10, 50 DUP(" "), "A Project", 0							;menuTitle string
	promptMessage BYTE 13, 10, 50 DUP(" "), "CHOOSE! (1, 2, 3, or 4)", 0			;Choose string
	invalidOption BYTE 13, 10, 50 DUP(" "), "You're a failure. Try again.", 0		;invalidOption string

	optionsTable BYTE 13, 10, 50 DUP(" "), "1. Basic Writing Test"					;List of options
				 BYTE 10, 13, 50 DUP(" "), "2. Typing Game"
				 BYTE 13, 10, 50 DUP(" "), "3. Show Statistics"
				 BYTE 13, 10, 50 DUP(" "), "4. Exit", 0

	blankLine BYTE 13, 10, 50 DUP(" "), 0

	;Random Paragraph Generator Data
	paragraph		BYTE 1024 DUP(0)								;Buffer for random paragraph
	numWords		DWORD 5										;Max word count
	maxLineLength	DWORD 40										;Max length of line

	;Random Word Generator Data
	maxWordlength	DWORD 8											;Max length of word
	wordBuffer		BYTE 16 DUP(0)									;Buffer for random word
	
	;Basic Writing Test data
	userInput		BYTE 1024 DUP(0)								;Buffer for user input
	sTime			DWORD ?											;start time
	eTime			DWORD ?											;end time
	numCorrect		DWORD 0											;store # of correct words
	resultMessage	BYTE "Basic Typing Test Results", 0				;Result message
	WPM				BYTE "WPM: ", 0									;WPM string
	accuracy		BYTE "Accuracy: ", 0							;Accuracy string
	newLine			BYTE 13, 10, 0	
	paragraphLength DWORD 0											;Length of paragraph
	typedLength		DWORD 0											;Length of typed words
	basicflag 		BYTE 0											;Basic writing test flag

	;Color separation
	redArray		BYTE 1024 DUP(0)
	greenArray		BYTE 1024 DUP(0)
	orderArray		BYTE 1024 DUP(0)
	row				BYTE 0
	col				BYTE 0
	redIndex		DWORD 0
	greenIndex		DWORD 0

	;Falling Words Game Data
	rRow			BYTE 0
	rCol			BYTE 0

	;test data
	testmessage		BYTE "This is a test message", 0
	equal			BYTE "Equal", 0
	notEqual		BYTE "Not Equal!!!!!!!", 0

.code
main PROC

	call Menu ; Call the Menu procedure to display the menu
	call ReadInt													;Read user input
	cmp eax, 0														;Compare user input to 0
	je invalidPrompt												;If user input is invalid, display invalidPrompt
	cmp eax, 4h														;Compare user input to 4
	ja invalidPrompt												;Display invalidPrompt if above menu options	
   
	cmp eax, 1														;Compare user input to 1
	jz callBasic													;If user input is 1, jump to basicWritingTest

	cmp eax, 2														;Compare user input to 2
	jz callTypingGame												;If user input is 2, jump to typingGame
COMMENT @
	cmp eax, 3														;Compare user input to 3
	jz callStatistics												;If user input is 3, jump to showStatistics
	
	callTypingGame:													;Call the word falling game
		call TypingGame
		jmp main
@
	cmp eax, 4														;Compare user input to 4
	jz exitProgram													;If user input is 4, jump to exitProgram

	callTypingGame:													;Call the word falling game
		call TypingGame
		jmp main

	callBasic:
		call ClrScr
		call BasicWritingTest
		ret

	invalidPrompt:													;Display invalidOption if user input is invalid	
		mov edx, OFFSET invalidOption
		call WriteString
		call ClrScr
		jmp main

	exitProgram:													;Exit the program
		INVOKE ExitProcess, 0
	

main ENDP
;---------------------------------------------------------------------------------------------------------------------
Menu PROC
	mov ecx, 10													    ;Set menu to the middle using the most brute force method known to mankind
	mov edx, OFFSET blankLine
	blankLoop:
		call WriteString
		loop blankLoop

	mov edx, OFFSET menuTitle										
	call WriteString												;Display menuTitle
	mov edx, OFFSET promptMessage
	call WriteString												;Display promptMessage
	mov edx, OFFSET optionsTable
	call WriteString												;Display optionsTable
	mov edx, OFFSET blankLine
	call WriteString												;Display blankLine
	call WriteString												;Display blankLine
	ret

Menu ENDP
;---------------------------------------------------------------------------------------------------------------------
;Generates a random word
GenerateWord PROC
mov eax, maxWordlength
call RandomRange
add eax, 2
mov ecx, eax
	wordLoop:
		mov eax, 26			
		call RandomRange
		add al, 'a'			;Convert to ASCII
		mov [esi], al		;Store letter in buffer
		inc esi
		loop wordLoop

	mov BYTE PTR [esi], 0	;Null terminate the string
	ret
GenerateWord ENDP
;---------------------------------------------------------------------------------------------------------------------
;Generates a random paragraph
GenerateParagraph PROC
    ;   ESI - Pointer to the paragraph buffer (output buffer)
    ;   EAX - Number of words to generate (word count)
    ;   ECX, EDI, EDX - Temporarily used for paragraph generation

    push ebx                            ; Preserve EBX (general purpose)
    push esi                            ; Preserve ESI (paragraph buffer pointer)

    mov ebx, eax                        ; Store number of words in EBX
    mov edx, maxLineLength              ; Set maximum line length to EDX
    xor ecx, ecx                        ; Initialize ECX for line length tracking

paragraphLoop:
    ; Generate a random word and store it in wordBuffer
    mov edi, OFFSET wordBuffer          ; Use EDI for word buffer
    call GenerateWord                   ; Generate a random word

    ; Calculate the word length
    lea edi, wordBuffer                 ; Load wordBuffer address into EDI
    xor eax, eax                        ; Clear EAX for length calculation
countWordLength:
    cmp BYTE PTR [edi + eax], 0         ; Check for null terminator
    je endCount                         ; Exit when null terminator is found
    inc eax                             ; Increment length counter
    jmp countWordLength
endCount:
    ; EAX now contains the word length

    ; Check if the word fits in the current line
    add ecx, eax                        ; Add word length to current line length
    cmp ecx, edx                        ; Compare current line length with maxLineLength
    ja lineBreak                        ; If it exceeds, go to line break

    ; Add word to paragraph buffer
    lea edi, wordBuffer                 ; Reload wordBuffer
    xor eax, eax                        ; Reset EAX for copying characters
addWord:
    mov al, BYTE PTR [edi + eax]        ; Load a character from wordBuffer
    cmp al, 0                           ; Check for null terminator
    je addSpace                         ; If null terminator, add space
    mov BYTE PTR [esi], al              ; Copy character to paragraph buffer
    inc esi                             ; Increment paragraph buffer pointer
    inc eax                             ; Increment wordBuffer pointer
    jmp addWord

addSpace:
    mov BYTE PTR [esi], ' '             ; Add a space after the word
    inc esi                             ; Increment paragraph buffer pointer
    inc ecx                             ; Account for the added space
    dec ebx                             ; Decrement word count
    jnz paragraphLoop                   ; Continue if more words remain
    jmp finalize                        ; Finalize the paragraph

lineBreak:
    ; Add newline to paragraph buffer
    mov BYTE PTR [esi], 13              ; Manually Carriage return to buffer
    inc esi
    mov BYTE PTR [esi], 10              ; Manual Line feed to buffer
    inc esi
    mov ecx, eax                        ; Reset current line length to word length
    jmp addWord                         ; Add the current word after the newline

finalize:
    dec esi                             ; Remove the last added space
    mov BYTE PTR [esi], 0               ; Null terminate the paragraph buffer

    pop esi                             ; Restore ESI
    pop ebx                             ; Restore EBX
    ret
GenerateParagraph ENDP
;---------------------------------------------------------------------------------------------------------------------
BasicWritingTest Proc
mov esi, OFFSET paragraph			;Set ESI to paragraph buffer
mov eax, numWORDS
call GenerateParagraph				;Generate random paragraph
mov edx, OFFSET paragraph
call WriteString					;Display paragraph
mov dh, row
mov dl, col
call gotoxy
call calculateStringLength			;Calculate length of random paragraph	
mov paragraphlength, eax			;Store length of paragraph
call InputString					;Get user input
call ClrScr
call InputString					;Get user input
call ClrScr

mov edx, OFFSET greenArray
call WriteString
call Crlf
mov edx, OFFSET redArray
call WriteString
call Crlf
mov edx, OFFSET orderArray
call writeString
ret

BasicWritingTest ENDP
;---------------------------------------------------------------------------------------------------------------------
compareLetters PROC
	push eax
	push ebx
	mov al, BYTE PTR [paragraph + ecx]	;Load character from paragraph
	mov bl, BYTE PTR [userInput + ecx]	;Load character from userInput

	cmp al, bl
	je addtoGreen
	jne addToRed
	
	addToGreen:
		push eax								;Save eax
		mov eax, 2								;Set text color to green
		call SetTextColor
		pop eax									;Restore eax
		push ebx								;Save ebx
		mov ebx, greenIndex						;Set ebx to greenIndex
		mov BYTE PTR [greenArray + ebx], al		;Store character in greenArray
		call WriteChar							;Display character
		inc greenIndex							;Increment greenIndex
		mov BYTE PTR [orderArray + ecx], "A"	;Store order in orderArray
		pop ebx									;Restore ebx
		pop ebx									;Restore ebx
		pop eax									;Restore eax
		ret

	addToRed:
		push eax								;Save eax
		mov eax, 4								;Set text color to red
		call SetTextColor						;Set text color to red
		pop eax									;Restore eax
		push ebx								;Save ebx
		mov ebx, redIndex						;Set ebx to redIndex
		mov BYTE PTR [redArray + ebx], al		;Store character in redArray
		call WriteChar							;Display character
		inc redIndex							;Increment redIndex
		mov BYTE PTR [orderArray + ecx], "B"	;Store order in orderArray
		pop ebx									;Restore ebx
		pop ebx									;Restore ebx
		pop eax									;Restore eax
		ret 

compareLetters ENDP
;---------------------------------------------------------------------------------------------------------------------
calculateStringLength PROC
xor ecx, ecx
stringLengthLoop:
	mov al, BYTE PTR [esi + ecx]	;Load one character at a time
	cmp al, 0
	je endStringLength
	inc ecx
	jmp stringLengthLoop
endStringLength:
	mov eax, ecx
	ret
calculateStringLength ENDP

;---------------------------------------------------------------------------------------------------------------------
InputString PROC
xor ecx, ecx
mov ebx, paragraphlength

inputLoop:
	cmp ecx, ebx								;Check if user input is complete
	je endInput

	call ReadChar								;Read user input
	cmp al, 27
	je exitInput								;Exit if user presses ESC
	
	mov BYTE PTR [userInput + ecx], al			;Store user input in buffer

	call compareLetters
	inc ecx
	jmp inputLoop
	
	endInput:
		mov BYTE PTR [userInput + ecx], 0		;Null terminate the string
		mov BYTE PTR [orderArray + ecx], 0		;Null terminate the string
		call ClrScr
		mov edx, OFFSET resultMessage
		call WriteString
		ret

	exitInput:
		ret
ret
InputString ENDP

;---------------------------------------------------------------------------------------------------------------------
END main
