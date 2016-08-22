// ImagePHash.cpp : Defines the entry point for the console application.
//
#include "stdafx.h"
#include <Windows.h>
#include <iostream>
#include<algorithm>
#include<vector>
#include<stdio.h>
#include "CImg.h"
#include "stdafx.h"
#include "PHashDll.h"

typedef unsigned long long ulong64;
typedef signed long long long64;
typedef unsigned char uint8_t;
typedef unsigned int uint32_t;

using namespace cimg_library;
using namespace std;
#define Trace(m) cout<<#m"="<<(m)<<endl;
typedef unsigned int PixelType ;
typedef  CImg<PixelType> Img;

class PlayerInfo{
public:
	void getStr(char *);
};

extern void mainProcess(const char *file);
extern PlayerInfo my,other;
extern void parse_init();
PHASHDLL_API void WINAPI init(void){
	parse_init();
}
char retStr[1024];
PHASHDLL_API char* WINAPI parseImg(const char *file){
	mainProcess(file);
	char buffer[1024];
	my.getStr(retStr);
	other.getStr(buffer);
	strcat(retStr,"!");
	strcat(retStr,buffer);
	printf(retStr);
	return retStr;
}


/*
int numf=10;
char files[20][100];
ulong64 hashs[100];
int diff[20][20];
int main(){
	//Img img=Img("a.bmp").normalize(0,255);
	//showImage(img);

	for(int i=0;i<numf;i++){
		sprintf(files[i],"h%d.bmp",i);
		hashs[i]=getHash(files[i]);
	}
	for(int i=0;i<numf;i++){
		for(int j=0;j<numf;j++){
			diff[i][j]=getBinDiff(hashs[i],hashs[j]);
		}
	}
	cout<<"DiffMatrix:"<<endl;
	for(int i=0;i<numf;i++){
		if(i==0){
			cout<<"0\t";
			for(int j=0;j<numf;j++){
			cout<<j<<"\t";
			}
			cout<<endl;
		}
		cout<<i<<"\t";
		for(int j=0;j<numf;j++){
			cout<<isDiffImg(files[i],files[j])<<"\t";
		}
		cout<<endl;
	}
	
	//cout<<"hello"<<endl;

//	system("pause");
	return 0;
}
*/