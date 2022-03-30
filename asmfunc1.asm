
   .global _asmfunc1

_asmfunc1:

   	; ������
	; ����������� �� ���������� ���������� ��������:
	; 1 x 2 + 3 x 4 + 5 - 7
	; �������, ��� �������� ��������� � ��������� ���������� Al, �2, Bl, �2, ��, �� �����.
	; ��������� ��������� � ������� ��. ��� �������������� �������� ������ ���� ���������
	;  ��������������� ������� ����������.

	; ������������� ������������� �������� � ���� ���-������������
   	MVK	1, A1 ; 1 -> A1, �������� � ������� ������ 16-���������� �����
   	MVK	2, A2 ; 2 -> A2
   	MVK 3, B1 ; 3 -> B1
   	MVK 4, B2 ; 4 -> B2
   	MVK 5, A3 ; 5 -> A3
   	MVK 7, B4 ; 7 -> B4.  B3 - ������� ������! ��� �������� ����� �������� � ��-���������.

   	MVKL	1, A1	; �������� � ������� ������ 32-���������� ����� (������� �����, 16-����.)
	MVKH	1, A1	; -//- (������� �����, 16-����.)

	MPY 	A1, A2, A1 ; 1 x 2 -> A1
	NOP		1

	MPY		B1, B2, B1 ; 3 x 4 -> B1
	NOP		1

	ADD		A1, B1, A2 ; (1 x 2) + (3 x 4) -> A2
	; ������� 1 ����, ���. �������� �� ���������

	SUB		A3, B4, A3 ; (5 - 7) -> A3

	ADD		A2, A3, A0 ; (1 x 2) + (3 x 4) + (5 - 7) -> A0

	MV		A0, A4 ; ��������� ������� � ������� �4

	B       B3 ; ����� �� Asm-������������ � ����������� � �������� ��-���������
   	NOP     5

