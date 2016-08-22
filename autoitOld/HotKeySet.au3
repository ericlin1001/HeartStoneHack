#include <MsgBoxConstants.au3>
#include<utils.au3>
; Press Esc to terminate script, Pause/Break to "pause"

Global $fPaused = False

HotKeySet("{PAUSE}", "TogglePause")
HotKeySet("{ESC}", "Terminate")
HotKeySet("+!d", "ShowMessage") ; Shift-Alt-d
setupDebug()
While 1
	Sleep(100)
	trace("not end...");
WEnd

Func TogglePause()
	$fPaused = Not $fPaused
	While $fPaused
		Sleep(100)
		ToolTip('Script is "Paused"', 0, 0)
	WEnd
	ToolTip("")
EndFunc   ;==>TogglePause

Func Terminate()
	Exit
EndFunc   ;==>Terminate

Func ShowMessage()
	MsgBox($MB_SYSTEMMODAL, "", "This is a message.")
EndFunc   ;==>ShowMessage
