;**** Directives created by AutoIt3Wrapper_GUI ****
;Description:
;once run this script, it will start play.
;F10 for paused the script.
;F11 for exit the script.
;mainLoop() is the main loop, you may get the image of what this script does.
;The default action flow is :
;		If not in battle mode, click "return button".
;		If in battle mode, select hero randomly, select one of two mode, start play game.
;By Eric(nameljh@sina.com)
#include-once

;This path should be modified to your path of battleNet.
Global $battleNetProgramPath="D:\Program Files\Battle.net\Battle.net Launcher.exe"
Global $isLogFile=False ; If true, the log file is: log.txt
Global $isDebug=True;
Global $isShowBasicInfo=True
Global $preferredHero=8 ; for top to down, from left to right. indexing from 0
Global $prederredMode=0 ;0 for battle mode, 1 for pratice mode.
Global $prederredComputerHero=4
Global $preferredSubMode=0
Global $logFileName="log.log"

;***************
Global $state;
Global $hwnd=0,$phwnd;
;Global $states[]=["challenge","arenaMode0","arenaMode1","battleMode","friendMode","buildingCard","buyingCard","checkForTasks","mainMenu","openCardPack","playingCard","praticeMode","searchForOppoent","selectCard"];
Global $states[]=["tutorial","mainMenu","battleMode","searchForOppoent","selectCard","playingCard","challenge","arenaMode0","arenaMode1","friendMode","buildingCard","buyingCard","checkForTasks","openCardPack","praticeMode","closed","loseGame","winGame"];
Global $heros[]=["Druid","Hunter","Mage","Paladin","Priest","Rogue","Shaman","Warlock","Warrior"]
Global $heroHashs[9];

Global $defaultXY[]=[1100,500];
Global $isEnd=False
Global $heroPoss[3][3][2];//[row][col][xy]
Global $computerHeroPoss[9][2];
Global $selectCardPoss[2][4][2];
Global $messagePoss[6][2];
Global $tutorialPoss[6][2];
Global $clientWidth,$clientHeight;
Global Enum $PP_MY_HERO,$PP_OTHER_HERO,$PP_MY_SKILL,$PP_OTHER_MID
Global $imgPath="simgs\"
Global $startTimeHandle;
Global $runTime;
Global $myHero;
Global $battlenetTitle="战网";"Battle.net";

#include <MsgBoxConstants.au3>
#include <ScreenCapture.au3>
#include <Debug.au3>
#include <ImageSearch.au3>
#include <ParseMainCard.au3>
#include <utils.au3>
#include <PHash.au3>
#include <aiplay.au3>
#include <basicFuns.au3>
#include <Misc.au3>
;*********************control of script *******************
; Press Esc to terminate script, Pause/Break to "pause"
Global $fPaused = False

startThisScript()
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

Func startThisScript()
	startApp()
EndFunc   ;==>ShowMessage

Func startApp()
	If _Singleton("hearthMoniter", 1) = 0 Then
		;MsgBox($MB_SYSTEMMODAL, "Warning", "An occurence of test is already running")
		;trace(""An occurence of test is already running"")
		Send("{F11}");end the previouse script.
		Sleep(1000);
		;Exit
	EndIf
	HotKeySet("{F10}", "TogglePause")
	HotKeySet("{F11}", "Terminate")
	HotKeySet("{F9}", "startThisScript") ; Shift-Alt-d

	$isEnd=False
	$startTimeHandle=TimerInit();
	readSetting()
	setupDebug()
	initScript()
	startGameProgram()
	createFoobars()
	mainLoop()
EndFunc

;**************************Main function******************
Func ScreenCapture_CaptureWnd($file,$hWnd,$iLeft=0,$iTop=0,$iRight=-1,$iBottom=-1,$bCursor=True)
_ScreenCapture_CaptureWnd($imgPath&$file,$hWnd,$iLeft,$iTop,$iRight,$iBottom,$bCursor)
EndFunc

Func ImageSearch($findImage,$resultPosition,ByRef $x, ByRef $y,$tolerance, $HBMP=0)
	;trace("search for "&$findImage)
	;trace("w:"&@DesktopWidth)
	;trace("@DesktopHeight:"&@DesktopHeight)
   return _ImageSearchArea($imgPath&$findImage,$resultPosition,0,0,@DesktopWidth,@DesktopHeight,$x,$y,$tolerance,$HBMP)
