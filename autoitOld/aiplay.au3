
#include-once
;#include<heartStonePlay1.au3>


;******************about the ai*****************
Func restMouse1()
	MouseMove($defaultXY[0],$defaultXY[1]);
EndFunc

Global Enum $SG_ATTACK_HERO,$SG_ATTACK_CARD
Func isMyAnyRead(ByRef $x,ByRef $y)
	$myNumDeckCard=$myPlayerStatus[$PS_NUM_DECK_CARDS];
	For $i=0 to $myNumDeckCard-1
		Local $mycard[7];
		copyArr($mycard,$myDeckCards,$i,7)
		if  $mycard[$CI_IS_READY] Then
			$x=$mycard[$CI_X];
			$y=$mycard[$CI_Y];
			Return True
		EndIf
	Next
	Return False
EndFunc


Func attackHero()
Local $count=0;
Local $mx,$my;
Local $ox,$oy;
While $count<10
	$isAnyReady=false
	$myNumDeckCard=$myPlayerStatus[$PS_NUM_DECK_CARDS];
	$otherNumDeckCard=$otherPlayerStatus[$PS_NUM_DECK_CARDS];
	if isMyAnyRead($mx,$my) Then
		$count+=1;
		mclick($mx,$my)
		clickPP($PP_OTHER_HERO)
		Sleep(300);
		MouseClick("right");
		Sleep(600);
	Else
		$count+=3
	EndIf
	updateCurPlayerStatus()
	Sleep(100)
WEnd
	clickPP($PP_MY_SKILL)
	clickPP($PP_OTHER_HERO)
	MouseClick("right");
	clickPP($PP_MY_HERO)
	clickPP($PP_OTHER_HERO)
	MouseClick("right");
EndFunc

Func getHitGain($i,$j)
	;mycard[$i] hit othercard[$j].
	;if other die +=11
	;if my die -=hithp/2
	;other +=other:hp+1.5*hit.
	Local $mhit=$myDeckCards[$i][$CI_HIT]
	Local $mhp=$myDeckCards[$i][$CI_HP]
	Local $ohit=$otherDeckCards[$j][$CI_HIT]
	Local $ohp=$otherDeckCards[$j][$CI_HP]
	Local $ret=0.0;
	$ret=$ohp+Number($ohit,3)*1.5
	If $mhit>=$ohp Then
	$ret+=11.0
	EndIf
	If $mhp<=$ohit Then
	$ret-=($mhit+$mhp*0.5)*2
EndIf
$ret-=($mhit*3+$mhp*2)*0.07
	;trace("gain:"&$ret)
	return $ret
EndFunc

Func hitCard($i,$j)
	Local $mx=$myDeckCards[$i][$CI_X]
	Local $my=$myDeckCards[$i][$CI_Y]
	Local $ox=$otherDeckCards[$j][$CI_X]
	Local $oy=$otherDeckCards[$j][$CI_Y]
mclick($mx,$my)
Sleep(100);
mclick($ox,$oy)
Sleep(200);
MouseClick("right");
EndFunc

Func decideHitAction(ByRef $ti,ByRef $tj)
	;Local $gainMatrix[10][10];
	$myNumDeckCard=$myPlayerStatus[$PS_NUM_DECK_CARDS];
	$otherNumDeckCard=$otherPlayerStatus[$PS_NUM_DECK_CARDS];
	$max=-1
	For $i=0 to $myNumDeckCard-1
		If $myDeckCards[$i][$CI_IS_READY] Then
			for $j=0 to $otherNumDeckCard-1
				Local $gain=getHitGain($i,$j)
				If $gain>$max Then
					$ti=$i
					$tj=$j
					$max=$gain
				EndIf
			Next
		EndIf
	Next
	trace($ti&" hits " & $tj &" gain:"&$max);
	if $max==-1 Then
		Return False
	EndIf
	Return True
EndFunc

Func decideHitMockAction(ByRef $ti,ByRef $tj)
	;Local $gainMatrix[10][10];
	$myNumDeckCard=$myPlayerStatus[$PS_NUM_DECK_CARDS];
	$otherNumDeckCard=$otherPlayerStatus[$PS_NUM_DECK_CARDS];
	$max=-1
	For $i=0 to $myNumDeckCard-1
		If $myDeckCards[$i][$CI_IS_READY] Then
			for $j=0 to $otherNumDeckCard-1
				If $otherDeckCards[$j][$CI_IS_MOCK] then
					Local $gain=getHitGain($i,$j)
					If $gain>$max Then
						$ti=$i
						$tj=$j
						$max=$gain
					EndIf
				EndIf
			Next
		EndIf
	Next
	trace($ti&" hits " & $tj &" gain:"&$max);
	if $max==-1 Then
		Return False
	EndIf
	Return True
