// TestAutoit.cpp : Defines the entry point for the console application.
#include "stdafx.h"
#include <Windows.h>
#include <iostream>
#include<algorithm>
#include<list>
#include<vector>
#include<stdio.h>
#include "CImg.h"
using namespace cimg_library;
using namespace std;
#define Trace(m) cout<<#m"="<<(m)<<endl;
typedef unsigned int PixelType ;
typedef  CImg<PixelType> Img;
template<class T>
void printArr(const vector<T>&a){
	cout<<"[";
	for(int i=0;i<a.size();i++){
		if(i!=0)cout<<",";
		a[i].print();
	}
	cout<<"]";
	cout<<endl;
}
#define ConstInfite 100000
//#define dimx width
//#define dimy height
/*********global variables***********/

vector<Img>ds;
vector<Img>lds;
vector<Img>mds;
/*********end global variables***********/

/*****************pHash**************/

/****************end pHash***********************/
template<class T>
void showImage(const CImg<T>&c){
	CImgDisplay display(c,"ImageViewer");
	//display.display(c);
	while(!display.closed)
		display.wait();
}

const PixelType red[] = { 255,0,0 }, green[] = { 0,255,0 }, blue[] = { 0,0,255 };
class Region{
	public:
	unsigned int x0,y0,x1,y1;
	Region(int _x0,int _y0,int _x1,int _y1):x0(_x0),y0(_y0),x1(_x1),y1(_y1){
	}
	Region(){
	}
	/*void init(int x0,int y0,int x1,int y1){
	}*/
};
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
		int t=int(threSim*256.0f);
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

int getColorCount(const Img&img,Color color,double sim=0.1);
void setColor(Img&img,int i,int j,const Color&c);

inline Color getColor(const Img&img,int i,int j,Color&c){
	c.r=img(i,j,0,0);
	c.g=img(i,j,0,1);
	c.b=img(i,j,0,2);
		return c;
}
void clip(Img&img){
	int w,h;
	w=img.dimx();
	h=img.dimy();
	int x0=0,y0=0,x1=w-1,y1=h-1;
	Color c,t;
	getColor(img,0,0,c);
	bool isTrun;
	isTrun=false;
	for(int i=x0;i<=x1;i++){
		for(int j=y0;j<=y1;j++){
			if(!(getColor(img,i,j,t)==c)){isTrun=true;break;}
		}
		if(isTrun){
			x0=i;
			break;
		}
	}
	isTrun=false;
	for(int i=x1;i>=x0;i--){
		for(int j=y0;j<=y1;j++){
			if(!(getColor(img,i,j,t)==c)){isTrun=true;break;}
		}
		if(isTrun){
			x1=i;
			break;
		}
	}
	isTrun=false;
	for(int j=y0;j<=y1;j++){
		for(int i=x0;i<=x1;i++){
			if(!(getColor(img,i,j,t)==c)){isTrun=true;break;}
		}
		if(isTrun){
			y0=j;
			break;
		}
	}
	isTrun=false;
	for(int j=y1;j>=y0;j--){
		for(int i=x0;i<=x1;i++){
			if(!(getColor(img,i,j,t)==c)){isTrun=true;break;}
		}
		if(isTrun){
			y1=j;
			break;
		}
	}
	img.crop(x0,y0,x1,y1,0);
}
int getP(const Img&i1){
	int w,h;
	w=i1.dimx();
	h=i1.dimy();
	int s=0;
	Color c;
	for(int i=0;i<w;i++){
		for(int j=0;j<h;j++){
			getColor(i1,i,j,c);
			if(!c.isBlack())s++;
		}
	}
	return s;
}

double getImgSim(const Img&i1,int fx,int fy,const Img&i2,int w,int h){
	double s=0;
	for(int i=0;i<w;i++){
		for(int j=0;j<h;j++){
			Color c1,c2;
			getColor(i1,fx+i,fy+j,c1);
			getColor(i2,i,j,c2);
			if(!(c1==c2))s+=1;
			if(!c1.isBlack())s-=0.4;//for digital:10, 
		}
	}
	//maxof(s)=140
	return -s;
}
//int ms[2][2];
//printf("ms:%d,%d,%d,%d",ms[0][0],ms[0][1],ms[1][0],ms[1][1]);
double getImgSim3(const Img&i1,int fx,int fy,const Img&i2,int w,int h){
	double s=0;
	//printf("start count\n");
	//showImage(i1);
	//showImage(i2);
	//ms[0][0]++;
	//ms[0][1]++;
	//ms[1][0]++;
	//ms[1][1]++;
	double ws[2][2];
	ws[0][0]=0.4;//ww
	ws[0][1]=-(0.5-0.08);//wb
	ws[1][0]=-(1.1);//bw
	ws[1][1]=-(0.08);//bb
	for(int i=0;i<w;i++){
		for(int j=0;j<h;j++){
			Color c1,c2;
			getColor(i1,fx+i,fy+j,c1);
			getColor(i2,i,j,c2);
		/*	if(!(c1==c2))s+=1;
			if(!c1.isBlack())s-=0.4;//for digital:10, */
			if(!c2.isBlack()){
				//mask is white
				if(!c1.isBlack()){
					s+=ws[0][0];
					//ms[0][0]++;
				}
				else {
					s+=ws[1][0];//mask is white, but it's not white,means possible low.
				//ms[1][0]++;
				}
			}else{
				if(!c1.isBlack()){//more likely.
				//ms[0][1]++;
				s+=ws[0][1];
				}else{
					//ms[1][1]++;
					s+=ws[1][1];
				}
			}

		}
	}
	//maxof(s)=140
	return s;
}
double getImgSim2(const Img&i1,int fx,int fy,const Img&i2,int w,int h){
	double s=0;
	for(int i=0;i<w;i++){
		for(int j=0;j<h;j++){
			Color c1,c2;
			getColor(i1,fx+i,fy+j,c1);
			getColor(i2,i,j,c2);
			if(!c2.isBlack()){
				//mask is white
				if(!c1.isBlack())s+=1;
				else s-=0.8;//mask is white, but it's not white,means possible low.
			}else{
				if(!c1.isBlack())s-=0.6;//more likely.
			}
			//if(!(c1==c2))s+=1;
			//if(!c1.isBlack())s-=0.4;//for digital:10, 
		}
	}
	//maxof(s)=140
	return s;
}

