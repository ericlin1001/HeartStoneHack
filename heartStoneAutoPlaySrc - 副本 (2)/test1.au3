#include <Debug.au3>
#include <ImageSearch.au3>
#include <ParseMainCard.au3>
#include <ScreenCapture.au3>
;#include <utils.au3>
	Local $x,$y;
_DebugSetup("abc",true,2)
;_ScreenCapture_Capture("a.bmp");
_ScreenCapture_Capture("gold.bmp",1094,688,1199,707);
;trace(parseInt("gold.bmp"));

;getMainCardInfo("a.bmp")
;               0       1           2      3      4        5          6      7       8
Local $heros[]=["Druid","Hunter","Mage","Paladin","Priest","Rogue","Shaman","Warlock","Warrior"]
Local $hero=$heros[5];
Func getMyHero()
	For $i in $heros
		if _ImageSearchArea("simgs\hero_"&$i&".bmp",1,628,515,674,570, $x,  $y, 10)<>"0" Then
			Return $i;
		EndIf
	Next
	;_ScreenCapture_Capture("simgs\hero_"&$hero&".bmp",628,515,674,570,False);
EndFunc

_ScreenCapture_Capture("simgs\hero_"&$hero&".bmp",628,515,674,570,False);
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
Exit
;Local $hwnd=WinGetHandle("[CLASS:UnityWndClass]");heartStone.
Local $hwnd=WinGetHandle("[CLASS:MSPaintApp]");heartStone.
If @error Then
	trace("Can't find");
EndIf
;WinMove($hwnd,"",0,0);
trace("hwnd:"&$hwnd)

trace("try register");


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
