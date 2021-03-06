
   .global _asm_get_y1

C1 .set 0x3F800000		; C1 = 1
C2 .set 0x40400000		; C2 = 3
C3 .set 0x40C00000  	; C3 = 6

_asm_get_y1:
	; X[] -> A4
	; Y[] -> B4
	; len -> A6
	; res -> B6
	; a -> A8
	; b -> B8
		MVKL	.S1	C1, A1			; C1 = 1 -> A1
	||	MVKL	.S2 C2, B1			; C2 = 3 -> B1
		MVKH	.S1	C1, A1			; C1 = 1 -> A1
	||	MVKH	.S2 C2, B1			; C2 = 3 -> B1
		MVKL	.S2	C3, B2			; C3 = 6 -> B2
		MVKH	.S2	C3, B2			; C3 = 6 -> B2
		MV		.S2	A6, B0			; len -> B0
		MVKL	.S1	0, A2			; i -> A2
	||	MVKL	.S2	0, B6			; 0 -> B6
		MVKH	.S1	0, A2			; i -> A2
	||	MVKH	.S2	0, B6			; 0 -> B6
_LOOP:
		LDW		.D1	*A4++[1], A5	; X[i] -> A5
		NOP		4
		RCPSP	.S2	A5, B5			; X[i] ^ (-1) -> B5

		RSQRSP	.S1	A5, A7			;
	||	RSQRSP	.S2	B5, B7			;
		RCPSP	.S1	A7, A7			; v(X[i]) -> A7
	||	RCPSP	.S2	B7, B7			; v(X[i] ^ (-1)) -> B7

		MPYSP	.M1	A5, A5, A9		;
		NOP		3					; X[i] ^ 2 -> A9
		RCPSP	.S2	A9, B9			; X[i] ^ (-2) -> B9

		SUBSP	.L1	A7, B7, A10		; v(X[i]) - v(X[i] ^ (-1)) -> A10
	||	SUBSP	.L2	A5, B9, B9		; X[i] - (X[i] ^ (-2)) -> B9
		NOP		3					;
		RCPSP	.S1	A10, A10		;             1
		MPYSP	.M2	B9, A10, B10	; ------------------------ -> A10
		NOP		3					; v(X[i]) - v(X[i] ^ (-1))
									;
									;   X[i] - (X[i] ^ (-2))
									; ------------------------ -> B10
									; v(X[i]) - v(X[i] ^ (-1))

		MPYSP	.M1	A5, A7, A11		; X[i] * v(X[i]) -> A11
	||	SUBSP	.L2	A1, B9, B11		; 1 - (X[i] ^ (-2)) -> B11
		NOP		3					;
		RCPSP	.S1	A11, A11		;
		MPYSP	.M1	B1, A11, A11	;        3
	||	MPYSP	.M2	B11, A10, B11	; -------------- -> A11
		NOP		3					; X[i] * v(X[i])
									;
									;     1 - (X[i] ^ (-2))
									; ------------------------ -> B11
									; v(X[i]) - v(X[i] ^ (-1))

									;            (X[i] - (X[i] ^ (-2))
									; v(X[i]) - ------------------------ -> A7
		SUBSP	.L1	A7, B10, A7		;           v(X[i]) - v(X[i] ^ (-1))
	||	ADDSP	.L2	A5, B2, B12		; X[i] + 6 -> B12
		NOP		3
									;             X[i] - (X[i] ^ (-2))         1 - (X[i] ^ (-2))
									; v(X[i]) - ------------------------ + ------------------------  -> A7
		ADDSP	.L1 A7, B11, A7		;           v(X[i]) - v(X[i] ^ (-1))   v(X[i]) - v(X[i] ^ (-1))
	||	SUBSP	.L2	B12, A9, B12	; X[i] + 6 - X[i] ^ 2 -> B12
	||	MPYSP	.M2	B8, B8, B14		; b ^ 2 -> B14
		NOP		3
									;             X[i] - (X[i] ^ (-2))         1 - (X[i] ^ (-2))             3
									; v(X[i]) - ------------------------ + ------------------------ + -------------- -> A7
		ADDSP	.L1	A7, A11, A7		;           v(X[i]) - v(X[i] ^ (-1))   v(X[i]) - v(X[i] ^ (-1))   X[i] * v(X[i])
	||	MPYSP	.M2 B8, B14, B14	; b ^ 3 -> B14
		NOP		3
		ADDSP	.L1	A2, A1, A2		; ??????????? i ?? 1, ????????? ????? a ?????? ?????????? ?? ????? ?? 1 (?? ???????)
	||	MPYSP	.M1	A7, A7, A7		;              X[i] - (X[i] ^ (-2))         1 - (X[i] ^ (-2))             3
		NOP		3					; (v(X[i]) - ------------------------ + ------------------------ + --------------) ^ 2 -> A7
									;            v(X[i]) - v(X[i] ^ (-1))   v(X[i]) - v(X[i] ^ (-1))   X[i] * v(X[i])
		MPYSP	.M1	A2, A8, A2		; a * i -> A2
	||	RCPSP	.S1	A7, A7			;              X[i] - (X[i] ^ (-2))         1 - (X[i] ^ (-2))             3
		NOP		3					; (v(X[i]) - ------------------------ + ------------------------ + --------------) ^ (-2) -> A7
									;            v(X[i]) - v(X[i] ^ (-1))   v(X[i]) - v(X[i] ^ (-1))   X[i] * v(X[i])

									;              X[i] - (X[i] ^ (-2))         1 - (X[i] ^ (-2))             3
									; ((v(X[i]) - ------------------------ + ------------------------ + --------------) ^ (-2)) * (X[i] + 6 - X[i] ^ 2) -> A7
		MPYSP	.M1	A7, B12, A7		;             v(X[i]) - v(X[i] ^ (-1))   v(X[i]) - v(X[i] ^ (-1))   X[i] * v(X[i])
	||	ADDSP	.L1	A2, A1, A2		; (a * 1) + 1 -> A2
		NOP		3
									;                      X[i] - (X[i] ^ (-2))         1 - (X[i] ^ (-2))             3
									; Y[i] = ((v(X[i]) - ------------------------ + ------------------------ + --------------) ^ (-2)) * (X[i] + 6 - X[i] ^ 2)
		STW		.D2	A7, *B4++[1]	;                    v(X[i]) - v(X[i] ^ (-1))   v(X[i]) - v(X[i] ^ (-1))   X[i] * v(X[i])
	||	MPYSP	.M1	A7, A7, A12		; Y[i] ^ 2 -> A12
	||	MPYSP	.M2	A2, B14, B13	; ((a * 1) + 1) * b ^ 3 -> B13
		NOP		3
		MPYSP	.M1	A12, B13, A12	; (Y[i] ^ 2) * (((a * 1) + 1) * b ^ 3) -> A12
		NOP		3
		ADDSP	.L2	B6, A12, B6		; yres += (Y[i] ^ 2) * (((a * 1) + 1) * b ^ 3)
		NOP		3
		SUB 	.L2	B0, 1, B0		; ????????? ???????? ????? (???????? ?0)
		[B0] 	B _LOOP
		NOP		5
		B 		B3
		NOP		5