#define INFINITY 100000
double findImg(const Img&i1,const Img&i2,int &x,int &y,double thre=0.9){
	int w,h,w2,h2;
	x=-1;
	y=-1;
	w=i1.dimx();
	h=i1.dimy();
	w2=i2.dimx();
	h2=i2.dimy();
	int dw=w-w2;
	int dh=h-h2;
	double maxSim=-INFINITY;
	double r=0;
	for(int i=0;i<=dw;i++){
		for(int j=0;j<=dh;j++){
			double k=getImgSim(i1,i,j,i2,w2,h2);
			if(k>maxSim){
				x=i;
				y=j;
				maxSim=k;
				//r=((double)maxSim)/pow((double)p,0.8);
				r=maxSim;
				if(r>=thre)return r;
			}
		}
	}
	return r;
}
double findImg3(const Img&i1,const Img&i2,int &x,int &y,double thre=0.9){
	int w,h,w2,h2;
	x=-1;
	y=-1;
	w=i1.dimx();
	h=i1.dimy();
	w2=i2.dimx();
	h2=i2.dimy();
	int dw=w-w2;
	int dh=h-h2;
	double maxSim=-INFINITY;
	double r=0;
	for(int i=0;i<=dw;i++){
		for(int j=0;j<=dh;j++){
			double k=getImgSim3(i1,i,j,i2,w2,h2);
			if(k>maxSim){
				x=i;
				y=j;
				maxSim=k;
				//r=((double)maxSim)/pow((double)p,0.8);
				r=maxSim;
				if(r>=thre)return r;
			}
		}
	}
	return r;
}

double findImg2(const Img&i1,const Img&i2,int &x,int &y,double thre=0.9){
	int w,h,w2,h2;
	x=-1;
	y=-1;
	w=i1.dimx();
	h=i1.dimy();
	w2=i2.dimx();
	h2=i2.dimy();
	int dw=w-w2;
	int dh=h-h2;
	double maxSim=-INFINITY;
	//int p2=getP(i2);
	int p1=getP(i1);
	double p2=getP(i2);

	double r=0;
	for(int i=0;i<=dw;i++){
		for(int j=0;j<=dh;j++){
			double k=getImgSim2(i1,i,j,i2,w2,h2);
			if(k>maxSim){
				x=i;
				y=j;
				maxSim=k;
				//r=((double)maxSim)/pow((double)p,0.8);
				r=maxSim;//+p1;//-0.5f*p2;
				if(r>=thre)return r;
			}
		}
	}
	return r;
}


struct Coord{
	int i;
	int x,y;
	double sim;
	bool operator<(const Coord&c){
		return sim<c.sim;
	}
	void print(){
		printf("i:%d sim:%f",i,sim);
	}
};

int findImgs(Img&img,const vector<Img>&imgs,double thre=0){
	vector<Coord>cs;
	Coord c;
	for(int i=0;i<imgs.size();i++){
			int x,y;
			double sim=findImg3(img,imgs[i],x,y);
			c.x=x;
			c.y=y;
			c.i=i;
			c.sim=sim;
			cs.push_back(c);
	}
	//cs[1].sim-=0.05;
	/*cout<<"cs.size="<<cs.size()<<endl;
	for(int i=0;i<cs.size();i++){
		cs[i].print();cout<<endl;
	}*/
	if(cs.empty())	return -1;
	sort(cs.begin(),cs.end());
	if(cs.back().sim<=thre)return -1;
	return cs.back().i;
}
int findImgs2(Img&img,const vector<Img>&imgs,double thre=0){
	vector<Coord>cs;
	Coord c;
	for(int i=0;i<imgs.size();i++){
			int x,y;
			double sim=findImg2(img,imgs[i],x,y);
			c.x=x;
			c.y=y;
			c.i=i;
			c.sim=sim;
			cs.push_back(c);
			/*if(x!=-1){
				Trace(x);
				img.draw_circle(x,y,2,red,0,1);
				Trace(i);
				showImage(img);
			}*/
	}
	//cs[1].sim-=0.05;
	/*cout<<"cs.size="<<cs.size()<<endl;
	for(int i=0;i<cs.size();i++){
		cs[i].print();cout<<endl;
	}*/
	if(cs.empty())	return -1;
	sort(cs.begin(),cs.end());
	if(cs.back().sim<=thre)return -1;
	return cs.back().i;
		/*
	Img d("./imgs/2.bmp");
	showImage(d);
	int x,y;
	Trace(findImg(img,d,x,y));
	Trace(x);
	if(x!=-1){
		img.draw_circle(x,y,1,red,0,1);
	}
	return -1;*/
}
int findImgs3(Img&img,const vector<Img>&imgs,double thre=0){
	vector<Coord>cs;
	Coord c;
	for(int i=0;i<imgs.size();i++){
			int x,y;
			double sim=findImg3(img,imgs[i],x,y);
			c.x=x;
			c.y=y;
			c.i=i;
			c.sim=sim;
			cs.push_back(c);
			/*if(x!=-1){
				Trace(x);
				img.draw_circle(x,y,2,red,0,1);
				Trace(i);
				showImage(img);
			}*/
	}
	//cs[1].sim-=0.05;
	/*cout<<"cs.size="<<cs.size()<<endl;
	for(int i=0;i<cs.size();i++){
		cs[i].print();cout<<endl;
	}*/
	if(cs.empty())	return -1;
	sort(cs.begin(),cs.end());
	if(cs.back().sim<=thre)return -1;
	return cs.back().i;
		/*
	Img d("./imgs/2.bmp");
	showImage(d);
	int x,y;
	Trace(findImg(img,d,x,y));
	Trace(x);
	if(x!=-1){
		img.draw_circle(x,y,1,red,0,1);
	}
	return -1;*/
}
int getImgInt(Img&img){
	return findImgs(img,ds,-12);
	//return findImgs2(img,ds,-13);
}
int getImgInt1(Img&img){
	//return findImgs(img,lds,-21);
	return findImgs2(img,lds,-13);
}
int getImgInt2(Img&img){
	return findImgs2(img,mds,-13);
}
int getImgInt3(Img&img){
	vector<Img>gds=ds;
	gds.pop_back();
	return findImgs3(img,gds,-12);
	//return findImgs2(img,ds,-13);
}
void thresholdSplit(Img&img,double thre){
	int w,h;
	w=img.dimx();
	h=img.dimy();
	vector<double>vs;
	for(int i=0;i<w;i++){
		for(int j=0;j<h;j++){
			double r=img(i,j,0,0);
			double g=img(i,j,0,1);
			double b=img(i,j,0,2);
			double v=(r*256+g*512+b*128)/1024;
			vs.push_back(v);
		}
	}
	sort(vs.begin(),vs.end());
	double t=vs.at(thre*(double)vs.size());
	//Trace(t);
	for(int i=0;i<w;i++){
		for(int j=0;j<h;j++){
			double r=img(i,j,0,0);
			double g=img(i,j,0,1);
			double b=img(i,j,0,2);
			double v=(r*256+g*512+b*128)/1024;
			//Trace(v);
			for(int k=0;k<3;k++){
				if(v>=t)
					img(i,j,0,k)=0;
				else
					img(i,j,0,k)=255;
			}
		}
	}
}
void twoDis(Img&img){
	int w,h;
	w=img.dimx();
	h=img.dimy();
	vector<double>vs;
	for(int i=0;i<w;i++){
		for(int j=0;j<h;j++){
			double r=img(i,j,0,0);
			double g=img(i,j,0,1);
			double b=img(i,j,0,2);
			double v=(r*256+g*512+b*128)/1024;
			vs.push_back(v);
		}
	}
	sort(vs.begin(),vs.end());
	double t=vs.at(vs.size()*80/100);
	//Trace(t);
	for(int i=0;i<w;i++){
		for(int j=0;j<h;j++){
			double r=img(i,j,0,0);
			double g=img(i,j,0,1);
			double b=img(i,j,0,2);
			double v=(r*256+g*512+b*128)/1024;
			//Trace(v);
			for(int k=0;k<3;k++){
				if(v>=t)
					img(i,j,0,k)=255;
				else
					img(i,j,0,k)=0;
			}
		}
	}
}
void twoDis1(Img&img){
	int w,h;
	w=img.dimx();
	h=img.dimy();
	vector<double>vs;
	for(int i=0;i<w;i++){
		for(int j=0;j<h;j++){
			double r=img(i,j,0,0);
			double g=img(i,j,0,1);
			double b=img(i,j,0,2);
			double v=(r*256+g*512+b*128)/1024;
			vs.push_back(v);
		}
	}
	sort(vs.begin(),vs.end());
	double t=vs.at(vs.size()*20/100);
	//Trace(t);
	for(int i=0;i<w;i++){
		for(int j=0;j<h;j++){
			double r=img(i,j,0,0);
			double g=img(i,j,0,1);
			double b=img(i,j,0,2);
			double v=(r*256+g*512+b*128)/1024;
			//Trace(v);
			for(int k=0;k<3;k++){
				if(v<=t)
					img(i,j,0,k)=255;
				else
					img(i,j,0,k)=0;
			}
		}
	}
}
void twoDis2(Img&img){
	int w,h;
	w=img.dimx();
	h=img.dimy();
	vector<double>vs;
	for(int i=0;i<w;i++){
		for(int j=0;j<h;j++){
			double r=img(i,j,0,0);
			double g=img(i,j,0,1);
			double b=img(i,j,0,2);
			double v=(r*256+g*512+b*128)/1024;
			vs.push_back(v);
		}
	}
	sort(vs.begin(),vs.end());
	double t=vs.at(vs.size()*5/100);
	//Trace(t);
	for(int i=0;i<w;i++){
		for(int j=0;j<h;j++){
			Color c;
			getColor(img,i,j,c);
			if(c.isEachSim(Color(0x000000),0.15)||c.getGray()<t){
				setColor(img,i,j,Color::WHITE);
			}else{
				setColor(img,i,j,Color::BLACK);
			}
		}
	}
}
void twoDis3(Img&img){
	int w,h;
	w=img.dimx();
	h=img.dimy();
	vector<double>vs;
	for(int i=0;i<w;i++){
		for(int j=0;j<h;j++){
			double r=img(i,j,0,0);
			double g=img(i,j,0,1);
			double b=img(i,j,0,2);
			double v=(r*256+g*512+b*128)/1024;
			vs.push_back(v);
		}
	}
	sort(vs.begin(),vs.end());
	double t=vs.at(vs.size()*99/100);
	//Trace(t);
	for(int i=0;i<w;i++){
		for(int j=0;j<h;j++){
			Color c;
			getColor(img,i,j,c);
			if(c.isEachSim(Color(0xffffff),0.08)||c.getGray()>t){
				setColor(img,i,j,Color::WHITE);
			}else{
				setColor(img,i,j,Color::BLACK);
			}
		}
	}
}

