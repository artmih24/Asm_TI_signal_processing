
   .global _asmfunc5

   .global _x

_asmfunc5:

	; ������
	; ����������� �� ���������� ���������� ��������:
	; 1.1 * �1 + 2.2 * �2 + 3.3 * �3 + 4.4 * �4
	; ��� ���� xl = 1, �2 = 2, �� = 3, �4 = 4; "�" - ������.
	; �������, ��� �������� ��������� � ��������� ���������� Al, �2, Bl, �2 �����.
	; ��������� ��������� � ������� ��. ��� �������������� �������� ������ ���� ���������
	;  ��������������� ������� ����������.

	MV		B3, A10 ; �������� ����� �������� � ��-��������� � ��������� �������, �.�. B3 ����� ��������������

	; ������������� Float-Point �������� � ���� ���-������������
	MVKL	0x3F8CCCCD, A1	; �������� � ������� �������� 32-���������� ����� (������� �����, 16-����.)
	MVKH	0x3F8CCCCD, A1	; -//- (������� �����, 16-����.); 1.1 -> A1

	MVKL	0x400CCCCD, A2	; = 2.2 -> A2
	MVKH	0x400CCCCD, A2	;

	MVKL	0x40533333, B1	; = 3.3 -> B1
	MVKH	0x40533333, B1	;

	MVKL	0x408CCCCD, B2	; = 4.4 -> B2
	MVKH	0x408CCCCD, B2	;

	MVKL	_x, A7 ; �������� ����� ������� "x" (�� ����, ����� ��� ������� ��������) � ������� �7
	MVKH	_x, A7 ; - �������� �������

	LDW		*A7, A3 ; ��� *+A7[0], A3 - �������� �������� � ������� �3 �� ������ ������ �� ������ �� �7
	NOP 	4

	MPYSP 	A1, A3, A4 	; 1.1*x1 -> A4
	NOP		3 			;  � �3 ��������� �������� ������� �������� ������� "�"; x1 -> A3

	LDW 	*+A7[1], A3 ; ����� �������� ������ �� 1 ������� (1 ������� FLoatPoint = 4 �����,
	NOP 	4 		   	;  �.�. ����� �� 4 ����� ������), ��� ���� ���� �������� � A7 �� ��������; x2 -> A3

	MPYSP 	A3, A2, A5 ; 2.2*x2 -> A5
	NOP		3

	ADDSP 	A4, A5, A6 ; (1.1*x1) + (2.2*x2) -> A6
	NOP		3

	LDW 	*+A7[2], B3 ; ����� �������� ������ �� 2 �������� (�.�. ����� �� 2*4 ���� ������)
	NOP		4			;  ���� �������� � A7 �� ��������; x3 -> B3

	MPYSP 	B1, B3, B4 	; 3.3*x3 -> B4
	NOP		3

	LDW 	*+A7[3], B3	; ����� �������� ������ �� 3 �������� (�.�. ����� �� 3*4 ���� ������)
	NOP	4				;  ���� �������� � A7 �� ��������; x4 -> B3

	MPYSP 	B3, B2, B5 	; 4.4*x4 -> B5
	NOP		3

	ADDSP 	B4, B4, B6 	; (3.3*x3) + (4.4*x4) -> B6
	NOP		3

	ADDSP 	A6, B6, A0 	; ( (1.1*x1) + (2.2*x2) ) + ( (3.3*x3) + (4.4*x4) ) -> A0
	NOP		3

	STW 	A0, *+A7[4]	; ����� �������� ������ �� 4 �������� (�.�. ����� �� 4*4 ���� ������)
	NOP					;  ������ ���������� � ��������� ������� �������, �.�. A0 -> x5

	MV		A0, A4 		; ��������� ��������� ��� ������ ����� �������� ���-�������

	B       A10 ; ����� �� Asm-������������ � ����������� � �������� ��-���������
	NOP     5