EndFunc

Func attackCard()
Local $count=0;
Local $i,$j;
While $count<10
	$isAnyReady=false
	if decideHitAction($i,$j) Then
		$count+=1;
		hitCard($i,$j)
		restMouse1()
		Sleep(1000);
	Else
		$count+=3
	EndIf
	updateCurPlayerStatus()
	Sleep(100)
WEnd
	clickPP($PP_MY_SKILL)
	clickPP($PP_OTHER_MID)
	MouseClick("right");
	clickPP($PP_MY_HERO)
	clickPP($PP_OTHER_MID)
	MouseClick("right");
EndFunc

Func attackMock()
Local $count=0;
Local $i,$j;
While $count<10
	if decideHitMockAction($i,$j) Then
		$count+=1;
		hitCard($i,$j)
		restMouse1()
		Sleep(1000);
	Else
		$count+=3
	EndIf
	updateCurPlayerStatus()
	Sleep(100)
WEnd
EndFunc

Func attackMock_old()
Local $count=0;
Local $mx,$my;
Local $ox,$oy;
While $count<10
	$isAnyReady=false
	$myNumDeckCard=$myPlayerStatus[$PS_NUM_DECK_CARDS];
	$otherNumDeckCard=$otherPlayerStatus[$PS_NUM_DECK_CARDS];
	if isOtherHashMock($ox,$oy) And  isMyAnyRead($mx,$my) Then
		$count+=1;
		mclick($mx,$my)
		mclick($ox,$oy)
		restMouse1();
		Sleep(300);
		MouseClick("right");
		Sleep(1000);
	Else
		$count+=3
	EndIf
	updateCurPlayerStatus()
	Sleep(100)
WEnd
EndFunc

Func attackCard_old()
Local $count=0;
Local $mx,$my;
Local $ox,$oy;
While $count<10
	$isAnyReady=false
	$myNumDeckCard=$myPlayerStatus[$PS_NUM_DECK_CARDS];
	$otherNumDeckCard=$otherPlayerStatus[$PS_NUM_DECK_CARDS];
	if isMyAnyRead($mx,$my) Then
		$count+=1;
		mclick($mx,$my)
		clickPP($PP_OTHER_MID)
		Sleep(300);
		MouseClick("right");
		Sleep(600);
	Else
		$count+=3
	EndIf
	updateCurPlayerStatus()
	Sleep(100)
WEnd
clickPP($PP_MY_SKILL)
	clickPP($PP_OTHER_MID)
	MouseClick("right");
	clickPP($PP_MY_HERO)
	clickPP($PP_OTHER_MID)
	MouseClick("right");
EndFunc

Func getMyMostHit()
	Local $ret=0
	$myNumDeckCard=$myPlayerStatus[$PS_NUM_DECK_CARDS];
	For $i=0 to $myNumDeckCard-1
		Local $mycard[7];
		copyArr($mycard,$myDeckCards,$i,7)
		if  $mycard[$CI_IS_READY] Then
			$ret+=Abs($mycard[$CI_HIT]);
		EndIf
	Next
	Return $ret;
EndFunc



Func getMyAllHit()
	Local $ret=0
	$myNumDeckCard=$myPlayerStatus[$PS_NUM_DECK_CARDS];
	For $i=0 to $myNumDeckCard-1
		Local $mycard[7];
		copyArr($mycard,$myDeckCards,$i,7)
		$ret+=Abs($mycard[$CI_HIT]);
	Next
	Return $ret;
EndFunc



Func getOtherAllHit()
	Local $ret=0
	$otherNumDeckCard=$otherPlayerStatus[$PS_NUM_DECK_CARDS];
	For $i=0 to $otherNumDeckCard-1
		Local $othercard[7];
		copyArr($othercard,$otherDeckCards,$i,7)
		$ret+=Abs($othercard[$CI_HIT]);
	Next
	Return $ret;
EndFunc