EndFunc

Func createFoobars()
EndFunc

Func createFoobars_Old()
	;***********test dm************/
	If $foobar>-1 Then
		$ret=$dm.FoobarClose($foobar)
		If $ret==0 Then
			trace("Error: $dm.FoobarClose($foobar) fails");
		EndIf
	EndIf
	If $statusBar>-1 Then
		$ret=$dm.FoobarClose($statusBar)
		If $ret==0 Then
			trace("Error: $dm.FoobarClose($statusBar) fails");
		EndIf
	EndIf

	If $isDebug Then
		$foobar = $dm.CreateFoobarRect($hwnd,10,100,200,250)
	EndIf
	If $isShowBasicInfo Then
		$statusBar=$dm.CreateFoobarRect($hwnd,3,514,399,80)
		$stateBar=$dm.CreateFoobarRect($hwnd,1143,506,116,42)
	EndIf
	;trace("dm.ret="&$ret);
;********
EndFunc

Func readSetting()
$battleNetProgramPath=IniRead("setting.ini","General","battleNetProgramPath","D:\Program Files\Battle.net\Battle.net Launcher.exe")
$isLogFile=Int(IniRead("setting.ini","General","isLogFile",1))
$isDebug=Int(IniRead("setting.ini","General","isDebug",1))
;Local $test=IniRead("setting.ini","General","test","default")
;trace("$test"&$test)
;trace("$isDebug"&$isDebug)
$isShowBasicInfo=Int(IniRead("setting.ini","General","isShowBasicInfo",0))
$preferredHero=Int(IniRead("setting.ini","General","preferredHero",8))
$prederredMode=Int(IniRead("setting.ini","General","prederredMode",0))
$prederredComputerHero=Int(IniRead("setting.ini","General","prederredComputerHero",4))
$preferredSubMode=Int(IniRead("setting.ini","General","preferredSubMode",0))
$logFileName=IniRead("setting.ini","General","logFileName","log.log");
EndFunc

;************start the game program*********
Func isProgramExist($p)
	Local $h=WinGetHandle($p);
	If @error Then
		return False
	EndIf
	If IsHungAppWindow($h) Then
		WinKill($h)
		Sleep(300);
		Return False
	EndIf
	Return True
EndFunc

Func startGameProgram()
	$endWhile=False
	trace("check for heartStone program exist?");
	If  isProgramExist("炉石传说") Then
		trace("heartStone had been opened, start play1.")
		$hwnd=WinGetHandle("炉石传说")
		;WinSetState($hwnd,"",@SW_RESTORE)
		;WinActivate($hwnd)
		;WinMove($hwnd,"",0,0);
		;Local $clientSize=WinGetClientSize($hwnd)
		;$clientWidth=$clientSize[0]
		;$clientHeight=$clientSize[1]
		$endWhile=True;
	EndIf
	While Not $endWhile
		If isProgramExist($battlenetTitle) Then
			$phwnd=WinGetHandle($battlenetTitle)
			If  isProgramExist("炉石传说") Then
				trace("heartStone had been opened, start play2.")
				$hwnd=WinGetHandle("炉石传说")
				WinSetState($hwnd,"",@SW_RESTORE)
				;WinActivate($hwnd)
				;WinMove($hwnd,"",0,0);
				;Local $clientSize=WinGetClientSize($hwnd)
				;$clientWidth=$clientSize[0]
				;$clientHeight=$clientSize[1]
				createFoobars()
				$endWhile=True
			Else
				$hwnd=0;
				trace("opening heartStone game program.")
				Send("#d");
				WinSetState($phwnd,"",@SW_RESTORE)
				WinActivate($phwnd)
				WinMove($phwnd,"",0,0);
				Sleep(400)
				mclick(49,321)
				Sleep(200)
				;mclick(221,471)
				clickPics("button_online.bmp|button_online1.bmp");
				trace("click enterGame...");

				Local $cs=WinGetClientSize($phwnd)
				Local $bheight=$cs[1];

				mclick(304,$bheight-89);
				clickPics("button_enterGame.bmp|button_enterGame1.bmp");|button_playGame.bmp|button_playGame1.bmp|button_playGame2.bmp")
				Sleep(400)
				Sleep(1300)
			EndIf
		Else
			trace("opening battlen net.")
			If Not ProcessExists("Battle.net.exe")>0 Then
				Run($battleNetProgramPath)
			EndIf
			Sleep(6000)
		EndIf
	WEnd
	startHearthcrawler()
