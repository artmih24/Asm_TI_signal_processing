
   .global _asm_get_z

_asm_get_z:
	; X[] -> A4
	; Y[] -> B4
	; Z[] -> A6
	; len -> B6
		MV		.S2	B6, B0			; len -> B0
_ABS:
		LDW		.D1	*A4++[1], A5	; X[i] -> A5
	||	LDW		.D2	*B4++[1], B5	; Y[i] -> B5
		NOP		4
		SUBSP	.L1	B5, A5, A7
		NOP		3
		ABSSP	.S1	A7, A7
		STW		.D1	A7, *A6++[1]
		SUB 	.L2	B0, 1, B0		; декремент счетчика цикла (регистра В0)
		[B0] 	B _ABS
		NOP		5
		B 		B3
		NOP		5