Func getStrategy()
	updateCurPlayerStatus();

	$myHp=Abs($myPlayerStatus[$PS_HP]);
	$otherHp=Abs($otherPlayerStatus[$PS_HP]);
	$myMostHit=getMyMostHit()
	$myAllHit=getMyAllHit()
	$otherAllHit=getOtherAllHit()
	trace("calculating strategy....")
	;trace("$myHp:"&$myHp);
	;trace("$otherHp:"&$otherHp);
	;trace("$myMostHit:"&$myMostHit);
	;trace("$myAllHit:"&$myAllHit);
	;trace("$otherAllHit:"&$otherAllHit);

showStatus("My[hp:"&$myHp&",mostHit:"&$myMostHit&",allHit"&$myAllHit&"");

appendStatus("Other[hp:"&$otherHp&",allHit"&$otherAllHit&"]")
trace("otheDeckCard:"&$otherPlayerStatus[$PS_NUM_DECK_CARDS])
If $otherPlayerStatus[$PS_NUM_DECK_CARDS]<=0 Then
	return $SG_ATTACK_HERO
EndIf

	If ($myHp-$otherHp)>20 Then
		return $SG_ATTACK_HERO
	EndIf
	If ($otherHp-$myMostHit)<=0 Then
		return $SG_ATTACK_HERO
	EndIf
	If ($otherHp-$myMostHit-$myHp+$otherAllHit)>-8 Then
		return $SG_ATTACK_CARD
	EndIf

	If ($myHp-$otherAllHit*2)<=0 Then
		return $SG_ATTACK_CARD
	EndIf
	if Ceiling($myHp/$otherAllHit)<=Ceiling(($otherHp-$myMostHit)/$myAllHit)-1 Then
		return $SG_ATTACK_CARD
	else
		return $SG_ATTACK_HERO
	EndIf
EndFunc


Func AIPlayCard()
	captureHandCard();
	Sleep(600);

	;************
	For $i =1 to 2
		updateCurPlayerStatus();
		 attackMock()
		 updateCurPlayerStatus();
		$sg=getStrategy();
		Switch($sg)
			case $SG_ATTACK_HERO
				trace("My Strategy:"&"SG_ATTACK_HERO")
				appendStatus("My Strategy:"&"ATTACK_HERO");
				attackHero()
			case $SG_ATTACK_CARD
				trace("My Strategy:"&"ATTACK_CARD")
				appendStatus("My Strategy:"&"ATTACK_CARD");

				attackCard()
		EndSwitch
		Sleep(1200)
	Next
EndFunc


Func AIPlayCard_old()
	;now my turn.
	captureHandCard();
	Sleep(600);
	;trace("***cur***cur****");
updateCurPlayerStatus();
Local $count=0;
Local $isAnyReady=false
While $count<18
	$isAnyReady=false
	$myNumDeckCard=$myPlayerStatus[$PS_NUM_DECK_CARDS];
	$otherNumDeckCard=$otherPlayerStatus[$PS_NUM_DECK_CARDS];
;trace("$myNumDeckCard:"&$myNumDeckCard)
;trace("$otherNumDeckCard:"&$otherNumDeckCard)
	For $i=0 to $myNumDeckCard-1
		trace("$i:"&$i)
		Local $mycard[7];
		;$mycard=$myDeckCards[$i]
	copyArr($mycard,$myDeckCards,$i,7)
		if  $mycard[$CI_IS_READY] Then
			$isAnyReady=True
			mclick($mycard[$CI_X]-20,$mycard[$CI_Y])
			;trace("click my card:"&$mycard[$CI_X]&","&$mycard[$CI_Y])
			Local $mx,$my;
			if isOtherHashMock($mx,$my) Then
				trace("other has mock!!!")
				mclick($mx,$my)
				Sleep(300);
			Else
				mclick(643,154); hero pos.
			EndIf
			MouseClick("right");
			Sleep(800);
			updateCurPlayerStatus()
			$i=50
		EndIf
	Next
$count+=1;
trace("$count:"&$count);
If not $isAnyReady Then
$count+=6
updateCurPlayerStatus()
EndIf
Sleep(100)
WEnd

	;trace("num of deck :"&$myPlayerStatus[$PS_NUM_DECK_CARDS]);
clickPP($PP_MY_SKILL)
clickPP($PP_OTHER_MID)
clickPP($PP_MY_HERO)
clickPP($PP_OTHER_MID)
EndFunc