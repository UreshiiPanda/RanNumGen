

; Author:  Joseph Houghton
; Last Modified:  3/2/2023
; email address:  jojohoughton22@gmail.com
; Description:  a random number generator which also calculates and displays data on those random numbers


INCLUDE Irvine32.inc

LO				=  15
HI				=  50	
ARRAYSIZE	    =  200


.data

intro_1				BYTE		"Welcome to generating, sorting, and counting random integers!             Coded by Joseph Houghton", 13, 10, 0
intro_2				BYTE		"First we will generate 200 random integers between 15 and 50, inclusive.", 13, 10, 0
intro_3				BYTE		"We will then display that list of integers, sort them, and display the median value.", 13, 10, 0
intro_4				BYTE		"This program sorts the list in ascending order, it then displays the instances of each", 13, 10, 0
intro_5				BYTE		"number in that list, starting with the lowest value in the list.", 13, 10, 0
prompt_rand			BYTE		"Your unsorted random numbers:", 13, 10, 0
prompt_median		BYTE		"The median value of the array: ", 0
prompt_sorted		BYTE		"Your sorted random numbers:", 13, 10, 0
prompt_instances	BYTE		"Your list of instances of each generated number, starting with the smallest value:", 13, 10, 0
outro				BYTE		"Goodbye, and thanks for using my program  :)", 13, 10, 0
num_space			BYTE		" ", 0

randArray			DWORD		ARRAYSIZE		DUP(0)
counts				DWORD		HI - LO + 1		DUP(0)
counter				DWORD		0
index				DWORD		0


.code
main PROC

	Call	Randomize

; introduction
	
	PUSH	OFFSET	intro_1									; push input parameters to the stack by reference
	PUSH	OFFSET	intro_2
	PUSH	OFFSET	intro_3
	PUSH	OFFSET	intro_4
	PUSH	OFFSET	intro_5
	Call	introduction

; display random integers

	PUSH	OFFSET randArray								; push output parameter to the stack by reference
	Call	fillArray
	
	PUSH	OFFSET prompt_rand								; push input parameters to the stack
	PUSH	OFFSET randArray
	PUSH	ARRAYSIZE										; push array length by value
	PUSH	OFFSET num_space
	PUSH	counter
	Call	displayList

; sort the array of random integers

	PUSH	index
	PUSH	counter
	PUSH	OFFSET randArray
	Call	sortList

; display the median

	PUSH	OFFSET prompt_median
	PUSH	OFFSET randArray
	Call	displayMedian

; display the sorted array

	PUSH	OFFSET prompt_sorted							; push input parameters to the stack
	PUSH	OFFSET randArray
	PUSH	ARRAYSIZE										; push array length by value
	PUSH	OFFSET num_space
	PUSH	counter
	Call	displayList

; display the counts array

	PUSH	counter
	PUSH	index
	PUSH	OFFSET counts
	PUSH	OFFSET randArray
	Call	countList

	PUSH	OFFSET prompt_instances							; push input parameters to the stack
	PUSH	OFFSET counts
	PUSH	HI - LO + 1										; push array length by value
	PUSH	OFFSET num_space
	PUSH	counter
	Call	displayList

; outro
	
	PUSH	OFFSET outro
	Call	goodbye


	Invoke ExitProcess,0									; exit to operating system
main ENDP



; ---------------------------------------------------------------------------------
; Name:  introduction
;
; Description:  writes an introduction to the console
;
; Preconditions:  None
;
; Postconditions:  None
;
; Receives:  5 input parameters:  intro_1, intro_2, intro_3, intro_4, intro_5
;
; Returns:  prints to console
; ---------------------------------------------------------------------------------
introduction PROC	USES EDX					; preserve EDX via PUSH, and POP it back off before RET

	PUSH	EBP									; preserve EBP
	MOV		EBP, ESP							; assign EBP as a static stack-frame pointer, by moving it to where ESP is

	MOV		EDX, [EBP + 28]						;  use EBP pointer to access parameters via Base+Offest method							
	Call	WriteString
	Call	CrLf

	MOV		EDX, [EBP + 24]  
	Call	WriteString

	MOV		EDX, [EBP + 20]  
	Call	WriteString

	MOV		EDX, [EBP + 16] 
	Call	WriteString

	MOV		EDX, [EBP + 12] 
	Call	WriteString

	Call	CrLf

	POP		EBP
	RET		20									; de-reference the parameters

