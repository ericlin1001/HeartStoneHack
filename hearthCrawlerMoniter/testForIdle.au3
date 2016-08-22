#include <Debug.au3>
#include <MsgBoxConstants.au3>
Global $mousePos = MouseGetPos()
#include <WinAPISys.au3>
Global $startProcessName="heartStonePlayNew.exe"
Global $timeOut=120
Global $workingDir="J:\Users\Eric\Documents\myDocument\大三下\HeartStoneHack\heartStoneAutoPlaySrc"
Func main()
	readSetting()
	While True
		If ProcessExists($startProcessName)>0 Then
			Sleep(1000);
		Else
			If _WinAPI_GetIdleTime()>$timeOut*1000 Then
				Run($startProcessName,$workingDir)
			Else
				Sleep(1000);
			EndIf
		EndIf
	WEnd
EndFunc

main()

Func readSetting()
	$iniFile="testForIdle.ini"
	$section="General"
	$startProcessName=IniRead($iniFile,$section,"startProcessName","none")
	$timeOut=Int(IniRead($iniFile,$section,"timeOut",100))
	$workingDir=IniRead($iniFile,$section,"workingDir","none")
	;trace("$startProcessName"&$startProcessName)
	;trace("$timeOut"&$timeOut)
	;trace("$workingDir"&$workingDir)
EndFunc

Func isDiffMousePos()
	Local $pos = MouseGetPos()
	If $pos[0]==$mousePos[0] And $pos[1]==$mousePos[1] Then
		;not changed.
		Return False
	Else
		$mousePos=$pos
		Return True
	EndIf
EndFunc
Func isIdle($testSeconds)
	_WinAPI_GetIdleTime()
EndFunc

Func isMouseIdle($testSeconds)
	;mouse not change for 10 minutes, means idle.
	Const $notChangeTime=$testSeconds*1000
	Const $testInterval=200;
	Local $waitTime=0;
	While $waitTime<$notChangeTime
		If isDiffMousePos() Then
			Return False
		EndIf
		$waitTime+=$testInterval;
		Sleep($testInterval);
	WEnd
	Return True
EndFunc

Func trace($m)
	_DebugSetup("a");
	_DebugOut($m);
EndFunc





