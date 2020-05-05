TITLE Project #3     (Program#3.asm)

;------------------------------------------------------------------------------------------------------------------------------------------------;
; Author:Brandon Schultz																													     ;
; First Modified: 4-5-20                             Last Modified: 5-3-20															             ;
; OSU email address:                                 schulbra@oregonstate.edu                                                                    ;
; Course number/section:                             CS 271 400 Spring 2020																	     ;
; Project number: Three                              Due Date: 5-3-20																			 ;
; This program implements an accumulator.																										 ;
;------------------------------------------------------------------------------------------------------------------------------------------------;

INCLUDE Irvine32.inc
INCLUDE macros.inc

;------------------------------------------------------------------------------------------------------------------------------------------------;
;	-Constants used for input validation [-88, -55] or [-40, -1] (inclusive).																	 ;
;------------------------------------------------------------------------------------------------------------------------------------------------;
NEGATIVE_88 = -88
NEGATIVE_55 = -55
NEGATIVE_40 = -40
NEGATIVE_01 = -1

;------------------------------------------------------------------------------------------------------------------------------------------------;
;	-Variable definitions																														 ;
;------------------------------------------------------------------------------------------------------------------------------------------------;
.data
displayboardTOP					BYTE	"|--------------------------------------------------------------------------------------| ", 0
programmerName					BYTE	"| Name:    Brandon Schultz                                                             | ", 0
programTitle					BYTE	"| Course - Program Title:  CS_271 - Number accumulator                                 | ", 0
ecPrompt						BYTE	"| **EC #1: Valid user input is numbered line by line.                                  | ", 0
ecPrompt2						BYTE	"| **EC #2: Avg of user input values is calculated and displayed as floating-point #    | ", 0
displayboardBOT					BYTE	"|--------------------------------------------------------------------------------------| ", 0
getUserName						BYTE	"Select a username: ", 0
userGreet						BYTE	"Hello, ", 0
UserInstructions1				BYTE	"[INSTRUCTIONS] -Enter negative values between [-88, -55] or [-40, -1] to proceed. ", 0
UserInstructions1End			BYTE	"               -Enter any positive value to end accumulation. ", 0
userInputVal					BYTE	"Input value ", 0
userInputValNumX				BYTE	": ", 0
InputValidationPrompt			BYTE	"This doesnt look like anything to me.", 0
InputValidationPassPrompt1		BYTE	"You selected ", 0
InputValidationPassPrompt2		BYTE	"valid numbers.", 0
maxUserInputPrompt				BYTE	"Max valid number    : ", 0
minUserInputPrompt				BYTE	"Min valid number    : ", 0 
sumUserInputPrompt				BYTE	"Sum of input numbers: ", 0
avgUserInputPrompt				BYTE	"Rounded avg int     : ", 0
floatUserInputPrompt			BYTE	"Rounded avg float   : ", 0
goodbyePrompt					BYTE    "Hey, what happens here, stays here. ", 0
userName						BYTE	30 DUP(?)
lineNum							DWORD	0
max								DWORD	0
min								DWORD	0
userInputSumTotal				DWORD	0
roundInt						DWORD	0
roundFactor						REAL8	-0.0005
roundFloat						REAL8	?
thousand						WORD	1000
floatInstruct					WORD	110000000000b

.code
main PROC

		; Displays Boarder for top/bottom of assignment info template.
		mov			edx, OFFSET	displayboardTOP
		call		WriteString
		call		Crlf

		; Displays program title.
		mov			edx, OFFSET programTitle
		call		WriteString
		call		Crlf

		; Displays programmer name.
		mov			edx, OFFSET programmerName
		call		WriteString
		call		Crlf

		; EC Prompt(s).
		mov			edx, OFFSET ecPrompt
		call		WriteString
		call		Crlf
		mov			edx, OFFSET ecPrompt2
		call		WriteString
		call		Crlf

		; Displays Boarder for top/bottom of assignment info template.
		mov			edx, OFFSET	displayboardBOT
		call		WriteString
		call		Crlf
		call		Crlf

		; Used to get then greet user by entered username.
		mov		edx, OFFSET	getUserName
		call	WriteSTring
		mov		edx, OFFSET	userName
		mov		ecx, SIZEOF	userName
		call	ReadString
		mov		edx, OFFSET userGreet
		call	WriteString
		mov		edx, OFFSET userName
		call	WriteString
		call	Crlf
		call	Crlf

		; Describes instructions for using program. - numbers in valid ranges used as input will continue the program,
		; prompting user for addtional input until a + value is input, closing the program.
		mov		edx, OFFSET	UserInstructions1
		call	WriteString
		call	Crlf
		call	Crlf
		mov		edx, OFFSET UserInstructions1End
		call	WriteString
		call	Crlf
		call	Crlf