introduction ENDP



; ---------------------------------------------------------------------------------
; Name:  fillArray
;
; Description:  populates randArray with 200 random values
;
; Preconditions:  None
;
; Postconditions:  None
;
; Receives:  1 output parameter,    3 globals:   an array,      ARRAYSIZE, HI, LO
;
; Returns:  a populated randArray
; ---------------------------------------------------------------------------------
fillArray PROC	USES EAX EDI ECX				; preserve registers and pop them back off before RET
	
	PUSH	EBP									; preserve EBP
	MOV		EBP, ESP							; assign EBP as a static stack-frame pointer, by moving it to where ESP is
	
	MOV		ECX, ARRAYSIZE						; prepare EDI & ECX for the loop
	MOV		EDI, [EBP + 20]						; pop the first randArray index into EDI 

_fill_start:							
	MOV		EAX, HI + 1							; generate a random number between 0 and HI inclusive
	Call	RandomRange
	CMP		EAX, LO 
	JB		_fill_start							; only store the integer if it is >= LO

	MOV		[EDI], EAX							; use EDI to write to randArray via Register Indirect method
	ADD		EDI, 4								; move EDI to the next index in the array

	LOOP	_fill_start

	POP		EBP
	RET		4									; de-reference the parameter

fillArray ENDP



; ---------------------------------------------------------------------------------
; Name:  displayList
;
; Description:  prints the given array out to the console
;
; Preconditions:  None
;
; Postconditions:  None
;
; Receives:  5 input parameters:   a prompt string, an array, length of array, space string, a counter value
;
; Returns:  prints to console
; ---------------------------------------------------------------------------------
displayList PROC	USES EDX ESI ECX EBX EAX	; preserve registers and pop them back off before RET

	PUSH	EBP									; preserve EBP
	MOV		EBP, ESP							; assign EBP as a static stack-frame pointer, by moving it to where ESP is

	MOV		EDX, [EBP + 44]						; grab the prompt from the stack and print it
	Call	WriteString
	
	MOV		ECX, [EBP + 36]						; prepare ESI (with array) & ECX (with array len) for the loop
	MOV		ESI, [EBP + 40]						; pop the first array index into EDI 

_display_start:
	MOV		EAX, [EBP + 28]                     ; check if 20 integers have been printed
	MOV		EBX, 20
	XOR		EDX, EDX
	DIV		EBX
	CMP		EDX, 0
	JNE		_finish_loop						; prime found, increment loop

	Call	CrLf								; 20 integers have been printed, print new line
	
_finish_loop:
	MOV		EAX, [EBP + 28]						; increment the integer counter
	INC		EAX									 
	MOV		[EBP + 28], EAX

	MOV		EAX, [ESI]							; print out the value at this current index
	Call	WriteDec
	MOV		EDX, [EBP + 32]
	Call	WriteString

	ADD		ESI, 4								; move to next index in the array
	LOOP	_display_start

	Call	CrLf
	Call	CrLf
	POP		EBP
	RET		20									; de-reference the parameters

displayList ENDP


; ---------------------------------------------------------------------------------
; Name:  sortList
;
; Description:  sorts the given array in ascending order via selection sort
;
; Preconditions:  a random array has been generated 
;
; Postconditions:  None
;
; Receives:  2 input parameters, 1 input/output parameter, 1 global:  an index, an ESI counter,  an array,  ARRAYSIZE
;
; Returns:  a sorted array 
; ---------------------------------------------------------------------------------
sortList PROC	USES EDI ESI EBX EAX			; preserve registers and pop them back off before RET

	PUSH	EBP									; preserve EBP
	MOV		EBP, ESP							; assign EBP as a static stack-frame pointer, by moving it to where ESP is

	MOV		EDI, [EBP + 24]						; EDI will be slow-moving pointer
	MOV		ESI, [EBP + 24]						; ESI will be fast-moving pointer
	MOV		EBX, [EBP + 24]						; EBX will be start-pointer