EndFunc


Func startHearthcrawler()
	$endWhile=False
	$title="Hearthcrawler (arMa)  "
	trace("check for heartStone program exist?");
	If  isProgramExist($title) Then
		trace("Hearthcrawler had been opened, start play1.")
		$hwnd=WinGetHandle($title)
		;WinSetState($hwnd,"",@SW_RESTORE)
		$endWhile=True;
	EndIf
	$hearthcrawlerProgramPath="I:\HeartStoneGame\HearthCrawler R24 Cracked - Updater Blocked [arMa]\Hearthcrawler.exe"
	While Not $endWhile
		If isProgramExist($title) Then
			$hwnd=WinGetHandle($title)
			WinSetState($hwnd,"",@SW_RESTORE)

			WinMove($hwnd,"",0,0);
			WinActivate($hwnd)
			mclick(687,153);
			Sleep(200);
			mclick(559,409);
			Sleep(200);
			;****
mclick(661,246);
Sleep(1000);
mclick(466,329);
Sleep(500);
mclick(559,409);
			$endWhile=True
		Else
			trace("opening "&$title)
			If Not ProcessExists("Hearthcrawler.exe")>0 Then
				Run($hearthcrawlerProgramPath)
			EndIf
			Sleep(6000)
		EndIf
		WinActivate("炉石传说");
	WEnd
EndFunc

;************end start****************

Func initScript()
	AutoItSetOption("WinTitleMatchMode",3);Exact title match.
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
	;,,,572,
	For $i=0 to 5
		If $i<3 Then
			$xx=535
			$yy=453+60*$i
		Else
			$yy=453+60*($i-3)
			$xx=776
		EndIf
		$messagePoss[$i][0]=$xx
		$messagePoss[$i][1]=$yy
	Next
	for $i=0 to 5
		$xx=326+120*$i
		$tutorialPoss[$i][0]=$xx;
		$tutorialPoss[$i][1]=545;
	Next


EndFunc
;***************play game******
Func restMouse()
	mclick($defaultXY[0],$defaultXY[1]);
EndFunc

Func mmove($x,$y,$s=10)
	$x=$x+Random(-2,2,1)
	$y=$y+Random(-2,2,1)
	MouseMove($x,$y,$s)
	Sleep(50)
EndFunc

Func mclick($x,$y,$isLeft=True)
	$x=$x+Random(-2,2,1)
	$y=$y+Random(-2,2,1)
	If $isLeft Then
	MouseClick("left",$x,$y,1,5)
Else
	MouseClick("right",$x,$y,1,5)
EndIf
	Sleep(50)
EndFunc

Func clickPP($type,$isLeft=True)
	Switch($type)
		case $PP_MY_HERO
			mclick(645,533,$isLeft)
		case $PP_OTHER_HERO
			mclick(649,150,$isLeft)
		case $PP_MY_SKILL
			mclick(759,545,$isLeft)
		case $PP_OTHER_MID
			mclick(618,279,$isLeft); mide of other deck card.
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
			Local $ret=ImageSearch($imgs[$i],1,$x,$y,20);
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
	PixelSearch(1014,322,1031,328,0x04BF29,20);search for my round end.
	If Not @error Then ;end my round.
		endRound()
		Sleep(500)
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
	captureAll($imgPath&"all.bmp");
	getMainCardInfo($imgPath&"all.bmp");
EndFunc
Func getAttackActions()
	captureAll($imgPath&"all.bmp");
	getMainCardInfo($imgPath&"all.bmp");
	getActions($imgPath&"all.bmp");
EndFunc


Func sendMockMessage()
	If Random(0,100,1)<50 Then
					If Random(0,100,1)<70 Then
						clickMessage(4)
					Else
						clickMessage(Random(0,5,1))
					EndIf
				EndIf

