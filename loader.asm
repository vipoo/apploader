STKSIZ	EQU	$40		; WORKING STACK SIZE
RESTART	EQU	$0000		; CP/M RESTART VECTOR

	ORG	$100

	LD	SP, STACK		; SET NEW STACK
	LD	HL, (6)		;DE = HIMEM
	DEC	HL
	LD	L, 0		; 256 BOUNDARY
	DEC	HL

	PUSH	HL
	POP	IX
	LD	DE, HL

	LD	HL, APP + APPSIZE - 1
	LD	BC, APPSIZE
	LDDR

	INC	DE

	PUSH	DE			; CAPTURE START POINT IN IX
	POP	IX

	EX	DE, HL
	LD	DE, $100
	OR	A
	SBC	HL, DE
	PUSH	HL
	POP	IY			; OFFSET VALUE (IX - 100)

	PUSH	IX
	POP	DE			; START OF CODE
	LD	HL, RELOC
	LD	BC, RELOCSIZE / 2

LOOP:
	CALL	TRANSPOSE

	INC	HL
	INC	HL
	DEC	BC
	LD	A, B
	OR	C
	JR	NZ, LOOP

	PUSH	IX
	POP	HL

	JP	(IX)

TRANSPOSE:
	PUSH	HL
	PUSH	BC
	PUSH	DE

	LD	E, (HL)
	INC	HL
	LD	D, (HL)

	EX	DE, HL
	PUSH	IX
	POP	DE
	ADD	HL, DE

	LD	C, (HL)
	INC	HL
	LD	B, (HL)

	PUSH	IY
	POP	DE

	PUSH	HL
	LD	HL, DE
	ADD	HL, BC
	LD	D, H
	LD	E, L
	POP	HL

	LD	(HL), D
	DEC	HL
	LD	(HL), E
	POP	DE
	POP	BC
	POP	HL
	RET

	ALIGN 256
RELOC:
BINARY	"/tmp/100.reloc"
RELOCSIZE:	EQU	ASMPC - RELOC

	ALIGN 256


STKSAV:		DEFW	0		; STACK POINTER SAVED AT START
		DEFS	STKSIZ	; STACK
STACK:		EQU	ASMPC		; STACK TOP

	DEFS	8

	ALIGN 256

APP:
BINARY "/tmp/100.bin"
	DEFS 	256 - ((ASMPC - APP) % 256)
APPSIZE:	EQU	ASMPC - APP
