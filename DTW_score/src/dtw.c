#include "dtw.h"

unsigned char diff_abs(unsigned char x,unsigned char y)
{
	if(x>=y) return (x-y);
	else	return (y-x);
}

unsigned char min_data(unsigned char x,unsigned char y,unsigned char z)
{
	if(x<=y && x<=z)
		return x;
	else if(y<=x && y<=z)
		return y;
	else
		return z;
}

void min_five_data(unsigned char result[2],unsigned char x1,unsigned char x2,unsigned char x3,unsigned char x4,unsigned char x5)
{
	if(x1<=x2 && x1<=x3 && x1<=x4 && x1<=x5)
	{
		result[1] = x1;
		result[0] = 1;
	}
	else if(x2<=x1 && x2<=x3 && x2<=x4 && x2<=x5)
	{
		result[1] = x2;
		result[0] = 2;
	}
	else if(x3<=x2 && x3<=x1 && x3<=x4 && x3<=x5)
	{
		result[1] = x3;
		result[0] = 3;
	}
	else if(x4<=x2 && x4<=x3 && x4<=x1 && x4<=x5)
	{
		result[1] = x4;
		result[0] = 4;
	}
	else
	{
		result[1] = x5;
		result[0] = 5;
	}
}

unsigned char dtw(unsigned char F[50],unsigned char R[50])
{
	//¼ÆËã¾àÀë¾ØÕó
	unsigned char dis_mem[50][50];
	unsigned char dis_i,dis_j;
	dtw_label1:for(dis_i=0;dis_i<50;dis_i++)
		for(dis_j=0;dis_j<50;dis_j++)
			dis_mem[dis_i][dis_j]=diff_abs(F[dis_i],R[dis_j]);

	//µü´ú¼ÆËã×î¶ÌÂ·¾¶
	unsigned char path_mem[50][50];
	unsigned short temp;
	unsigned char path_i,path_j;
	for(path_i=0;path_i<50;path_i++)
		for(path_j=0;path_j<50;path_j++)
		{
			if(path_i==0 && path_j==0)
				path_mem[path_i][path_j]=dis_mem[0][0];
			else if(path_i==0)
			{
				temp=path_mem[path_i][path_j-1]+dis_mem[path_i][path_j];
				if(temp > 255)
					path_mem[path_i][path_j] = 255;
				else
					path_mem[path_i][path_j] = temp;
			}
			else if(path_j==0)
			{
				temp=path_mem[path_i-1][path_j]+dis_mem[path_i][path_j];
				if(temp > 255)
					path_mem[path_i][path_j] = 255;
				else
					path_mem[path_i][path_j] = temp;
			}
			else
			{
				temp=min_data(path_mem[path_i][path_j-1],path_mem[path_i-1][path_j],path_mem[path_i-1][path_j-1])+dis_mem[path_i][path_j];
				if(temp > 255)
					path_mem[path_i][path_j] = 255;
				else
					path_mem[path_i][path_j] = temp;
			}
		}

	return path_mem[49][49];
}

unsigned char music_match(unsigned char F1[50],unsigned char F2[50],unsigned char F3[50],unsigned char F4[50],unsigned char F5[50],unsigned char R[50])
{
	unsigned char dtw_result1,dtw_result2,dtw_result3,dtw_result4,dtw_result5;
	unsigned char result[2];
	dtw_result1 = dtw(F1,R);
	dtw_result2 = dtw(F2,R);
	dtw_result3 = dtw(F3,R);
	dtw_result4 = dtw(F4,R);
	dtw_result5 = dtw(F5,R);

	min_five_data(result,dtw_result1,dtw_result2,dtw_result3,dtw_result4,dtw_result5);

	if(result[1] > 100)
		result[1] = 0;
	else
		result[1] = 100 - result[1];

	if(result[1] < 50)
	{
		result[1] = 0;
		result[0] = 7;
	}

	return result[0];
}

unsigned char score_match(unsigned char F1[50],unsigned char F2[50],unsigned char F3[50],unsigned char F4[50],unsigned char F5[50],unsigned char R[50])
{
	unsigned char dtw_result1,dtw_result2,dtw_result3,dtw_result4,dtw_result5;
	unsigned char result[2];
	dtw_result1 = dtw(F1,R);
	dtw_result2 = dtw(F2,R);
	dtw_result3 = dtw(F3,R);
	dtw_result4 = dtw(F4,R);
	dtw_result5 = dtw(F5,R);

	min_five_data(result,dtw_result1,dtw_result2,dtw_result3,dtw_result4,dtw_result5);

	if(result[1] > 100)
		result[1] = 0;
	else
		result[1] = 100 - result[1];

	if(result[1] < 50)
	{
		result[1] = 0;
		result[0] = 7;
	}

	return result[1];
}