EndFunc

Func playCard()
	;trace("This use AI to play card!!!")
	$s=getPlayCardState();
	;trace("p_state:"&$s);
	Switch $s
		case "myTurn"
			updateMyHero();
			updateCurPlayerStatus()
			if  AIPlayCard() Then
			Else
				endRound()
			EndIf
		case "otherTurn"
			trace("waiting for other play...")
			Sleep(500)
		case Else
			trace("unknow turn...??")
	EndSwitch

EndFunc

Func mmclick($xy,$isLeft=True)
	mclick($xy[0],$xy[1],$isLeft)
EndFunc

Func clickIfReturn()
	clickPics("button_return.bmp|button_return1.bmp|button_return2.bmp|button_return3.bmp|button_return4.bmp|button_return5.bmp|button_return6.bmp")
	mclick(1047,655)
	restMouse()
EndFunc
Func buttonAccept()
	clickPics("button_accept.bmp")
EndFunc

Func clickMessage($type)
	clickPP($PP_MY_HERO,False)
	mclick($messagePoss[$type][0],$messagePoss[$type][1])
	restMouse()
EndFunc
Func updateGold()
_ScreenCapture_Capture("simgs\gold.bmp",1094,688,1199,707);
Local $g=parseInt("simgs\gold.bmp")
If $g==-1 Then
Else
	$gold=$g;
EndIf
trace("My Gold:"&$gold)
EndFunc

Func testForGameCarsh()
if WinExists("Oops!") Or IsHungAppWindow($hwnd) Then
	WinClose("Oops!");
	WinKill("炉石传说");
	trace("game has crash");
	startGameProgram()
EndIf
EndFunc

Func getRunTime()
	$runTime=TimerDiff($startTimeHandle);
	$runTime/=1000;
	trace("runTime:"&$runTime&" seconds");
	return $runTime;
EndFunc

Func restartGameProgram()
	trace("closing heartStone");
	WinClose($hwnd);
	Sleep(5000);
	startGameProgram();
EndFunc


Func getInstMyHero()
	Local $x,$y;
	_ScreenCapture_Capture("simgs\hero_cur.bmp",628,515,674,570,False);
	Local $cur=getHash("simgs\hero_cur.bmp");

	For $i=0 to 8
		If getBinDiff($cur,$heroHashs[$i])<10 Then
			Return $heros[$i]
		EndIf
	Next
	return "unknow"
	;_ScreenCapture_Capture("simgs\hero_"&$hero&".bmp",628,515,674,570,False);
EndFunc

Func updateMyHero()
	Local $count=0;
	Local $h;
	While $count<=5
		$h=getInstMyHero()
		If $h<>"unknow" Then
			$myHero=$h;
			$count=100
		Else
			Sleep(500)
			$count+=1
		EndIf
	WEnd
	Return $h
EndFunc

;************end play game*******
Func mainLoop()
	Local $lastState="??";
	Local $unknowCount=0;
	Local $loopCount=0;
	Local $restartGameTimerHandler=TimerInit();
	While 1
		;mclick(647,428);click the mid of screen, mostly the ok_button.
		;$state=getState(False,1);
		;*****
		if (TimerDiff($restartGameTimerHandler)/1000)>60*60*2 Then
			$state="closed";
			$restartGameTimerHandler=TimerInit();
		EndIf
		testForGameCarsh()
		$loopCount+=1
	;	If $lastState<>$state Then
	;	;	trace("change to state:"&$state)
	;	EndIf
		If Mod($loopCount,10)==0 Then
			startGameProgram()
		EndIf
	;	$lastState=$state
		Switch $state
			;******
			case "closed"
				restartGameProgram();
		EndSwitch
		trace("l.");
		Sleep(500)
	WEnd
	trace("exiting....");
EndFunc

