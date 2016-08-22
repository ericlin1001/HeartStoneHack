// ParseCardsDll.cpp : Defines the exported functions for the DLL application.
//

#include "stdafx.h"
#include <Windows.h>
#include <iostream>
#include<algorithm>
#include<vector>
#include<stdio.h>
#include "CImg.h"
#include "ParseCardsDll.h"
using namespace cimg_library;
using namespace std;
#define Trace(m) cout<<#m"="<<(m)<<endl;
typedef unsigned int PixelType ;
typedef  CImg<PixelType> Img;

int parseGold(Img&img);
class PlayerInfo{
public:
	void getStr(char *);
};

extern void mainProcess(const char *file);
extern PlayerInfo my,other;
extern void parse_init();
PARSECARDSDLL_API void WINAPI init(void){
	parse_init();
}
char retStr[1024];
char buffer[1024];
PARSECARDSDLL_API char* WINAPI parseImg(const char *file){
	parse_init();
	mainProcess(file);
	my.getStr(retStr);
	other.getStr(buffer);
	strcat(retStr,"!");
	strcat(retStr,buffer);
	return retStr;
}
PARSECARDSDLL_API int WINAPI parseInt(const char *file){
	parse_init();
	return parseGold(Img(file));
}


