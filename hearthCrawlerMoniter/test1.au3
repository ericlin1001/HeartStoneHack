#include <Debug.au3>
#include <ImageSearch.au3>
#include <ParseMainCard.au3>
#include <ScreenCapture.au3>
#include <basicFuns.au3>
#include <WinAPISys.au3>
main()
Func main()
$dllName="ParseCardsDll.dll"
$funcName="_testGetInt@0"

	p(DllCall($dllName,"int",$funcName));
	p(DllCall($dllName,"int",$funcName));

	$dll=DllOpen($dllName);
	p(DllCall($dll,"int",$funcName));
	p(DllCall($dll,"int",$funcName));
	DllClose($dll);

	p(DllCall($dllName,"int",$funcName));
	p(DllCall($dllName,"int",$funcName));

	$dll=DllOpen($dllName);
	p(DllCall($dllName,"int",$funcName));
	p(DllCall($dllName,"int",$funcName));
	DllClose($dll);
	exit;
EndFunc
Func p($r)
	trace("r:"&$r[0]);
EndFunc

Func testGetInt()
Local $ret=DllCall("PHashDll.dll","str","_getCardInfo@4");
if  (Not @error) And IsArray($ret) Then
	Local $r=$ret[0];
	$retArr=StringSplit($r,"|");
	$ready=$retArr[2];retArr[0]=length, retArr[1]=(xxx,xxx,xxx)
	$cost=$retArr[3];
	$hp=$retArr[4];
	$hit=$retArr[5];
	;trace("count:"&$retArr[6])
	return True
EndIf
return False;
EndFunc

Func getNextFile($prefix,$posfix)
	Local $i=0
	While FileExists($prefix&$i&$posfix)
		$i+=1
	WEnd
	return $prefix&$i&$posfix
EndFunc

;#include <utils.au3>

Local $hwnd=WinGetHandle("[CLASS:UnityWndClass]");heartStone.
;Local $hwnd=WinGetHandle("[CLASS:HH Parent]");AutoIt Help

	Local $x,$y;
_DebugSetup("trace",true,2)
$myHwnd=_WinAPI_GetActiveWindow()
$pos=WinGetPos($hwnd)
WinMove($hwnd,"",0,0);
WinActivate($hwnd)

_ScreenCapture_Capture(getNextFile("..\TestAutoit\TestAutoit\testAI\a",".bmp"));
Sleep(200);
WinActivate($myHwnd);
WinMove($hwnd,"",$pos[0],$pos[1]);
_ScreenCapture_Capture("gold.bmp",1094,688,1199,707);
Exit
;trace(parseInt("gold.bmp"));

;getMainCardInfo("a.bmp")
;               0       1           2      3      4        5          6      7       8
Global $heros[]=["Druid","Hunter","Mage","Paladin","Priest","Rogue","Shaman","Warlock","Warrior"]
Global $heroHashs[9];
Func getInstMyHero1()
	For $i in $heros
		if _ImageSearchArea("simgs\hero_"&$i&".bmp",1,628,515,674,570, $x,  $y, 10)<>"0" Then
			Return $i;
		EndIf
	Next
	return "unknow"
	;_ScreenCapture_Capture("simgs\hero_"&$hero&".bmp",628,515,674,570,False);
EndFunc
Func getInstMyHero()
	Local $x,$y;
	Local $diffs[9];
	_ScreenCapture_Capture("simgs\hero_cur.bmp",628,515,674,570,False);
	Local $cur=getHash("simgs\hero_cur.bmp");
	$min=$heros[0];
	For $i in $heros
		;$heroHashs[$i]=getHash("simgs\hero_"&$i&".bmp");
		If getBinDiff($heroHashs[$i],$cur)<10 Then
			return $i;
		EndIf
	Next
	return "unknow"
EndFunc

Func getMyHero()
	Local $count=0;
	Local $hero;
	While $count<=5
		$hero=getInstMyHero()
		If $hero<>"unknow" Then
			Return $hero
		EndIf
		$count+=1
		Sleep(500)
	WEnd
	Return $hero
EndFunc
;Local $hero=$heros[8];
;_ScreenCapture_Capture("simgs\hero_"&$hero&".bmp",628,515,674,570,False);
trace("hero:"&getMyHero());
;Local $x=-1,$y=-1;
if _ImageSearchArea("simgs\c_weapon.bmp",1,628,515,674,570, $x,  $y, 10)=="0" Then
	trace("fails");
else
	trace("OK!");
EndIf
if _ImageSearch("simgs\c_weapon.bmp",1, $x,  $y, 10)=="0" Then
	trace("fails");
