#include <Debug.au3>
#include <ImageSearch.au3>
#include <ParseMainCard.au3>
#include <ScreenCapture.au3>
;#include <utils.au3>
	Local $x,$y;
_DebugSetup()
;_ScreenCapture_Capture("a.bmp");
getMainCardInfo("a.bmp")

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
;trace1(isCardReady("a.bmp"))
;trace1(isCardReady("b.bmp"))
trace1("abcc");
	;trace("search:"&_ImageSearch("a.bmp",0,$x,$y,20))
