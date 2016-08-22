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

struct CardInfo{
	//width:72~85
	int cost,hp,hit,x,y,isMock,isReady;
};
class PlayerInfo{
public:
	int hp,armour,maxCrystal,curCrystal,hit;
	vector<CardInfo>handCards;
	vector<CardInfo>deckCards;
	bool my;
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

struct Attack{
	int l,r;
};
//import.
typedef vector<Attack> Attacks;
Attacks getActions(PlayerInfo&my,PlayerInfo&other);
PARSECARDSDLL_API char* WINAPI parseImgNew(const char *file,int type){
	//type==0 for getAI, ==1 for getImg, 2 for getALL.
	parse_init();
	mainProcess(file);
	Attacks as;
	if(type==1||type==2){
		my.getStr(retStr);
		other.getStr(buffer);
		strcat(retStr,"!");
		strcat(retStr,buffer);
	}
	strcat(retStr,"#");
	if(type==0||type==2){
		as=getActions(my,other);
		for(int i=0;i<as.size();i++){
			if(i!=0)strcat(retStr,"|");
			sprintf(buffer,"%d,%d",as[i].l,as[i].r);
			strcat(retStr,buffer);
		}
	}
	return retStr;
}


PARSECARDSDLL_API int WINAPI parseInt(const char *file){
	parse_init();
	return parseGold(Img(file));
}
int gint=5;

PARSECARDSDLL_API int WINAPI testGetInt(){
	gint++;
	return gint;
}