void process(Img&img){
	//showImage(img);
	twoDis3(img);
	//showImage(img);
	//clip(img);
	//showImage(img);
}
void process1(Img&img){
	//showImage(img);
	twoDis1(img);
	//showImage(img);
	//clip(img);
	//showImage(img);
}
void process2(Img&img){
	//img.blur_anisotropic(8,10);
	//showImage(img);
	twoDis2(img);
	//showImage(img);
	//clip(img);
	//showImage(img);
}

struct CardInfo{
	//width:72~85
	int cost,hp,hit,x,y,isMock,isReady;
	void print(){
		printf("CardInfo[cost:%d,hit/hp:%d/%d,coord:(%d,%d),isMock:%d,isReady:%d]",cost,hit,hp,x,y,isMock,isReady);
	}
	CardInfo(){
		cost=0;
		hp=-1;
		hit=-1;
		x=-1;
		y=-1;
		isMock=-1;
	}
	void getStr(char *str){
		sprintf(str,"cost:%d/hit:%d/hp:%d/x:%d/y:%d/isMock:%d/isReady:%d",cost,hit,hp,x,y,isMock,isReady);
	}

};
Img getImgR(Img&img,const Region&r){
	return img.get_crop(r.x0,r.y0,r.x1,r.y1);
}

class ImgParser{
	Img img;
public:
	ImgParser(const char *file):img(file){
		cout<<"test:"<<file<<endl;
	}
	int getCurCrystal(){
		Img i=img.get_crop(820, 652,840, 669,0);
		process(i);
		return getImgInt(i);
	}
	int getMaxCrystal(){
		Img i=img.get_crop(840, 652,861, 669,0);
		process(i);
		return getImgInt(i);
	}
	int getHp(){
		//692
		Img all=img.get_crop(679,584,707,606,0);
		Img all0=img.get_crop(679,584,692,606,0);
		Img all1=img.get_crop(692,584,707,606,0);
		process1(all0);
		int a0=getImgInt1(all0);
		if(a0==-1){
			//not found in left half.
			process1(all);
			return getImgInt1(all);
		}
		process1(all1);
		int a1=getImgInt1(all1);
		return a0*10+a1;
		/*
		process1(i);
		Trace();
		return 0;*/
	}
	void test(){
		Trace(getHp());
	}
};
bool isFileExist(const char *file){
	FILE* f=fopen(file,"r");
	if(f==NULL)return false;
	fclose(f);
	return true;
}
struct DInfo{
	int c1,c2;
	int hp;
	char file[100];
};
/*for(int i=0;i<w;i++){
		for(int j=0;j<h;j++){
			double r=img(i,j,0,0);
			double g=img(i,j,0,1);
			double b=img(i,j,0,2);
			double v=(r*256+g*512+b*128)/1024;
			vs.push_back(v);
		}
	}
	sort(vs.begin(),vs.end());
	double t=vs.at(vs.size()*20/100);
	//Trace(t);
	for(int i=0;i<w;i++){
		for(int j=0;j<h;j++){
			double r=img(i,j,0,0);
			double g=img(i,j,0,1);
			double b=img(i,j,0,2);
			double v=(r*256+g*512+b*128)/1024;
			//Trace(v);
			for(int k=0;k<3;k++){
				if(v<=t)
					img(i,j,0,k)=255;
				else
					img(i,j,0,k)=0;
			}
		}
	}*/
void setColor(Img&img,int i,int j,const Color&c){
	img(i,j,0,0)=c.r;
img(i,j,0,1)=c.g;
img(i,j,0,2)=c.b;
}

