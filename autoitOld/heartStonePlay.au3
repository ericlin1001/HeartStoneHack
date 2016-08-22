#include-once

Global $state;
Global $hwnd=-1,$phwnd;
Global $states[]=["arenaMode0","battleMode","buildingCard","buyingCard","checkForTasks","mainMenu","openCardPack","playingCard","praticeMode","searchForOppoent","selectCard"];
Global $defaultXY[]=[1100,500];
Global $isEnd=False
Global $heroPoss[3][3][2];//[row][col][xy]
Global $computerHeroPoss[9][2];
Global $selectCardPoss[2][4][2];
Global $clientWidth,$clientHeight;
Global Enum $PP_MY_HERO,$PP_OTHER_HERO,$PP_MY_SKILL,$PP_OTHER_MID
Global $battleNetProgramPath="D:\Program Files\Battle.net\Battle.net Launcher.exe"

#include <MsgBoxConstants.au3>
#include <ScreenCapture.au3>
#include <Debug.au3>
#include <ImageSearch.au3>
#include <ParseMainCard.au3>
#include <utils.au3>
#include <PHash.au3>
#include <aiplay.au3>


;*********************control of script *******************
; Press Esc to terminate script, Pause/Break to "pause"
Global $fPaused = False
HotKeySet("{F10}", "TogglePause")
HotKeySet("{F11}", "Terminate")
HotKeySet("{F9}", "ShowMessage") ; Shift-Alt-d

setupDebug()
ShowMessage()
While 1
	Sleep(100)
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
	startApp()
EndFunc   ;==>ShowMessage

;**************************Main function******************
Func startApp()
	$isEnd=False
	readSetting()
	startGameProgram()
	initScript()
	initHwnd()
	;setupDebug()
	;updateState();
	;checkForImg()
	mainLoop()
EndFunc

