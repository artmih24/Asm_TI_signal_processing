
   .global _asm_get_y

_asm_get_y:
	; X[] -> A4
	; Y[] -> B4
	; len -> A6
	; res -> B6
	; a -> A8
	; b -> B8
		MVKL	.S1	0x40000000, A1	; 2 -> A1
		MVKH	.S1	0x40000000, A1	; 2 -> A1
		MVKL	.S1	0x3F800000, A0	; 1 -> A0
		MVKH	.S1 0x3F800000, A0	; 1 -> A0
		MV		.S2	A6, B0			; len -> B0
		MVKL	.S1	0, A2			; i -> A2
	||	MVKL	.S2	0, B7			; 0 -> B7
		MVKH	.S1	0, A2			; i -> A2
	||	MVKH	.S2	0, B7			; 0 -> B7
	||	INTSP	.L1 A8, A8			; (float) a -> A8
	||	INTSP	.L2	B8, B8			; (float) b -> B8
		NOP		3
_LOOP:
		LDW		.D1	*A4++[1], A5	; X[i] -> A5
		NOP		4
		MPYSP	.M1	A5, A5, A7		; X[i] ^ 2 -> A7
		NOP		3
		ADDSP	.L1	A2, A0, A2		; i++ -> A2
		NOP		3
		ADDSP	.L1	A5, A1, A5		; X[i] + 2 -> A5
	||	MPYSP	.M2	B8, B8, B9		; b ^ 2 -> B9
		NOP		3
		MPYSP	.M1	A2, A8, A10		; a * i -> A10
	||	MPYSP	.M2	B8, B9, B9		; b ^ 3 -> B9
		NOP		3
		ADDSP	.L1	A10, A0, A10	; a * i + 1 -> A10
	||	MPYSP	.M1	A5, A5, A5		; (X[i] + 2) ^ 2 -> A5
		NOP		3
		MPYSP	.M1	A5, A7, A5		; (X[i] ^ 2) * ((X[i] + 2) ^ 2) -> A5
		NOP		3
		RSQRSP	.S1	A5, A5			;
		RCPSP	.S1	A5, A5			; v((X[i] ^ 2) * ((X[i] + 2) ^ 2)) -> A5
		MPYSP	.M1	A10, B9, A10	; (a * i + 1) * (b ^ 3) -> A10
		NOP		3
		MPYSP	.M1	A5, A5, A9		; (v((X[i] ^ 2) * ((X[i] + 2) ^ 2))) ^ 2 -> A9
		NOP		3
		MPYSP	.M1	A10, A9, A10	; ((a * i + 1) * (b ^ 3)) * (v((X[i] ^ 2) * ((X[i] + 2) ^ 2))) ^ 2 -> A10
		NOP		3
		STW		.D2	A5, *B4++[1]	; Y[i] = ((a * i + 1) * (b ^ 3)) * v((X[i] ^ 2) * ((X[i] + 2) ^ 2))
		ADDSP	.L2	B7, A10, B7		; Yres += Y[i] -> B6
		NOP		3
		SUB 	.L2	B0, 1, B0		; декремент счетчика цикла (регистра В0)
		[B0] 	B _LOOP
		NOP		5
		STW		.D2	B7, *B6++[1]
		B 		B3
		NOP		5
