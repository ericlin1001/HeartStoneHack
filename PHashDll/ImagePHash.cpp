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
struct Color{
	static Color BLACK,WHITE;
	PixelType r,g,b;
	Color(unsigned long c){
		b=c%256;
		c/=256;
		g=c%256;
		c/=256;
		r=c%256;
	}
	bool operator==(const Color &c){
		return r==c.r&&g==c.g&&b==c.b;
	}
	Color(){}
	Color(PixelType tr,PixelType tg,PixelType tb):r(tr),g(tg),b(tb){}
	void print(){
	printf("(%d,%d,%d)\n",r,g,b);
	}
	int getGray(){
		return (r*30+g*59+b*11)/100;
	}
	int subabs(PixelType a,PixelType b){
		if(a>b)return a-b;
		else return b-a;
	}
	bool isEachSim(Color c,double threSim){
		int t=threSim*256.0f;
		return subabs(r,c.r)<t&&subabs(g,c.g)<t&&subabs(b,c.b)<t;
	}
	bool isSim(Color c,double threSim){
		return abs(this->getGray()-c.getGray())<255.0f*threSim;
	}
	bool isBlack(){
		return r==0&&g==0&&b==0;
	}
};
Color Color::BLACK(0),Color::WHITE(0xffffff);


CImg<float>* ph_dct_matrix(const int N){
    CImg<float> *ptr_matrix = new CImg<float>(N,N,1,1,1/sqrt((float)N));
    const float c1 = sqrt(2.0f/N); 
    for (int x=0;x<N;x++){
        for (int y=1;y<N;y++){
            *ptr_matrix->data(x,y) = c1*(float)cos((cimg::PI/2/N)*y*(2*x+1));
        }
    }
    return ptr_matrix;
}
int ph_dct_imagehash(const char* file,ulong64 &hash){

    if (!file){
        return -1;
    }
    CImg<uint8_t> src;
    try {
        src.load(file);
    } catch (CImgIOException ex){
        return -1;
    }
    CImg<float> meanfilter(7,7,1,1,1);
    CImg<float> img;
    if (src.spectrum() == 3){
        img = src.RGBtoYCbCr().channel(0).get_convolve(meanfilter);
    } else if (src.spectrum() == 4){
        int width = img.width();
        int height = img.height();
        int depth = img.depth();
        img = src.crop(0,0,0,0,width-1,height-1,depth-1,2).RGBtoYCbCr().channel(0).get_convolve(meanfilter);
    } else {
        img = src.channel(0).get_convolve(meanfilter);
    }

    img.resize(32,32);
    CImg<float> *C  = ph_dct_matrix(32);
    CImg<float> Ctransp = C->get_transpose();

    CImg<float> dctImage = (*C)*img*Ctransp;

    CImg<float> subsec = dctImage.crop(1,1,8,8).unroll('x');;

    float median = subsec.median();
    ulong64 one = 0x0000000000000001;
    hash = 0x0000000000000000;
    for (int i=0;i< 64;i++){
        float current = subsec(i);
        if (current > median)
            hash |= one;
        one = one << 1;
    }

    delete C;

    return 0;
}


template<class T>
void showImage(const CImg<T>&c){
	CImgDisplay display(c,"ImageViewer",0);//important,0
	while(!display.is_closed()){
		cimg::wait(20);
	}
}


PHASHDLL_API ulong64 WINAPI getHash(const char *file){
	ulong64 hash;
	ph_dct_imagehash(file,hash);
	return hash;
}
PHASHDLL_API  int WINAPI getBinDiff(ulong64 a,ulong64 b){
	int i;
	int count=0;
	for(i=0;i<32;i++){
		if((a&1)!=(b&1))count++;
		a>>=1;
		b>>=1;
	}
	return count;
}
inline Color getColor(const Img&img,int i,int j,Color&c){
	c.r=img(i,j,0,0);
	c.g=img(i,j,0,1);
	c.b=img(i,j,0,2);
		return c;
}
int getColorCount(const Img&img,Color color,double sim=0.1){
	Color c;
	int w,h;
	w=img.width();
	h=img.height();
	int count=0;
	vector<double>vs;
	for(int i=0;i<w;i++){
		for(int j=0;j<h;j++){
			getColor(img,i,j,c);
			if(c.isEachSim(color,sim)){
				count++;
			}
		}
	}
	return count;
}

char retStr[100];
PHASHDLL_API char* WINAPI getCardInfo(const char *file){
	/************decide whether card is ready*****/
	/****the threshold of count of green(0x5bff3b) is 200*/
	bool isCardReady=false;
	int cost=-1;
	int hp=-2;
	int hit=-3;
	if(getColorCount(Img(file),Color(0x5bff3b),0.02)>200){
		isCardReady=true;
	}else {
		isCardReady=false;
	}
	/********/
	sprintf(retStr,"(ready,cost,hp,hit)=|%d|%d|%d|%d|%d|",isCardReady?1:0,cost,hp,hit,getColorCount(Img(file),Color(0x5bff3b),0.02));
	return retStr;
}

PHASHDLL_API int WINAPI isDiffImg(const char *f1,const char *f2,int thre=5){
	ulong64 a,b;
	int diff=0;
	int i;
	ph_dct_imagehash(f1,a);
	ph_dct_imagehash(f2,b);
	for(i=0;i<32;i++){
		if((a&1)!=(b&1)){diff++;if(diff>=thre)return 1;}
		a>>=1;
		b>>=1;
	}
	return 0;
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