void colorRemove(Img&img,Color c0,double threSim=0.1){
	//b27945
	//Color c0(0xc5,0x75,0x55);
	Color c;
	int w,h;
	w=img.dimx();
	h=img.dimy();
	vector<double>vs;
	for(int i=0;i<w;i++){
		for(int j=0;j<h;j++){
			getColor(img,i,j,c);
			if(c.isSim(c0,threSim)){
				setColor(img,i,j,Color::WHITE);
			}
		}
	}
}
/*
void imgErosion(Img&img){
	int w,h;
	w=img.dimx();
	h=img.dimy();
	vector<double>vs;
	Color c;
	for(int i=0;i<w;i++){//i=0??
		for(int j=0;j<h;j++){
			getColor(img,i,j,c);
			bool isSet=false;
			if(c.isBlack()){
				for(int m=-1;m<2;m++){
					for(int n=-1;n<2;n++){
						if(!getColor(img,i+m,j+n,c).isBlack()){//getcolor(i+m Bug:range)
							setColor(img,i,j,Color::WHITE);
							isSet=true;
							break;
						}
					}
					if(isSet){
						isSet=false;
						break;
					}
				}
			}
		}
	}
}
void imgDilation(Img&img){
	int w,h;
	w=img.dimx();
	h=img.dimy();
	vector<double>vs;
	Color c;
	for(int i=1;i<w-1;i++){
		for(int j=1;j<h-1;j++){
			getColor(img,i,j,c);
			bool isSet=false;
			if(!c.isBlack()){
				for(int m=-1;m<2;m++){
					for(int n=-1;n<2;n++){
						if(getColor(img,i+m,j+n,c).isBlack()){//getcolor(i+m Bug:range)
							setColor(img,i,j,Color::BLACK);
							isSet=true;
							break;
						}
					}
					if(isSet){
						isSet=false;
						break;
					}
				}
			}
		}
	}
}*/
#define iter(cmd,n) for(int i=0;i<n;i++){cmd;}

bool isAllCol(Img&img,int i,Color color){
	int h=img.dimy();
	Color c;
	for(int j=0;j<h;j++){
		getColor(img,i,j,c);
			if(!(c==color))return false;
	}
	return true;
}
bool getRange(Img&img,int &fromx,int &tox,int minWidth=1){
	int w,h;
	w=img.dimx();
	h=img.dimy();
	vector<double>vs;
	Color c;
	int i;
	for(i=fromx;i<w;i++){
		if(!isAllCol(img,i,Color::BLACK))break;
	}
	if(i>=w)return false;
	fromx=i;
	for(i=fromx+minWidth;i<w;i++){
		if(isAllCol(img,i,Color::BLACK))break;
	}
	if(i>=w)tox=w-1;
	else tox=i;
	_ASSERT(fromx<=tox);
	//	if(fromx>tox)return false;
	return true;
}
int getAllColCount(Img&img,int fromx,int tox,Color color){
	int h=img.dimy();
	Color c;
	int count=0;
	for(int i=fromx;i<=tox;i++){
		for(int j=0;j<h;j++){
			getColor(img,i,j,c);
			if(c==color){
				count++;
			}
		}
	}
	return count;
}
bool parseDeckCard(Img&img,CardInfo&card){
	Color c;
	const int dgwidth=30;
	const int dgheight=24;
	const int dgy=72;
	const int ndgx=48;
	//
	if(img.dimx()<ndgx+dgwidth/2)return false;
	Img hitImg=img.get_crop(0,dgy,dgwidth,dgy+dgheight);
	Img hpImg=img.get_crop(ndgx,dgy,ndgx+dgwidth,dgy+dgheight);
	//showImage(img);
	//Trace(getColorCount(img,Color(0x5bff3b),0.02));
	//showImage(img);
	
	process2(hitImg);
	card.hit=getImgInt2(hitImg);
	//Trace(card.hit);


	process2(hpImg);
	card.hp=getImgInt2(hpImg);
	//Trace(card.hp);

	//if(card.hp<0 && card.hit<0)return false;


	/*************/
	
	if(getColorCount(img,Color(0x5bff3b),0.02)>=20){
		card.isReady=true;
	}else{
		card.isReady=false;
	}
	//showImage(hpImg);
	getColor(img,9,12,c);
	if(c.isSim(Color(0x4b413b),0.2)||c.isSim(Color(0x907f0f),0.1)){
		card.isMock=1;
	}else{
		card.isMock=0;
	}
	//card.print();cout<<endl;
	//showImage(img);
	return true;
}

vector<CardInfo> processDeckCard_old(Img&img){
	Img origin_img=img;
	Img img1=img;
	colorRemove(img,Color(0xd79758));
	colorRemove(img,Color(0x926032),0.05);
	colorRemove(img,Color(0xb87e49),0.05);
	colorRemove(img,Color(0xa26b3b),0.05);
	colorRemove(img,Color(0x392115),0.05);
	//showImage(img);
	thresholdSplit(img,0.2);
	//showImage(img);
	iter(img.dilate(1),2);
	//showImage(img);
	iter(img.erode(1),4);
	iter(img.dilate(1),2);
	//showImage(img);
	iter(img.dilate(1);img.erode(1);,1)
	showImage(img);
	
	vector<Coord>cs;
	Coord c;
	int last=-1;
	while(1){
		c.x=last+1;
		if(!getRange(img,c.x,c.y,10))break;
		last=c.y;
#define MIN_DECK_CARD_WIDTH 72.0f
#define MAX_DECK_CARD_WIDTH 85.0f
		if((c.y-c.x)<MIN_DECK_CARD_WIDTH)continue;
		//if((c.y-c.x)>MAX_DECK_CARD_WIDTH*1.5f)continue;
		int countw=getAllColCount(img,c.x,c.y,Color::WHITE);
		if(countw<1500)continue;
		if((c.y-c.x)>MAX_DECK_CARD_WIDTH){
			c.y=c.x+(int)(MIN_DECK_CARD_WIDTH+MAX_DECK_CARD_WIDTH)/2;
		}
		//printf("#%d from->to: %d,%d count:%d\n",i,cs[i].x,cs[i].y,getAllColCount(img,c.x,c.y,Color::WHITE));
		cs.push_back(c);
	}
	/***********parse card***********/
	vector<CardInfo>cards;
	CardInfo card;
	img=origin_img;
	for(int i=0;i<cs.size();i++){
		Coord c=cs[i];
		if(parseDeckCard(img.get_crop(c.x,c.y+10,0),card)){
			card.x=c.x;
			cards.push_back(card);
		}
	}
	return cards;
}