_start_compare:
	MOV		EAX, [EBP + 32]
	CMP		EAX, ARRAYSIZE - 1					; compare the curr start-pointer index with the last index
	JAE		_end_sort							; when start pointer reaches end of array, the sort is finished

	MOV		EAX, [EBP + 28]
	INC		EAX									; increment the ESI counter ("counter") to check ESI against array length
	MOV		[EBP + 28], EAX
	CMP		EAX, ARRAYSIZE
	JAE		_break_inner_loop					; ESI has reached end of array, break "inner" loop

	ADD		ESI, 4								; move ESI to next index
	MOV		EAX, [ESI]
	CMP		EAX, [EDI]
	JB		_new_smallest_element				; there's a new smallest value, move EDI to that value
	JMP		_start_compare						; otherwise, just continue moving ESI down the array 

_new_smallest_element:
	MOV		EDI, ESI							; move EDI to where ESI is, further down the array
	JMP		_start_compare						; then just continue moving ESI and comparing

_break_inner_loop:
	PUSH	EDI									; first exchange EDI (curr smallest value) with EBX (curr start value)
	PUSH	EBX 
	Call	exchangeElements

	MOV		EAX, [EBP + 32]						; increment the start-pointer index ("index")
	INC		EAX
	MOV		[EBP + 32], EAX 

	ADD		EBX, 4								; then start the registers back over from the next element
	MOV		EDI, EBX							; EDI starts at curr start index
	MOV		ESI, EDI							; ESI will start at 1 index beyond EDI 

	MOV		EAX, [EBP + 32]
	MOV		[EBP + 28], EAX						; reset the ESI counter, place it at the curr start-index
	JMP		_start_compare

_end_sort:
				
	POP		EBP
	RET		12

sortList ENDP


; ---------------------------------------------------------------------------------
; Name:  exchangeElements
;
; Description:  swaps the 2 given input values
;
; Preconditions:  2 references to-be-swapped have been pushed to the stack
;
; Postconditions:  the references point to different values now, unless they were already at same position
;
; Receives:  2 input/output parameters:   2 array indices [i] [j] by reference
;
; Returns:  2 swapped indices [i] <--> [j]
; ---------------------------------------------------------------------------------
exchangeElements  PROC	USES EAX EBX ECX EDX			; preserve registers and pop them back off before RET

	PUSH	EBP											; preserve EBP
	MOV		EBP, ESP									; assign EBP as a static stack-frame pointer

	MOV		EAX, [EBP + 24]								; EAX now contains the curr start-pointer
	MOV		EBX, [EBP + 28]

	MOV		ECX, [EAX]
	MOV		EDX, [EBX]
	MOV		[EAX], EDX
	MOV		[EBX], ECX

	MOV		[EBP + 24], EAX								; curr start-pointer value has been swapped to smallest value
	MOV		[EBP + 28], EBX								; slow-pointer value has been swapped to curr start value

	POP		EBP
	RET		8

exchangeElements  ENDP


; ---------------------------------------------------------------------------------
; Name:  displayMedian
;
; Description:  displays the median of the given sorted array
;
; Preconditions:  the input array has been sorted
;
; Postconditions:  None
;
; Receives:  2 input parameters, 1 global:   a prompt, an array  by reference,  ARRAYSIZE
;
; Returns:  prints median to the console
; ---------------------------------------------------------------------------------
displayMedian  PROC	USES EAX EBX ECX EDX ESI			; preserve registers and pop them back off before RET

	PUSH	EBP											; preserve EBP
	MOV		EBP, ESP									; assign EBP as a static stack-frame pointer

	MOV		EDX, [EBP + 32]								; display median prompt
	Call	WriteString

	MOV		EAX, ARRAYSIZE								; first check if array is of even or odd length
	XOR		EDX, EDX
	MOV		EBX, 2
	DIV		EBX
	CMP		EDX, 0
	JE		_even_len_array


	MOV		ECX, EAX									; move ARRAYSIZE/2 into ECX
	MOV		ESI, [EBP + 28]								; set up ECX and ESI for the loop