Func mainLoop_Old()
	Local $lastState="??";
	Local $unknowCount=0;
	Local $loopCount=0;
	Local $restartGameTimerHandler=TimerInit();
	While 1
		;mclick(647,428);click the mid of screen, mostly the ok_button.
		restMouse();
		clickPics("button_ok0.bmp|button_ok1.bmp|button_ok2.bmp|button_ok6.bmp|button_ok7.bmp")
		$state=getState();
		;*****
		if (TimerDiff($restartGameTimerHandler)/1000)>60*60*2 Then
			$state="closed";
			$restartGameTimerHandler=TimerInit();
		EndIf
		testForGameCarsh()
		$loopCount+=1
		If $lastState<>$state Then
			trace("change to state:"&$state)
		EndIf
		If Mod($loopCount,10)==0 Then
			startGameProgram()
		EndIf
		$lastState=$state
		If $state=="unknow" Then
			$unknowCount+=1
			If $unknowCount>3 Then
				$state="playingCard"
				If $unknowCount>10 Then
					startGameProgram()
					$unknowCount=0
				EndIf
			EndIf
		Else
			$unknowCount=0;
		EndIf
		appendState("state:"&$state)
		Switch $state
			case "mainMenu"
			enterMode($prederredMode)
			updateGold()
			;************
		case "arenaMode0"
			clickIfReturn()
			case "arenaMode1"
			clickIfReturn()
		case "tutorial"
			trace("tutorials....");
			for $i=0 to 5
				mclick($tutorialPoss[$i][0],$tutorialPoss[$i][1]);
			Next
		Case "battleMode"
			;clickIfReturn()
			updateGold()
			If Random(0,100,1)<=100 Then
				selectMyHero($preferredHero);
			Else
				selectMyHero(Random(0,8,1));
			EndIf
			If Random(0,100,1)<90 Then
				selectBattleSubMode($preferredSubMode)
			Else
				selectBattleSubMode(Random(0,1,1))
			EndIf
				buttonEnter()
			case "challenge"
				buttonAccept()
			case "praticeMode"
				;trace("praticeMode")
				;clickIfReturn()
			If Random(0,100,1)<60 Then
				selectMyHero($preferredHero);
				$preferredHero=$preferredHero+1;
				$preferredHero=Mod($preferredHero,9);
			Else
				selectMyHero(Random(0,8,1));
			EndIf
				buttonEnter()
				selectComputerHero($prederredComputerHero)
				buttonEnter()
			case "friendMode"
				If Random(0,100,1)<80 Then
					selectMyHero($preferredHero);
				Else
					selectMyHero(Random(0,8,1));
				EndIf
				If Random(0,100,1)<90 Then
					selectBattleSubMode($preferredSubMode)
				Else
					selectBattleSubMode(Random(0,1,1))
				EndIf
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
				clickIfReturn()
				restMouse()
			case "checkForTasks"
				trace("checkForTasks")
				restMouse()
			case "openCardPack"
				trace("openCardPack")
				clickIfReturn()
			;***********main play game....*****
			case "selectCard"
				trace("selectCard")
				selectCard()
			case "playingCard"
				trace("playingCard")
				playCard()
				;giveUpGame()
			;******
			case "closed"
				restartGameProgram();
			case "loseGame"
				trace("lose the game...");
			case "winGame"
				trace("win the game...");
				If hasPic("endGame_state_hadGain100Gold.bmp") Then
					$preferredSubMode=1;
					trace("have gain 100 gold today");
				Else
					$preferredSubMode=0;
				EndIf
				trace("set prederedSubMode="&$preferredSubMode);
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
	;trace("******start getState()*****")
	While $waitTime<=$timeout
		;trace("******start getInstState()*****")
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
		;trace("search for :"&$p)
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
		Local $ret=ImageSearch($imgs[$i],0,$x,$y,20);
		If $ret=1 Then
			Return True
		EndIf
	Next
	return False
EndFunc

Func hasPic($img)
	Local $x,$y;
	Local $s=ImageSearch($img,0,$x,$y,30);
	;trace("has Pic for :"&$img)
	If $s = 1 Then
		return True
	Else
		;trace("Not Found!");
		return False
	EndIf
EndFunc

Func isCardReady($f)
Local $ready, $cost, $hp, $hit,$all
getCardInfo($f,$ready, $cost, $hp, $hit)
if $ready==0 Then
Return False
EndIf
return True
EndFunc

Func captureAll($f)
	_ScreenCapture_CaptureWnd($f,$hwnd);