Func readSetting()
		;FileRead("settting.init",
EndFunc

;************start the game program*********
Func isProgramExist($p)
	WinGetHandle($p);
	Return  Not @error
EndFunc

Func startGameProgram()
	$endWhile=False
	While Not $endWhile
		If isProgramExist("战网") Then
			$phwnd=WinGetHandle("战网")
			WinSetState($phwnd,"",@SW_RESTORE)
			WinActivate($phwnd)
			WinMove($phwnd,"",0,0);
			If  isProgramExist("炉石传说") Then
				trace("heartStone had been opened, start play.")
				$hwnd=WinGetHandle("炉石传说")
				$endWhile=True
			Else
				trace("opening heartStone game program.")
				mclick(49,321)
				Sleep(200)
				;mclick(221,471)
				clickPics("button_enterGame.bmp")
				Sleep(400)
				Sleep(1300)
			EndIf
		Else
			trace("opening battlen net.")

			Run($battleNetProgramPath)
			Sleep(2400)
		EndIf
	WEnd
EndFunc

;************end start****************

Func initScript()

	For $i=0 to 2
		For $j=0 to 2
			$xx=340+150*$j
			$yy=218+140*$i
			$heroPoss[$i][$j][0]=$xx;
			$heroPoss[$i][$j][1]=$yy;
		Next
	Next

	$xx=928
	for $i=0 to 8
		$yy=131+42*$i
		$computerHeroPoss[$i][0]=$xx;
		$computerHeroPoss[$i][1]=$yy;
	Next

	for $i=0 to 2
		$selectCardPoss[0][$i][0]=437+214*$i
		$selectCardPoss[0][$i][1]=340
	Next
	for $i=0 to 3
		$selectCardPoss[1][$i][0]=407+162*$i
		$selectCardPoss[1][$i][1]=340
	Next

EndFunc
;***************play game******
Func restMouse()
	MouseMove($defaultXY[0],$defaultXY[1]);
EndFunc

Func mclick($x,$y)
	MouseClick("left",$x,$y,1,5)
	Sleep(50)
EndFunc

Func clickPP($type)
	Switch($type)
		case $PP_MY_HERO
			mclick(645,533)
		case $PP_OTHER_HERO
			mclick(649,150)
		case $PP_MY_SKILL
			mclick(759,545)
		case $PP_OTHER_MID
			mclick(618,279); mide of other deck card.
	EndSwitch
EndFunc

Func playMonkey()
	trace("playMonkey");
	For $i=1 to 20
		mclick(Random(1,$clientWidth),Random(1,$clientHeight))
		Sleep(50)
	Next
EndFunc

Func selectBattleSubMode($type)
	If $type==0 Then
		trace("select relax mode");
		mclick(857,143)
	Else
		trace("select competive mode");
		mclick(989,143)
	EndIf
EndFunc



Func selectMyHero($which=0)
	$r=Mod($which,3)
	$c=Int($which/3)
	mclick($heroPoss[$r][$c][0],$heroPoss[$r][$c][1])
	trace("select my hero");
EndFunc

Func selectComputerHero($which=0)
	trace("selectComputerHero ");
	mclick($computerHeroPoss[$which][0],$computerHeroPoss[$which][1])
EndFunc

Func buttonReturn()
	mclick(1046,660)
EndFunc

Func giveUpGame()
	buttonOption();
	buttonGiveUp();
	mmclick($defaultXY)
EndFunc


Func buttonOption()
	mclick(1260,696)
EndFunc
Func buttonGiveUp()
	clickPics("button_giveup.bmp|button_giveup1.bmp",1)
EndFunc


Func buttonEnter()
	mclick(920,585)
EndFunc


Func enterMode($type)
	Switch $type
		case 0
			trace("enter battleMode");
			mclick(648,232)
		case 1
			mclick(648,282)
		case 2
			mclick(648,330)
		case Else
			trace("Unknow mode...")
			trace("enter battleMode");
			enterMode(0)
		EndSwitch
EndFunc



Func clickPics($img,$timeout=0)
	Local $x=-1,$y=-1;
	$timeout*=1000;
	$waitTime=0;
	Local $isFound=False
	Local $imgs=StringSplit($img,"|");
	While $waitTime<=$timeout
		For $i=1 to $imgs[0]
			Local $ret=_ImageSearch($imgs[$i],1,$x,$y,20);
			If $ret=1 Then
				;found that pic.
				mclick($x,$y)
				Return True
			EndIf
		Next
		Sleep(100);
		$waitTime+=200;
	WEnd
	Return False

EndFunc

Func selectCard()
	Local $isFirst=True
	If $isFirst Then
		For $i=0 to 2
			mclick($selectCardPoss[0][$i][0],$selectCardPoss[0][$i][1])
		Next
	Else
		For $i=0 to 3
			mclick($selectCardPoss[1][$i][0],$selectCardPoss[1][$i][1])
		Next
	EndIf
	mclick(648,567)
EndFunc
Func endRound()
	mclick(1026,329)
	restMouse();
EndFunc

Func getInstPlayCardState()
	;clickPics("p_state_myTurnEnd.bmp")
	PixelSearch(1014,322,1031,328,0x04BF29,50);search for my round end.
	If Not @error Then ;end my round.
		endRound()
		Sleep(200)
	EndIf
	;************
	PixelSearch(1014,322,1031,328,0x706562,50);search for other turn
	If @error Then
		return "myTurn"
	Else
		Return "otherTurn"
	EndIf
	If hasPics("p_state_myTurn.bmp|p_state_myTurn1.bmp") Then
		Return "myTurn"
	EndIf
	If hasPics("p_state_otherTurn.bmp|p_state_otherTurn1.bmp") Then
		Return "otherTurn"
	EndIf
	Return "unknow"
EndFunc

Func getPlayCardState()
	Local $s1=getInstPlayCardState()
	Local $s2=getInstPlayCardState()
	Local $timeout=5
	While $timeout>0 And $s1<>$s2
		$s1=$s2
		$s2=getInstPlayCardState()
		$timeout-=1
		Sleep(100)
	WEnd
	return $s2
EndFunc
Func updateCurPlayerStatus()
captureAll("all.bmp");
			getMainCardInfo("all.bmp");

		EndFunc

Func playCard()
	;trace("This use AI to play card!!!")
	$s=getPlayCardState();
	;trace("p_state:"&$s);
	Switch $s
		case "myTurn"
			updateCurPlayerStatus()
			AIPlayCard()
			endRound()
		case "otherTurn"
			trace("waiting for other play...")
			Sleep(500)
		case Else
			trace("unknow turn...??")
	EndSwitch

EndFunc



Func printCards($cards)
	$str="[cost:"&$cards[0]&",hp/hit:"&$cards[1]&"/"&$cards[2]&",("&$cards[3]&","&$cards[4]&",isMock:"&$cards[5]&"]";
	trace($str)
EndFunc



;
;,
Func isOtherHashMock(ByRef $x,ByRef $y)
	$otherNumDeckCard=$otherPlayerStatus[$PS_NUM_DECK_CARDS];
	$hasMock=False;
	;$CI_IS_MOCK,$CI_IS_READY
	For $j=0 to $otherNumDeckCard-1
		;=[$j]
		Local $othercard[7];
		;$mycard=$myDeckCards[$i]
		copyArr($othercard,$otherDeckCards,$j,7)
		if $othercard[$CI_IS_MOCK] Then
			$x=$othercard[$CI_X]
			$y=$othercard[$CI_Y]
		return True
		EndIf
	Next
	return False
EndFunc


Func copyArr(ByRef $dest,$src,$w,$size)
for $i=0 to $size-1
$dest[$i]=$src[$w][$i]
next
EndFunc



Func mmclick($xy)
	mclick($xy[0],$xy[1])
EndFunc

Func clickIfReturn()
	clickPics("button_return.bmp|button_return1.bmp|button_return2.bmp|button_return3.bmp|button_return4.bmp|button_return5.bmp")
	restMouse()
EndFunc

;************end play game*******

;Global $states[]=["arenaMode0","battleMode","buildingCard","buyingCard","checkForTasks","mainMenu","openCardPack","playingCard","praticeMode","searchForOppoent","selectCard"];
Func mainLoop()
	Local $lastState="??";
	Local $unknowCount=0;
	While 1
		$state=getState();
		If $lastState<>$state Then
			trace("change to state:"&$state)
		EndIf
		$lastState=$state
		If $state=="unknow" Then
			$unknowCount+=1
			If $unknowCount>3 Then
				$state="playingCard"
				$unknowCount=10
			EndIf
		Else
			$unknowCount=0;
		EndIf
		appendState("state:"&$state)
		Switch $state
			case "mainMenu"
			enterMode(0)
			;************
		case "arenaMode0"
			clickIfReturn()
		Case "battleMode"
			;clickIfReturn()
			If Random(0,100,1)<60 Then
				selectMyHero(8);
			Else
				selectMyHero(Random(0,8,1));
			EndIf
				selectBattleSubMode(Random(0,1,1))
				buttonEnter()
			case "praticeMode"
				trace("praticeMode")
				clickIfReturn()
				selectMyHero(Random(0,8,1));
				buttonEnter()
				selectComputerHero(4)
				buttonEnter()
			;************
			case "searchForOppoent"
				trace("searchForOppoent")
			;******
			case "buildingCard"
				trace("buildingCard")
				clickIfReturn()
			case "buyingCard"
				trace("buyingCard")
			case "checkForTasks"
				trace("checkForTasks")
			case "openCardPack"
				trace("openCardPack")

			;***********main play game....*****
			case "selectCard"
				trace("selectCard")
				selectCard()
			case "playingCard"
				trace("playingCard")
				playCard()
				;giveUpGame()
			;******
			Case "unknow"
				trace("unknow state,play monkey");
				playMonkey()
			Case Else
				trace("Not capture all state in switch list!");
		EndSwitch
		Sleep(5)
	WEnd
	trace("exiting....");
EndFunc

Func isPlayingCard()
	return hasPics("state_playingCard1.bmp|state_playingCard2.bmp|state_playingCard3.bmp")
EndFunc


Func getState($doClick=True,$timeout=1)
	$timeout*=1000
	$waitTime=0
	While $waitTime<=$timeout
		Local $s=getInstState()
		If $s<>"unknow" Then
			Return $s
		EndIf
		If $doClick Then
			MouseClick("left",$defaultXY[0],$defaultXY[1]);
		EndIf
		Sleep(50);
		$waitTime+=300;
	WEnd
	Return "unknow"
EndFunc

Func getInstState()
	If isPlayingCard() Then
		Return "playingCard"
	EndIf
	For $i In $states
		$p="state_"&$i&".bmp";
		;trace($i);
		if hasPic($p) Then
			return $i;
		EndIf
	Next
	return "unknow"
EndFunc

Func hasPics($img)
	Local $x,$y;
	Local $imgs=StringSplit($img,"|");
	For $i=1 to $imgs[0]
		Local $ret=_ImageSearch($imgs[$i],0,$x,$y,20);
		If $ret=1 Then
			Return True
		EndIf
	Next
	return False
EndFunc

Func hasPic($img)
	Local $x,$y;
	Local $s=_ImageSearch($img,0,$x,$y,30);
	If $s = 1 Then
		return True
	Else
		return False
	EndIf
EndFunc

Func del()
While True
		trace(getState(False))
		Sleep(200)
	WEnd
EndFunc

Func checkForImg()
del()
	Local $x=0,$y=0;
	;trace("start search")
	;Local $s=_ImageSearch('state_battleMode.bmp',0,$x,$y,0);
	Local $s=_ImageSearch('b.bmp',0,$x,$y,10);
	;trace("end search")
	trace("(x,y)=("& $x & "," & $y & ")");
	If $s = 1 Then
		trace("OK!")
		MouseMove($x,$y)
	Else
		trace("fails!")
	EndIf
EndFunc


Func updateState()
	$state="battling"
	trace("state:"&$state)
EndFunc


Func captureAll($f)
	_ScreenCapture_CaptureWnd($f,$hwnd);
EndFunc

Func grabHandCardChanged()
	DllCall
	for $i=1 to 12
		;Beep(1000,300);
		trace("beep"&$i);
		Sleep(800);
		_ScreenCapture_CaptureWnd("h"&$i&".bmp",$hwnd,386,452,870,509);
	Next
EndFunc

Func test()
	_ScreenCapture_CaptureWnd("a.bmp",$hwnd);
	;
;grabHandCardChanged()
;captureHandCard()
	MouseClick("left",200,200);
EndFunc

Func isCardReady($f)
	Local $ready, $cost, $hp, $hit,$all
getCardInfo($f,$ready, $cost, $hp, $hit)
if $ready==0 Then
Return False
EndIf
return True
EndFunc

Func captureHandCard()
;x:419->817,y:677,
;region:386,452,870,509
Const $fromX=419
Const $toX=830
Const $stepX=20
const $thred=3
Const $y=677
Local $nextImgI=0
Local $lastHash=0;
Local $curHash=0;
Local $startHash=0;
Const $offX=-100
;capture the actual card:region 520,358,802,702
;minwidth:302, y0=358,y1=702, offx=-60
;***********get start hash******
restMouse();
_ScreenCapture_CaptureWnd("tmp.bmp",$hwnd,386,512,870,890,False);
$startHash=getHash("tmp.bmp")
$lastHash=$startHash;
;**************
MouseMove($fromX,$y,1)
For $x=($fromX+$stepX) to $toX Step $stepX
$file="h"&$nextImgI&".bmp"
Sleep(80)
_ScreenCapture_CaptureWnd($file,$hwnd,386,512,870,890,False);
MouseMove($x,$y,1)
$curHash=getHash($file)
if getBinDiff($lastHash,$curHash)>$thred Then
	;obviouse change of screen.
	$lastHash=$curHash
	$nextImgI+=1;
	Local $lastX=$x-$stepX
	Local $lastImg="hc"&$nextImgI&".bmp"
	_ScreenCapture_CaptureWnd($lastImg,$hwnd,$lastX+$offX,358,$lastX+$offX+302,702,False);
	if isCardReady($lastImg) Then
		mclick($lastX,$y)
		mclick(616,276)
		mclick(616,276)
		MouseClick("right");
		$x-=$stepX/2
	EndIf
EndIf
Next
If getBinDiff($lastHash,$startHash)<$thred Then
	$nextImgI-=1
EndIf
;Sleep(20)
;trace("You have cards:"&$nextImgI)
EndFunc


Func initHwnd()
	$hwnd=WinGetHandle("炉石传说")
	If $hwnd == 0 Then
		MsgBox(0,"Can't find 炉石传说","Can't find 炉石传说");
	EndIf
	WinSetState($hwnd,"",@SW_RESTORE)
	WinActivate($hwnd)
	WinMove($hwnd,"",0,0);
	Local $clientSize=WinGetClientSize($hwnd)
	$clientWidth=$clientSize[0]
	$clientHeight=$clientSize[1]
	test()
	;***********test dm************/
	$foobar = $dm.CreateFoobarRect($hwnd,10,100,200,250)
	$statusBar=$dm.CreateFoobarRect($hwnd,3,514,399,80)
	$stateBar=$dm.CreateFoobarRect($hwnd,1143,506,116,42)
	;trace("dm.ret="&$ret);
;********
EndFunc