bool getColorIndex(Img&img,int j,int &fromx, Color color,double sim=0.13){
	int w;
	w=img.dimx();
	int i;
	for(i=fromx;i<w;i++){
		Color c;
		getColor(img,i,j,c);
		if(c.isEachSim(color,sim)){
			fromx=i;
			return true;
		}
	}
	return false;
}
vector<CardInfo> processDeckCard(Img&img){
	Img origin_img=img;
	int w=img.dimx();
	int h=img.dimy();
	/*colorRemove(img,Color(0xd79758));
	colorRemove(img,Color(0x926032),0.05);
	colorRemove(img,Color(0xb87e49),0.05);
	colorRemove(img,Color(0xa26b3b),0.05);
	colorRemove(img,Color(0x392115),0.05);*/
	int my=h/2-2;
	Img m=img.get_crop(0,h/2,w,h/2+10);
	//showImage(m);
	//showImage(img);
	/*thresholdSplit(img,0.2);
	//showImage(img);
	iter(img.dilate(1),2);
	//showImage(img);
	iter(img.erode(1),4);
	iter(img.dilate(1),2);
	//showImage(img);
	iter(img.dilate(1);img.erode(1);,1)
	showImage(img);
	*/
	vector<Coord>cs;
	Coord c;
	c.x=0;
	while(1){
		if(getColorIndex(img,my,c.x,Color(0x5c5e57))){
			int lastx=c.x;
			c.x-=2;
			c.y=c.x+80;
			cs.push_back(c);
			c.x=lastx+85;
		}else{
			break;
		}
	}
	/*
	int last=-1;
	while(1){
		c.x=last+1;
		if(!getColorIndex(img,c.x,c.y,10))break;
		last=c.y;
#define MIN_DECK_CARD_WIDTH 72.0f
#define MAX_DECK_CARD_WIDTH 85.0f
		if((c.y-c.x)<MIN_DECK_CARD_WIDTH)continue;
		//if((c.y-c.x)>MAX_DECK_CARD_WIDTH*1.5f)continue;
		int countw=getAllColCount(img,c.x,c.y,Color::WHITE);
		if(countw<1500)continue;
		if((c.y-c.x)>MAX_DECK_CARD_WIDTH){
			c.y=c.x+(int)(MIN_DECK_CARD_WIDTH+MAX_DECK_CARD_WIDTH)/2;
		}
		//printf("#%d from->to: %d,%d count:%d\n",i,cs[i].x,cs[i].y,getAllColCount(img,c.x,c.y,Color::WHITE));
		cs.push_back(c);
	}*/
	/***********parse card***********/
	vector<CardInfo>cards;
	CardInfo card;
	img=origin_img;
	for(int i=0;i<cs.size();i++){
		Coord c=cs[i];
		if(parseDeckCard(img.get_crop(c.x,c.y+10,0),card)){
			card.x=c.x;
			cards.push_back(card);
		}
	}
	return cards;
}
vector<CardInfo>processHandCard(Img &img){
	//showImage(img);
	vector<Coord>cs;
	Coord c;
	c.x=0;
	const int minStep=10;
	while(1){
		//green:0x49ff30
		if(getColorIndex(img,0,c.x,Color(0x4dff33),0.2)){
			int lastx=c.x;
			cs.push_back(c);
			c.x=lastx+minStep;
		}else{
			break;
		}
		//cout<<"find one card"<<endl;
	}
	if(cs.size()>=2) {
		cs.pop_back();
	}
	/***********parse card***********/
	vector<CardInfo>cards;
	CardInfo card;
	for(int i=0;i<cs.size();i++){
		Coord c=cs[i];
		card.x=c.x;
		card.isReady=true;
		cards.push_back(card);
	}
	return cards;
}
int processHeroHit(Img&img){
	int w=img.dimx();
	int h=img.dimy();
	img=img.get_crop(w/2,w,0);

	showImage(img);
	img.blur(6,0);
	showImage(img);

	Color c;
		getColor(img,img.dimx()/2,img.dimy()/2,c);
		if(c.isEachSim(0xedb115,0.3)){
			return 1;
		}else{
			return 0;
		}
}

class PlayerInfo{
public:
	int hp,armour,maxCrystal,curCrystal,hit;
	vector<CardInfo>handCards;
	vector<CardInfo>deckCards;
	bool my;
	PlayerInfo(){
		hp=-1;
		armour=-1;
		maxCrystal=-1;
		curCrystal=-1;
		hit=1;
	}
	Region deckR,curCrystalR,maxCrystalR,hp0R,hp1R,hp2R,handR,hitR;
	Img img;
	void init(Region deck,Region curCrystal,Region maxCrystal,Region hp0,Region hp1,Region hp2,Region hand,Region hitR){
		this->deckR=deck;
		this->curCrystalR=curCrystal;
		this->maxCrystalR=maxCrystal;
		this->hp0R=hp0;
		this->hp1R=hp1;
		this->hp2R=hp2;
		this->handR=hand;
		this->hitR=hitR;
	}
public:
	void parse(Img&img){
		this->img=img;
		parseCrystal();
		parseHP();
		parseDeckCards();
		parseHandCards();
		parseHit();
	}
	void parseHit(){
		Img i=getImgR(img,hitR);
		//hit=processHeroHit(i);
		process1(i);
		hit=getImgInt1(i);

	}
	void parseHandCards(){
		Img i=getImgR(img,handR);
		handCards=processHandCard(i);
		for(int i=0;i<handCards.size();i++){
			handCards[i].x+=handR.x0+10;
			handCards[i].y=handR.y0;
		}
	}

	void print(){
		if(my){
			printf("My");
			}else{
			printf("Other");
		}
		printf("(hp:%d,armour:%d,crystal:%d/%d,hit:%d)\n",hp,armour,curCrystal,maxCrystal,hit);
		printf("Had cards[%d]:\n",handCards.size());
		if(my){
			for(int i=0;i<handCards.size();i++){
				printf("#%d ",i);handCards[i].print();printf("\n");
			}
		}
		printf("Deck cards[%d]:\n",deckCards.size());
		for(int i=0;i<deckCards.size();i++){
			printf("#%d ",i);deckCards[i].print();printf("\n");
		}
		printf("\n");
	}
	void getStr(char*str);
private:
void parseCrystal(){
	Img i;
	i=getImgR(img,curCrystalR);
	process(i);
	curCrystal=getImgInt(i);
	/*****/
	i=getImgR(img,maxCrystalR);
	process(i);
	maxCrystal=getImgInt(i);
}
void parseHP(){
	Img all=getImgR(img,hp0R);
		Img all0=getImgR(img,hp1R);
		Img all1=getImgR(img,hp2R);
		process1(all0);
		int a0=getImgInt1(all0);
		if(a0==-1){
			//not found in left half.
			process1(all);
			hp=getImgInt1(all);
		}else{
			process1(all1);
			int a1=getImgInt1(all1);
			hp=a0*10+a1;
		}
}
	void parseDeckCards(){
		Img i=getImgR(img,deckR);
		deckCards=processDeckCard(i);
		for(int i=0;i<deckCards.size();i++){
			//deck card [width,height]=[77,113]
			deckCards[i].x+=deckR.x0+77/2;
			deckCards[i].y=deckR.y0+113/2;
		}
	}
};
void PlayerInfo::getStr(char *str){
		char b1[1024],b2[1024];
		b1[0]=0;
		b2[0]=0;

		sprintf(b1,"hp:%d,armour:%d,curCrystal:%d,maxCrystal:%d,hit:%d",hp,armour,curCrystal,maxCrystal,hit);
		strcat(str,b1);
		sprintf(b1,",numHandCards:%d",handCards.size());
		strcat(str,b1);
		b1[0]=0;
		b2[0]=0;
		for(int i=0;i<handCards.size();i++){
			//printf("#%d ",i);handCards[i].print();printf("\n");
			handCards[i].getStr(b1);
			if(i!=0){
				strcat(b2,"|");
			}
			strcat(b2,b1);
		}
		sprintf(b1,",handCards:%s",b2);
		strcat(str,b1);
		sprintf(b1,",numDeckCards:%d",deckCards.size());
		strcat(str,b1);
		b1[0]=0;
		b2[0]=0;
		for(int i=0;i<deckCards.size();i++){
			//printf("#%d ",i);handCards[i].print();printf("\n");
			deckCards[i].getStr(b1);
			if(i!=0){
				strcat(b2,"|");
			}
			strcat(b2,b1);
		}
		sprintf(b1,",deckCards:%s",b2);
		strcat(str,b1);
	}