EndFunc
Func captureAllHandCards()
	const $offX=-100
	const $cardWidth=275
	;get all cards info.
	;place card into deck.
	updateCurPlayerStatus();
	For $i=0 to $myPlayerStatus[$PS_NUM_HAND_CARDS]-1
		$x=$myHandCards[$i][$CI_X]
		$y=$myHandCards[$i][$CI_Y]
		mmove($x,$y);
		Local $imgFile=$imgPath&"hc"&$i&".bmp"
		Sleep(200)
		_ScreenCapture_CaptureWnd($imgFile,$hwnd,$x+$offX,358,$x+$offX+$cardWidth,702,False);
	Next

EndFunc

Func captureHandCard()
Local $isPlaced=False
Local $count=0;
updateCurPlayerStatus()
While $myPlayerStatus[$PS_NUM_HAND_CARDS]>0 Or $count<=7
	If $myPlayerStatus[$PS_NUM_HAND_CARDS]>0 Then
		$i=Random(0,$myPlayerStatus[$PS_NUM_HAND_CARDS]-1,1)
		mclick($myHandCards[$i][$CI_X],$myHandCards[$i][$CI_Y]);
		mclick(644,276); other mid.
		mclick(514,259); select left option.
		clickPP($PP_OTHER_HERO)
		mclick(580,390); my mid.
		MouseClick("right");
		Sleep(50);
		$count+=1
		$isPlaced=true;
	Else
		$count+=4
		restMouse()
	EndIf
	updateCurPlayerStatus()
WEnd
restMouse()
Return $isPlaced;
EndFunc

Func captureHandCard_old1()
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
const $rX=$fromX+$toX
;capture the actual card:region 520,358,802,702
;minwidth:302, y0=358,y1=702, offx=-60
;***********get start hash******
restMouse();
_ScreenCapture_CaptureWnd($imgPath&"tmp.bmp",$hwnd,386,512,870,890,False);
$startHash=getHash($imgPath&"tmp.bmp")
$lastHash=$startHash;
;**************
mmove($rX-$fromX,$y,1)
For $x=($fromX+$stepX) to $toX Step $stepX
$file=$imgPath&"h"&$nextImgI&".bmp"
;Sleep(80)
_ScreenCapture_CaptureWnd($file,$hwnd,386,512,870,890,False);
mmove($rX-$x,$y,1)
$curHash=getHash($file)
if getBinDiff($lastHash,$curHash)>$thred Then
	;obviouse change of screen.
	$lastHash=$curHash
	$nextImgI+=1;
	Local $lastX=$rX-$x-$stepX
	Local $lastImg=$imgPath&"hc"&$nextImgI&".bmp"
	_ScreenCapture_CaptureWnd($lastImg,$hwnd,$lastX+$offX,358,$lastX+$offX+302,702,False);
	if isCardReady($lastImg) Then
		mclick($lastX,$y)
		clickPP($PP_OTHER_HERO)
		mclick(616,276); other mid.
		mclick(514,259); select left option.
		mclick(620,397); my mid.
		;mclick(616,276)
		MouseClick("right");
		$x+=$stepX*7/10
	EndIf
EndIf
Next
If getBinDiff($lastHash,$startHash)<$thred Then
	$nextImgI-=1
EndIf
restMouse()
EndFunc



Func captureHandCard_old()
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
_ScreenCapture_CaptureWnd($imgPath&"tmp.bmp",$hwnd,386,512,870,890,False);
$startHash=getHash($imgPath&"tmp.bmp")
$lastHash=$startHash;
;**************
mmove($fromX,$y,1)
For $x=($fromX+$stepX) to $toX Step $stepX
$file=$imgPath&"h"&$nextImgI&".bmp"
Sleep(80)
_ScreenCapture_CaptureWnd($file,$hwnd,386,512,870,890,False);
mmove($x,$y,1)
$curHash=getHash($file)
if getBinDiff($lastHash,$curHash)>$thred Then
	;obviouse change of screen.
	$lastHash=$curHash
	$nextImgI+=1;
	Local $lastX=$x-$stepX
	Local $lastImg=$imgPath&"hc"&$nextImgI&".bmp"
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
EndFunc



