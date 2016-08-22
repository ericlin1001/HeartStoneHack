#cs ----------------------------------------------------------------------------

 AutoIt Version: 3.3.10.2
 Author:         myName

 Script Function:
	Template AutoIt script.

#ce ----------------------------------------------------------------------------

; Script Start - Add your code below here
#include <ScreenCapture.au3>
MsgBox(0,"Can't find 炉石传说","Can't find 炉石传说");
test()
Func test()
	Local $hwnd=WinGetHandle("炉石传说")
	If $hwnd == 0 Then
		MsgBox(0,"Can't find 炉石传说","Can't find 炉石传说");
	Else
		MsgBox(0,"Find it:"& $hwnd,"no text");
	EndIf
	_ScreenCapture_CaptureWnd("J:\Users\Eric\Desktop\autoit\a.bmp",$hwnd);
EndFunc