PlayerInfo my,other;

bool isInit=false;
void parse_init(){
	if(!isInit){
		isInit=true;
	ds.clear();
	lds.clear();
	mds.clear();
	for(int i=0;i<=10;i++){
		char buffer[100];
		sprintf(buffer,"./imgs/%d.bmp",i);
		ds.push_back(Img(buffer));
	}
	for(int i=0;i<=9;i++){
		char buffer[100];
		sprintf(buffer,"./limgs/%d.bmp",i);
		lds.push_back(Img(buffer));
	}
	for(int i=0;i<=9;i++){
		char buffer[100];
		sprintf(buffer,"./mimgs/%d.bmp",i);
		mds.push_back(Img(buffer));
	}
	/***********init the region*********/
	
		const int my_crystal_y=652;
		const int my_hp_y=584;
		const int other_crystal_y=57;		
		const int other_hp_y=182-1-1;
		/********/
		const int crystal_height=17;
		const int hp_height=22;
	Region myDeck(341,345,950,467),
	myCurCrystal(820, my_crystal_y,840, my_crystal_y+crystal_height),
	myMaxCrystal(840, my_crystal_y,861, my_crystal_y+crystal_height),
	myHP0(679,my_hp_y,707,my_hp_y+hp_height),
	myHP1(679,my_hp_y,692,my_hp_y+hp_height),
	myHP2(692,my_hp_y,707,my_hp_y+hp_height),
	myHand(418,700,829,713),
	myHit(590,596,615,621)
	;
	int offcryl=-2-13-15+4;
	int offhp=-2;
Region otherDeck(341,225,950,344),
	otherCurCrystal(820+offcryl, other_crystal_y,840+offcryl, other_crystal_y+crystal_height),
	otherMaxCrystal(840+offcryl, other_crystal_y,861+offcryl, other_crystal_y+crystal_height),
	otherHP0(679+offhp,other_hp_y,707+offhp,other_hp_y+hp_height),
	otherHP1(679+offhp,other_hp_y,692+offhp,other_hp_y+hp_height),
	otherHP2(692+offhp,other_hp_y,707+offhp,other_hp_y+hp_height),
	otherHand(418,28,829,33),
	otherHit(590,596,615,621)
	;
	my.my=true;
	other.my=false;
	my.init(myDeck,myCurCrystal,myMaxCrystal,myHP0,myHP1,myHP2,myHand,myHit);
	other.init(otherDeck,otherCurCrystal,otherMaxCrystal,otherHP0,otherHP1,otherHP2,otherHand,otherHit);
	}
/***********end init the region*********/
}