_odd_arr_loop:
	ADD		ESI, 4										; if not at middle, keep moving ESI down the array
	LOOP	_even_arr_loop

	MOV		EAX, [ESI]									; ESI is at middle of array, display that median
	JMP		_end

_even_len_array:
	MOV		ECX, EAX									; move ARRAYSIZE/2 into ECX
	MOV		ESI, [EBP + 28]								; set up ECX and ESI for the loop

_even_arr_loop:
	CMP		ECX, 1
	JE		_finish_even_arr
	ADD		ESI, 4										; if not at middle, keep moving ESI down the array
	LOOP	_even_arr_loop

_finish_even_arr:
	MOV		EBX, [ESI]									; add the 2 middle values together
	ADD		ESI, 4
	MOV		EAX, [ESI]
	ADD		EAX, EBX

	XOR		EDX, EDX									; take the avg of those 2 middle values
	MOV		EBX, 2
	DIV		EBX

	CMP		EDX, 0										; the avg is already a whole int, display that
	JE		_end

	INC		EAX											; the avg is not a whole int, round it up, then display it
	JMP		_end


_end:
	Call	WriteDec									; EAX holds the median
	Call	CrLf
	Call	CrLf

	POP		EBP
	RET		8

displayMedian  ENDP


; ---------------------------------------------------------------------------------
; Name:  countList
;
; Description:  displays the number of occurrences of each value within [LO, HI] as an array
;
; Preconditions:  a sorted array and an empty array have been pushed to the stack
;
; Postconditions:  None
;
; Receives:  1 input parameter, 1 output parameter, 3 globals:   a sorted array,  an empty array, LO, HI, ARRAYSIZE
;
; Returns:  an array of counts of occurrences 
; ---------------------------------------------------------------------------------
countList  PROC	USES EAX ESI ECX EDI					; preserve registers and pop them back off before RET

	PUSH	EBP											; preserve EBP
	MOV		EBP, ESP									; assign EBP as a static stack-frame pointer

	MOV		EAX, LO
	MOV		[EBP + 32], EAX								; the "index" variable will hold the LO-HI value, it'll represent the output arr index

	MOV		ESI, [EBP + 24]								; ESI will read from sorted input array
	MOV		EDI, [EBP + 28]								; EDI will write to the empty output array		
	MOV		ECX, ARRAYSIZE
	
_start_array_counts:
	MOV		EAX, [EBP + 32]
	CMP		EAX, [ESI]									; compare current ESI input arr index with the current output arr index
	JNE		_curr_count_finished

	MOV		EAX, [EBP + 36]								; ESI input arr value is still the same, so increment the count of that integer
	INC		EAX
	MOV		[EBP + 36], EAX

	ADD		ESI, 4										; move to next input arr index and repeat process
	LOOP	_start_array_counts

	JMP		_end										; ESI has reached end of input arr, counting is finished 

_curr_count_finished:
	MOV		EAX, [EBP + 36]								; the count for this integer has ended, so add that count to output arr
	MOV		[EDI], EAX
	ADD		EDI, 4										; move to next output arr index

	MOV		EAX, 0										; reset the counter to 0
	MOV		[EBP + 36], EAX

	MOV		EAX, [EBP + 32]								; increment the LO-HI output index variable
	INC		EAX
	MOV		[EBP + 32], EAX
	JMP		_start_array_counts

_end:
	MOV		EAX, [EBP + 36]								; add the last count to the output array
	MOV		[EDI], EAX

	POP		EBP
	RET		16

countList  ENDP


; ---------------------------------------------------------------------------------
; Name:  goodbye
;
; Description:  writes a goodbye message to the console
;
; Preconditions:  None
;
; Postconditions:  None
;
; Receives:  1 input parameter:  outro
;
; Returns:  prints to console
; ---------------------------------------------------------------------------------
goodbye PROC	USES EDX						; preserve EDX via PUSH, and POP it back off before RET

	PUSH	EBP									; preserve EBP
	MOV		EBP, ESP							; assign EBP as a static stack-frame pointer

	MOV		EDX, [EBP + 12]						;  use EBP pointer to access parameters via Base+Offest method							
	Call	WriteString
	Call	CrLf

	POP		EBP
	RET		4									; de-reference the parameter

goodbye ENDP


END main