;------------------------------------------------------------------------------------------------------------------------------------------------;
;	-Process used in validating that user input is in stated ranges [-88, -55] or [-40, -1] (inclusive). lineNum stores line value, for          ;
;   every valid input entered eax increases by one. The result of that added value corresponds to the proper line number.                        ;
;	-LessThan40 compares value to -55 to ensure input is within required range.                                                                  ;
;	-LessThan55 compares value to -88 to ensure input is within required range.                                                                  ;
;	-validInput is only called if input passes both of the above comparisons. If input is found to be the first "valid" num enetered, program    ;
;	assigns line number one to it before continuing to max/min/sum calculations after additional - values are entered and assigned line values.  ;
;	-newMax/Min/Sum are used to keep track of overall max, min  and total sum of valid values entered by user.                                   ; 
;------------------------------------------------------------------------------------------------------------------------------------------------;
userInputNum:

		mov		edx, OFFSET userInputVal
		call	WriteString
		mov		eax, lineNum
		add		eax, 1
		call	WriteDec
		mov		edx, OFFSET userInputValNumX
		call	WriteString
		call	ReadInt
		JO		invalidInput
		JNS		noneUserInput
		CMP		eax, NEGATIVE_40
		JAE		validInput
	
LessThan40:

		CMP		eax, NEGATIVE_55
		JA		invalidInput

LessThan55:

		CMP		eax, NEGATIVE_88
		JL		invalidInput

validInput:

		CMP		lineNum, 0
		JE		chosenOne
		INC		lineNum
		CMP		eax, max
		JA		newMax
		CMP		eax, min
		JL		newMin
		JMP		newSum

newMax:
	
		mov		max, eax
		JMP		newSum

newMin:

		mov		min, eax

newSum:

		add		eax, userInputSumTotal
		mov		userInputSumTotal, eax
		JMP		userInputNum

; First valid input value.
chosenOne:

		mov		max, eax
		mov		min, eax
		mov		userInputSumTotal, eax
		INC		lineNum
		JMP		userInputNum

; Prompts user to enter a value within proper range.
invalidInput:

		mov		edx, OFFSET InputValidationPrompt
		call	WriteString
		call	Crlf
		JMP		userInputNum

; If user entered no valid numbers.
noneUserInput:

		cmp		lineNum, 0
		JE		nothingValid


;------------------------------------------------------------------------------------------------------------------------------------------------;
;	-Methods for rounding the avg value of entered numbers to whole number if needed.		                                                     ;
;	-Used " ece.colorado.edu/~siek/ecen4553/csapp-ch3.pdf " and " http://flatassembler.net/docs.php?article=manual#2.1.13 "                      ;
;   while putting together rounding methods below.                                                                                               ;  
;------------------------------------------------------------------------------------------------------------------------------------------------;

roundedInt:

		mov		eax, userInputSumTotal						; Numerator of avg calculation
		cdq													; edx = eax, or userInputSumTotal
		idiv	lineNum										; lineNum holds number of items that contribute to sum, or avg equation's denominator
		imul	edx, NEGATIVE_01
		CMP		edx, lineNum								; if a remainder value exists it is compared to equations denominator, lineNum
		JLE		roundedIntToFloat							; remove remainder value if its less than denominator via the below roundedIntToFloat
		add		eax, -1										; otherwise -1 from result of userInputSumTotal/lineNum

roundedIntToFloat:

		fnstcw	floatInstruct								; instruction used to transfer floating point status to int value.   
		mov		bx, floatInstruct             
		and		bh, 11110011b								; keeps instruction after removing bits.
		or		bh, 00001100b								; remaining bits round towards zero
		mov		floatInstruct, bx			
		fldcw	floatInstruct								; loads instruction held by control word
		fild	userInputSumTotal
		fidiv	lineNum
		fadd	roundFactor
		fimul	thousand
		frndint
		fidiv	thousand									; num is returned as decimal after rounded to .001
		fstp	roundFloat									; returned num is saved and eventually displayed via the below. 


;------------------------------------------------------------------------------------------------------------------------------------------------;
;	-Methods used to display numbers accumulated and various calculations to user                    	                                         ;
;------------------------------------------------------------------------------------------------------------------------------------------------;
		call	Crlf
		mov		roundInt, eax				
		mov		edx, OFFSET InputValidationPassPrompt1
		call	WriteString
		mov		eax, lineNum
		call	WriteDec
				mWriteSpace 1
		mov		edx, OFFSET InputValidationPassPrompt2
		call	WriteString
		call	Crlf

		mov		edx, OFFSET maxUserInputPrompt
		call	WriteString
		mov		eax, max
		call	WriteInt
		call	Crlf

		mov		edx, OFFSET minUserInputPrompt
		call	WriteString
		mov		eax, min
		call	WriteInt
		call	Crlf

		mov		edx, OFFSET sumUserInputPrompt
		call	WriteString
		mov		eax, userInputSumTotal
		call	WriteInt
		call	Crlf

		mov		edx, OFFSET avgUserInputPrompt
		call	WriteString
		mov		eax, roundInt
		call	WriteInt
		call	Crlf

		mov		edx, OFFSET floatUserInputPrompt
		call	WriteString
		fld		roundFloat
		call	WriteFloat
		call	Crlf
		call	Crlf

		JMP		endProgramPrompt

;Goodbye prompts
nothingValid:
		call	Crlf
		mov		edx, OFFSET InputValidationPrompt
		call	WriteString
		call	Crlf

endProgramPrompt:
		mov		edx, OFFSET goodbyePrompt
		call	WriteString
		mov		edx, OFFSET userName
		call	WriteString
		call	Crlf

		exit

main ENDP

END main