else
	trace("OK!");
EndIf
trace("abc here"&$x&","&$y);
trace("abc here");




;Local $hwnd=WinGetHandle("[CLASS:MSPaintApp]");heartStone.
If @error Then
	trace("Can't find");
EndIf
trace("isHung:"&IsHungAppWindow($hwnd));

;WinMove($hwnd,"",0,0);
trace("hwnd:"&$hwnd)

trace("try register");
Exit

Global $ret;
Global $dm = ObjCreate("dm.dmsoft")
$need_ver = "3.1233"


$ws=ObjCreate("Wscript.Shell")
$ws.run("regsvr32 J:\Users\Eric\Documents\myDocument\大三下\HeartStoneHack\heartStoneAutoPlaySrc\dm.dll /s")
Sleep(1500)

$dm = ObjCreate("dm.dmsoft")
$dm_ret = $dm.Reg("abcdefg","")
if $dm_ret <> 1 then
    trace ("reg fails.")
EndIf

$ver = $dm.Ver()

trace("try register");

if $ver <> $need_ver then
trace("reg fail1");
EndIf

;$dm.SetPath("J:\dmdir")
WinActivate($hwnd);
$ret=$dm.BindWindowEx($hwnd,"gdi", _
"dx.mouse.position.lock.api|dx.mouse.position.lock.message|dx.mouse.focus.input.api|dx.mouse.focus.input.message|dx.mouse.clip.lock.api|dx.mouse.input.lock.api|dx.mouse.state.api|dx.mouse.state.message|dx.mouse.api" , "windows", 0,0)


If $ret==0 Then
	trace("Fail dm");
	trace("lastError:"&$dm.GetLastError())
EndIf

;$ret=$dm.EnableBind(0)
If $ret==0 Then
	trace("Fail dm");
	trace("lastError:"&$dm.GetLastError())
EndIf
;$ret=$dm.DmGuard(1,"np2")
trace("$dm.EnableBind:"&$ret)
testR()
trace("ret:"&$ret)
$ret=$dm.MoveWindow($hwnd,0,0);
trace("isBind:"&$ret)
$ret=$dm.MoveTo(647, 235)
trace("ret:"&$ret)
$ret=$dm.LeftClick();
trace("ret:"&$ret)

trace($hwnd)
mclick(647, 235)
	For $j=0 to 700 Step 200
		For $i=0 to 1024 Step 200
			trace("(x,y)=("&$i&","&$j&")")
		mclick($i,$j)
	Next
Next
Local $y=200
Local $x=600
$WM_MOUSEMOVE =0x0200
$WM_LBUTTONDOWN                 = 0x0201
$WM_LBUTTONUP             =       0x0202
$ret=_SendMessage($hwnd,$WM_MOUSEMOVE,BitOR (BitShift ($y,-16),$x));
If @error  Then
	trace("send message fail!")
EndIf

trace("s ret:"&$ret)
$ret=_SendMessage($hwnd,$WM_LBUTTONDOWN);
trace("s ret:"&$ret)
$ret=_SendMessage($hwnd,$WM_LBUTTONUP);
trace("s ret:"&$ret)


mclick(600,200)
$dm.UnBindWindow()
Exit
Func mclick($x,$y)
;ControlClick($hwnd,"",0,"left",1,$x,$y);
;ControlMove($hwnd,"",0,$x,$y)
;ControlClick(
$ret=$dm.MoveTo($x,$y)
Sleep(20)
$ret=$dm.LeftClick();

If $ret==0 Then
	trace("left click fails")
	EndIf
Sleep(20)

$ret=$dm.LeftClick();
$ret=$dm.LeftDown()
trace("left down "&$ret)
Sleep(20)
$ret=$dm.LeftUp()
trace("left up "&$ret)
Sleep(20)
EndFunc

Func trace($m)
	_DebugSetup("a");
	_DebugOut(">"&$m)
EndFunc
Func trace1($m)
	_DebugOut(">"&$m)
EndFunc
Func isCardReady($f)
Local $ready, $cost, $hp, $hit,$all
getCardInfo($f,$ready, $cost, $hp, $hit)
if $ready==0 Then
Return False
EndIf
return True
EndFunc

Func testR()
	If $ret==0 Then
		trace("Error:lastError:"&$dm.GetLastError())
	EndIf
EndFunc
;trace1(isCardReady("a.bmp"))
;trace1(isCardReady("b.bmp"))
trace1("abcc");
	;trace("search:"&_ImageSearch("a.bmp",0,$x,$y,20))