int getColorCount(const Img&img,Color color,double sim){
	Color c;
	int w,h;
	w=img.dimx();
	h=img.dimy();
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
PixelType black[]={0,0,0};
int parseGold(Img&img){
	int fx,tx;
	fx=0;
	int s=0;
	process(img);
	int w=img.dimx();
	int h=img.dimy();
	while(getRange(img,fx,tx)){
		Img d=img;//.get_crop(fx,tx,0);
		d.draw_rectangle(0,0,fx-1,h,black);
		d.draw_rectangle(tx+1,0,w,h,black);
		//showImage(d);
		int dd=getImgInt3(d);
		Trace(dd);
		//showImage(d);
		if(dd==-1){
			return -1;
		}else{
			s*=10;
			s+=dd;
		}
		fx=tx+1;
	}
	return s;
}

struct Attack{
	//Attack(int tl,int tr):l(tl),r(tr){}
	int l,r;
	void print()const{
		cout<<"("<<l-1<<","<<r-1<<")";
	}

};
typedef vector<Attack> Attacks;
double getSeglineF(int x,int lx,int rx,int ly,int ry){
	//if x belogn to (lx,rx], then return y=...
	if(lx<=x&&x<rx){
		return (double)ly+(double)(ry-ly)*(x-lx)/(rx-lx);
	}
	return 0;
}
struct MUnit{
	int hp,hit;
	bool isReady,isMock;
	MUnit(int thp,int thit,bool tisMock,bool tisReady=false):hp(thp),hit(thit),isMock(tisMock),isReady(tisReady){
	}
	MUnit& preProcess(){
		hp=abs(hp);
		hit=abs(hit);
		return *this;
	}
	bool getIsMock()const{
		return hp>0&&isMock;
	}
	bool getIsReady()const{
		_ASSERT(hp>0);
		return isReady;
	}
	double getValue()const{
		double v=0;
		if(hp<=0)return 0;
		v+=hp+hit;
		if(hp>=hit)v+=0.5;
		else v+=0.1;
		if(isMock){
			v+=0.4;//0~1
		}
		return v;
	}
	double getHeroValue()const{
		double v=0;
		v+=getSeglineF(hp,-ConstInfite,0,-ConstInfite,-ConstInfite/2)+
			getSeglineF(hp,0,10,0,15)+
			getSeglineF(hp,10,20,15,28)+
			getSeglineF(hp,20,30,28,30)+
			getSeglineF(hp,30,ConstInfite,30,30);
		return v;
	}

};

struct MUnits{
	vector<MUnit>u;
	MUnit&operator[](int i){
		return u[i];
	}
	const MUnit&operator[](int i)const{
		return u[i];
	}
	int size()const{
		return u.size();
	}
	//helper function
	bool hasMock()const{
		for(int i=0;i<u.size();i++){
			if(u[i].getIsMock())return true;
		}
		return false;
	}
	int numAlive()const{
		int num=0;
		for(int i=0;i<u.size();i++){
			if(u[i].hp>0)num++;
		}
		return num;
	}
};
struct SearchState{
	MUnits ms;
	MUnits os;
	void attack(const Attack &a){
		_ASSERT(ms[a.l].isReady);
		_ASSERT(ms[a.l].hp>0);
		_ASSERT(ms[a.l].hit>0);
		_ASSERT(os[a.r].hp>0);
		MUnit&m=ms[a.l];
		MUnit&o=os[a.r];
		m.hp-=o.hit;
		o.hp-=m.hit;
		m.isReady=false;
	}
	
};

struct SearchNode{
	SearchState s;
	//bool isOtherHasMock;
	Attack in;//-1,-1.
	SearchNode*parent;//NULL
	vector<SearchNode>childs;
	double value;
	bool isValid()const{
		//this should be check in the end, not in the mid,
		//because some other may destroy the mock.
		if(s.os.hasMock()){
			//check for if some one attack none mock.
			const SearchNode*up=this;
			while(up->parent!=NULL){
				if(!s.os[up->in.r].getIsMock()){
					return false;
				}
				up=up->parent;
			}
		}
		return true;
	}
	void calValue(){
		//notice, other has a phantom 0,100000
		//value=s.ms.numAlive()-s.os.numAlive();
		//value=-s.os.numAlive();
		//s.os.u.pop_back();//delete the phantom.
		if(!this->isValid()){value=-ConstInfite;return;}
		int i;
		const MUnits &ms=s.ms;
		const MUnits  &os=s.os;
		double mv=0;
		double ov=0;
		//hero~~~
		mv+=ms[0].getHeroValue();
		for(i=1;i<ms.size();i++){
			mv+=ms[i].getValue();
		}
		_ASSERT((os.u[os.size()-1].hit==0)&&(os.u[os.size()-1].hp>ConstInfite/2));
		//hero~~~
		ov+=os[0].getHeroValue();
		for(i=1;i<os.size()-1;i++){
			ov+=os[i].getValue();
		}
		value=mv-ov;
	}
	void generateChilds(){
		//pruning...
		if(s.ms[0].hp<=0||s.os[0].hp<=0)return;
		for(int i=in.l+1;i<s.ms.size();i++){
			if(s.ms[i].isReady){
				_ASSERT(s.ms[i].hp>0);
				_ASSERT(s.ms[i].hit>0);
				for(int j=0;j<s.os.size();j++){
					if(s.os[j].hp>0){
						//decide i attack who.
						SearchNode child;
						child.in.l=i;
						child.in.r=j;
						child.parent=this;
						child.s=s;
						child.s.attack(child.in);
						this->childs.push_back(child);
					}
				}
				break;
			}
		}
	}
};
SearchNode*SubBSearch(SearchNode &root){
	root.generateChilds();
	if(root.childs.size()==0){
		root.calValue();
		return &root;
	}else{
		SearchNode*best=SubBSearch(root.childs[0]);
		double maxValue=best->value;
		for(int i=1;i<root.childs.size();i++){
			SearchNode*node=SubBSearch(root.childs[i]);
			if(node->value>=maxValue){
				maxValue=node->value;
				best=node;
			}
		}
		return best;
	}
}

SearchNode*BSearch(SearchNode &root){
	root.generateChilds();
	if(root.childs.size()==0){
		if(!root.isValid()){
			root.value=-ConstInfite;
			return &root;
		}
		SearchNode otherRoot;
		otherRoot.in.l=-1;
		otherRoot.in.r=-1;
		otherRoot.parent=NULL;
		otherRoot.s.ms=root.s.os;
		otherRoot.s.os=root.s.ms;
		//
		vector<MUnit>&ms=otherRoot.s.ms.u;
		vector<MUnit>&os=otherRoot.s.os.u;
		ms.pop_back();//delete the phantom enemy.
		ms[0].hit=0;
		for(int i=0;i<ms.size();i++){
			if(ms[i].hp>0&&ms[i].hit>0){
				ms[i].isReady=true;
			}
		}
		os.push_back(MUnit(ConstInfite,0,false,false).preProcess());//a phantom enemy.
		root.value=-SubBSearch(otherRoot)->value;
		return &root;
	}else{
		SearchNode*best=BSearch(root.childs[0]);
		double maxValue=best->value;
		for(int i=1;i<root.childs.size();i++){
			SearchNode*node=BSearch(root.childs[i]);
			if(node->value>=maxValue){
				maxValue=node->value;
				best=node;
			}
		}
		return best;
	}
}

Attacks getActions(PlayerInfo&my,PlayerInfo&other){
	//cout<<"start search..."<<endl;
	SearchNode root;
	SearchState s;//0:hero,[numDeck+1] 0,10000.
	//
	int i;
	CardInfo c;
	vector<MUnit>&ms=s.ms.u;
	vector<MUnit>&os=s.os.u;
	ms.push_back(MUnit(my.hp,my.hit,false,my.hit>0).preProcess());
	for(i=0;i<my.deckCards.size();i++){
		CardInfo c=my.deckCards[i];
		ms.push_back(MUnit(abs(c.hp),c.hit,c.isMock,c.isReady).preProcess());
	}
	os.push_back(MUnit(other.hp,0,false,false).preProcess());
	for(i=0;i<other.deckCards.size();i++){
		CardInfo c=other.deckCards[i];
		os.push_back(MUnit(c.hp,c.hit,c.isMock,false).preProcess());
	}
	os.push_back(MUnit(ConstInfite,0,false,false).preProcess());//a phantom enemy.
	//
	root.in.l=-1;
	root.in.r=-1;
	root.parent=NULL;
	root.s=s;
	SearchNode*best=BSearch(root);
	Attacks a,b;
	while(best->parent!=NULL){
		Attack in=best->in;
	//	cout<<"Action:";in.print();
	//	cout<<endl;
		if(s.os[in.r].isMock){
			a.push_back(best->in);
		}else{
			b.push_back(best->in);
		}
		best=best->parent;
	}
	reverse(a.begin(),a.end());
	reverse(b.begin(),b.end());
	for(int i=0;i<b.size();i++){
		a.push_back(b[i]);
	}
//	cout<<"Actions";
//	printArr(a);

	return a;
}

struct CardBuff{
	enum Action{ACTION_ADD,ACTION_DEL,ACTION_SET};
	enum Type{TYPE_HIT,TYPE_HP,TYPE_CRYSTAL,TYPE_CARD};
	Action action;//0:add 1:del 2:set 3:silence 4:selectBuff(type=leftBuffIndex,num=rightBuffIndex} 5:returnToHand
	Type type;//0:hit 1:hp 2:crystal 3:card 4:mock 5:armour 6:secret
	int num;
#define TARGET_OTHER_CARD (1<<0)
#define TARGET_OTHER_HERO (1<<1)
#define TARGET_OTHER (TARGET_OTHER_CARD|TARGET_OTHER_HERO)
#define TARGET_MY_CARD (1<<2)
#define TARGET_MY_HERO (1<<3)
#define TARGET_BETWEEN (1<<4) 
#define TARGET_MY (TARGET_MY_CARD|TARGET_MY_HERO)
	int target;//
};
struct HandCard{
	int hit,hp,cost;
	int state;
#define STATE_MOCK (1<<0)
#define STATE_SHIELD (1<<2)
#define STATE_RUSH (1<<3)
#define STATE_WIND (1<<4)
	int value;//decide which card is better.
	int priority;//decide this card should be placed first?
	int numBuffs;//decide how much buff.
	vector<CardBuff>cbs;
};
void clipHandCard(Img&img){
	showImage(img);
}
HandCard parseHandCard(const char *file){
	HandCard c;
	Img img(file);
	clipHandCard(img);
	return c;
}

void mainProcess(const char *file){	
Img img(file);
my.parse(img);
//my.print();
other.parse(img);
//other.print();
//getActions(my,other);
}
int main(){
#define WHICH 5
#if WHICH==0
	mainProcess("a.bmp");
#elif WHICH==5
	parse_init();
	for(int i=0;i<=20;i++){
		char buffer[100];
		sprintf(buffer,"testAI\\a%d.bmp",i);
		if(isFileExist(buffer)){
			printf("***********testing file:%s***************\n",buffer);
			mainProcess(buffer);
			cout<<endl;
		}
	}
#elif WHICH==1
	for(int i=0;i<=20;i++){
		char buffer[100];
		sprintf(buffer,"parseDeckCards\\m%d.bmp",i);
		if(isFileExist(buffer)){
			printf("testing file:%s  \n",buffer);
			mainProcess(buffer);
		}
	}
#elif WHICH==2
	for(int i=0;i<=20;i++){
		char buffer[100];
		sprintf(buffer,"parseHandCard\\hc%d.bmp",i);
		if(isFileExist(buffer)){
			Trace(buffer);
			Trace(getColorCount(Img(buffer),Color(0x5bff3b),0.02));
		}
	}
#elif WHICH==3
	parse_init();
	char retStr[1024];
	retStr[0]=0;
	mainProcess("c.bmp");
	char buffer[1024];
	buffer[0]=0;
	my.getStr(retStr);
	printf("my:%s\n",retStr);

	other.getStr(buffer);
	strcat(retStr,"!");
	strcat(retStr,buffer);
	printf("other:%s\n length:%d\n",retStr,strlen(retStr));


#endif
	
	system("pause");
	return 0;
}


int testParseMyHP(){
	parse_init();
	vector<DInfo>dis;
	for(int i=0;i<=20;i++){
		char buffer[100];
		sprintf(buffer,"a%d.bmp",i);
		if(isFileExist(buffer)){
			ImgParser imgp(buffer);
			int hp=imgp.getHp();
			Trace(hp);
			DInfo d;
			strcpy(d.file,buffer);
			d.hp=hp;
			dis.push_back(d);
		}
	}
	for(int i=0;i<dis.size();i++){
		DInfo d=dis[i];
		printf("file:%s hp:%d \n",d.file,d.hp);
	}
	system("pause");
	return 0;
}
void testParseCrystal(){
	parse_init();
	vector<DInfo>dis;
	for(int i=0;i<=20;i++){
		char buffer[100];
		sprintf(buffer,"a%d.bmp",i);
		if(isFileExist(buffer)){
			ImgParser imgp(buffer);
			int c1=imgp.getCurCrystal();
			Trace(c1);
			int c2=imgp.getMaxCrystal();
			Trace(c2);
			DInfo d;
			strcpy(d.file,buffer);
			d.c1=c1;
			d.c2=c2;
			dis.push_back(d);
		}
		//Trace(ip.getMaxCrystal());
		//ds.push_back(Img(buffer));
	}
	for(int i=0;i<dis.size();i++){
		DInfo d=dis[i];
		printf("file:%s c1:%d c2:%d\n",d.file,d.c1,d.c2);
	}
}
int test1() {
	parse_init();
	Img image("a.bmp");
	//process(image);
	//return 0;
	int w,h;
	w=image.dimx();
	h=image.dimy();
	//Trace(w);
	//Trace(h);
	/*for(int i=0;i<w;i++){
		for(int j=0;j<h;j++){
			for(int k=0;k<3;k++){
				image(i,j,0,k)=image(i,j,0,k)/2;
			}
		}
	}*/
	Img mycardImg,mydeckImg,otherdeckImg,mycstlImg,mycstlImg1,othercstlImg,myheroImg,otherhero,endroundImg;
	mycardImg=image.get_crop(397,578,836,679,0);
	mydeckImg=image.get_crop(266,318,1034,435,0);
	otherdeckImg=image.get_crop(272,181,1019,307,0);
	mycstlImg=image.get_crop(821, 652,841, 669,0);
	mycstlImg1=image.get_crop(841, 652,862, 669,0);
	othercstlImg=image.get_crop(789,32,832,50,0);
	endroundImg=image.get_crop(966,286, 1073,337,0);
	myheroImg=image.get_crop(577,437,826,587 ,0);
	otherhero=image.get_crop(577,59 ,805,197,0);
	

	process(mycstlImg);
	process(mycstlImg1);
	Trace(getImgInt(mycstlImg));
	Trace(getImgInt(mycstlImg1));
	/*process(othercstlImg);
	process(mycstlImg);

	Trace(getImgInt(mycstlImg));
Trace(getImgInt(othercstlImg));

	

	process(mycardImg);*/
	//showImage(mycardImg);

	//process(myheroImg);
	//showImage(myheroImg);
	/*
	showImage(mycardImg);
	showImage(mydeckImg);
	showImage(otherdeckImg);
	showImage(mycstlImg);
	showImage(othercstlImg);
	showImage(myheroImg);
	showImage(otherhero);
	showImage(endroundImg);

	image.draw_circle(100,100,100,red,0,1);
	showImage(image);
	*/
	//main_disp.show();
	cout<<"wait";
	system("pause");
	return 0;
}

/*
int main() {
CImg<unsigned char> image("lena.jpg"), visu(500,400,1,3,0);
const unsigned char red[] = { 255,0,0 }, green[] = { 0,255,0 }, blue[] = { 0,0,255 };
image.blur(2.5);
CImgDisplay main_disp(image,"Click a point"), draw_disp(visu,"Intensity profile");
while (!main_disp.is_closed() && !draw_disp.is_closed()) {
main_disp.wait();
if (main_disp.button() && main_disp.mouse_y()>=0) {
const int y = main_disp.mouse_y();
visu.fill(0).draw_graph(image.get_crop(0,y,0,0,image.width()-1,y,0,0),red,1,1,0,255,0);
visu.draw_graph(image.get_crop(0,y,0,1,image.width()-1,y,0,1),green,1,1,0,255,0);
visu.draw_graph(image.get_crop(0,y,0,2,image.width()-1,y,0,2),blue,1,1,0,255,0).display(draw_disp);
}
}
return 0;
}
*/
