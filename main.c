/*
 * main.c
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>

#pragma DATA_SECTION(signal, ".EXT_RAM")
#pragma DATA_SECTION(processed_signal, ".EXT_RAM")
#pragma DATA_SECTION(s1, ".EXT_RAM")
#pragma DATA_SECTION(s2, ".EXT_RAM")
#pragma DATA_SECTION(s1_1, ".EXT_RAM")
#pragma DATA_SECTION(s2_1, ".EXT_RAM")

extern void asm_processing(float* signal, float* processed_signal, int len, int N);
extern void asm_get_y(float* X, float* Y, int len, float* Yres, int a, int b);
extern void asm_get_z(float* X, float* Y, float* Z, int len);

float signal[100],
	processed_signal[91],	// 100 - (N - 1) = 100 - (10 - 1) = 100 - 9 = 91
	s1[91],
	s2[91],
	s1_1[91],
	s2_1[91];

int main(void) {
	FILE *f_signal, 
		*f_processed_signal, 
		*f_s1, 
		*f_s2, 
		*f_s1_1, 
		*f_s2_1;
	f_signal = fopen("signal.dat", "w");
	f_processed_signal = fopen("processed_signal.dat", "w");
	f_s1 = fopen("s1.dat", "w");
	f_s2 = fopen("s2.dat", "w");
	f_s1_1 = fopen("s1_1.dat", "w");
	f_s2_1 = fopen("s2_1.dat", "w");
	float A_signal = 20,					// ��������� �������
		Fc_signal = 1000,					// ������� �������
		pi = 3.14159265358979323846,		// ����� ��
		T1 = 1 / Fc_signal,					// ������ ������� = 1 ��
		SNR = 1.0 / 10,						// ��������� ������-���
		A_n = SNR * A_signal;				// ��������� ������
	int N = 10,								// ����� ��������, �� ������� ������� ����������
		N1 = 20;							// ����� �������� �� ������ �������
	float T = T1 / N1,						// ��� ������������� = 0.05 �� = 50 ���
		A_s1_s2 = 5,						// ��������� ����������� ��������
		tau_s1_s2 = 20,						// ���������� ������� ��������� �������� = 20 �
		e = 2.7182818284590452354;			// ����� �
	int i;
	srand(time(NULL));	// ������������� ���������� ����� ������ ������, ��������� � 01.01.1970 (������ ��� ���������� ����� �����)
	// ������������ ������� � �������:
	for (i = 0; i < (sizeof(signal) / sizeof(float)); i++){
		signal[i] = A_signal * (1 + sin(2 * pi * Fc_signal * i * T));			// ��������� �������� ������������� �������
		signal[i] += A_n * (((float)((rand() % 20001) - 10000)) / 10000);		// ���������� ������ � �������
		fprintf(f_signal, "%f\n", signal[i]);
	}
	asm_processing(signal, processed_signal, (sizeof(signal) / sizeof(float)), 10);
	for (i = 0; i < (sizeof(processed_signal) / sizeof(float)); i++) 
		fprintf(f_processed_signal, "%f\n", processed_signal[i]);
	float proc_signal_max = 0, proc_signal_min = 40;
	// ����� ��������� � �������� ������������� �������
	for (i = (N - 1); i < (sizeof(processed_signal) / sizeof(float)); i++){
		if (processed_signal[i] < proc_signal_min) 
			proc_signal_min = processed_signal[i];
		if (processed_signal[i] > proc_signal_max) 
			proc_signal_max = processed_signal[i];
	}
	// ������������ ���������� �������� s1 � s2
	float k = (A_s1_s2 / ((proc_signal_max - proc_signal_min) / 2));		// ����������� ���������� ��������� �������
	for (i = 0; i < (sizeof(processed_signal) / sizeof(float)); i++){
		s1[i] = ((processed_signal[i] - proc_signal_min) * k  - A_s1_s2) * pow(e, -(i * T / tau_s1_s2));
		s2[i] = s1[i] * i * T;
		fprintf(f_s1, "%f\n", s1[i]);
		fprintf(f_s2, "%f\n", s2[i]);
		s1_1[i] = s1[i];
		s2_1[i] = s2[i];
	}
	float s1_max = -10, s1_min = 10, s2_max = -10, s2_min = 10;
	// ����� ���������� � ��������� ������� s1 � s2
	for (i = (N - 1); i < (sizeof(s1) / sizeof(float)); i++){
		if (s1[i] < s1_min) s1_min = s1[i];
		if (s1[i] > s1_max) s1_max = s1[i];
		if (s2[i] < s2_min) s2_min = s2[i];
		if (s2[i] > s2_max) s2_max = s2[i];
	}
	float L_s1, L_s2;
	// ���������� ������, �� �������� ����� ������ ������ s1
	if (s1_max > -s1_min) 
		L_s1 = s1_max * (sqrt(2) / 2);
	else 
		L_s1 = -s1_min * (sqrt(2) / 2);
	// ���������� ������, �� �������� ����� ������ ������ s2
	if (s2_max > -s2_min) 
		L_s2 = s2_max * (sqrt(2) / 2);
	else 
		L_s2 = -s2_min * (sqrt(2) / 2);
	int s1_l = 100, 
		s1_r = -100, 
		s2_l = 100, 
		s2_r = -100;
	// ����� ������ � ����� ������ ����������, �� ������� ����� �������� �������� s1 � s2
	for (i = 0; i < (sizeof(s1) / sizeof(float)); i++){
		if ((s1[i] >= L_s1) || (s1[i] <= -L_s1)) 
			s1_r = i;
		if ((s2[i] >= L_s2) || (s2[i] <= -L_s2)) 
			s2_r = i;
	}
	for (i = ((sizeof(s1) / sizeof(float)) - 1); i >= 0; i--){
		if ((s1[i] >= L_s1) || (s1[i] <= -L_s1)) 
			s1_l = i;
		if ((s2[i] >= L_s2) || (s2[i] <= -L_s2)) 
			s2_l = i;
	}
	// �������� ������� s1, ���� ���������
	if (s1_l > 0) 
		for (i = 0; i < s1_l; i++) 
			s1_1[i] = 0;
	if (s1_r < (sizeof(s1) / sizeof(float)) - 1) 
		for (i = s1_r + 1; i < sizeof(s1) / sizeof(float); i++) 
			s1_1[i] = 0;
	// �������� ������� s2, ���� ���������
	if (s2_l > 0) 
		for (i = 0; i < s2_l; i++) 
			s2_1[i] = 0;
	if (s2_r < (sizeof(s2) / sizeof(float)) - 1) 
		for (i = s2_r + 1; i < sizeof(s2) / sizeof(float); i++) 
			s2_1[i] = 0;
	for (i = 0; i < (sizeof(s1) / sizeof(float)); i++){
		fprintf(f_s1_1, "%f\n", s1_1[i]);
		fprintf(f_s2_1, "%f\n", s2_1[i]);
	}
	fclose(f_signal);
	fclose(f_processed_signal);
	fclose(f_s1);
	fclose(f_s2);
	fclose(f_s1_1);
	fclose(f_s2_1);
	//-----------------------------------------
	float X[6] = {1, 2, 3, 4, 5, 6}, Y[6], Z[6], Yres[1], Y_nakop, Y_1[6], Z_1[6], Y_nakop_1 = 0;
	int	a = 1, b = 2;
	asm_get_y(X, Y, (sizeof(X)/sizeof(float)), Yres, a, b);
	Y_nakop = Yres[0];
	asm_get_z(X, Y, Z, (sizeof(X)/sizeof(float)));
	for (i = 0; i < (sizeof(X)/sizeof(float)); i++){
		Y_1[i] = sqrt(pow(X[i], 2) * pow(X[i] + 2, 2));
		Y_nakop_1 += pow(Y_1[i], 2) * (a * (i + 1) + 1) * pow(b, 3);
		Z_1[i] = abs(Y_1[i] - X[i]);
	}
	while(1);
}
