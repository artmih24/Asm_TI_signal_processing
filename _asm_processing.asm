   .global _asm_processing

_asm_processing:
	; signal[] -> A4;
	; processed_signal[] -> B4
	; len_processed_signal -> A6
	; N -> B6
		MV		.S2	A6, B0			; len -> B0
	||	INTSP	.L2	B6, B7			; (float) N -> B7
		NOP		3
		RCPSP	.S1	B7, A8			; 1 / N -> A8

_LOOP1:
		MV		.L1	B0, A0			; len -> A0
	||	MVKH	.S1 0, A7			; 0 -> A7
		MVKL	.S1	0, A7			; 0 -> A7
	||	MV		.S2	B6, B0			; N -> B0
_LOOP2:
		LDW		.D1	*A4++[1], A5
		NOP		4
		ADDSP	.L1	A5, A7, A7
		NOP		3
		SUB 	.L2	B0, 1, B0		; декремент счетчика цикла (регистра В0)
		[B0] 	B _LOOP2
		NOP		5
		LDW		.D1	*A4--[9], A5	; смещение на N - 1 отсчетов назад
		NOP		4
		MPYSP	.M1	A7, A8, A7		; A7 / N -> A7
		NOP		3
		MV		.S2	A0, B0
		STW		.D2	A7, *B4++[1]
	||	SUB 	.L2	B0, 1, B0		; декремент счетчика цикла (регистра В0)
		[B0] 	B _LOOP1
		NOP		5
		B		B3
		NOP		5
