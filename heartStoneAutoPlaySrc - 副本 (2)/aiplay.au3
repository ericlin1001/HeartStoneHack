;Description: implemnt AIPlayCard()
;             just play the cards in deck.
;
; about parse the status of game:
; call updateCurPlayerStatus(), and all info is parsed into (Please reference file:ParseMainCard.au3)
;
;Global Enum $PS_HP,$PS_ARMOUR,$PS_CUR_CRYSTAL,$PS_MAX_CRYSTAL,$PS_NUM_HAND_CARDS,$PS_NUM_DECK_CARDS;
;Global Enum $CI_COST,$CI_HIT,$CI_HP,$CI_X,$CI_Y,$CI_IS_MOCK,$CI_IS_READY
;Global $myPlayerStatus[6];hp,armour,curCrystal,maxcrystal,numhandCards,numDeckCards
;Global $myDeckCards[10][7];cost,hit,hp,x,y,isMock,isready
;Global $otherPlayerStatus[6];hp,armour,curCrystal,maxcrystal,numhandCards,numDeckCards
;Global $otherDeckCards[10][7];cost,hit,hp,x,y,isMock,isready

#include-once
#include <ParseMainCard.au3>



;******************about the ai*****************
Func restMouse1()
	MouseMove($defaultXY[0],$defaultXY[1]);
EndFunc

Global Enum $SG_ATTACK_HERO,$SG_ATTACK_CARD,$SG_GIVE_UP_GAME

Func isMyAnyReady(ByRef $x,ByRef $y)
	$myNumDeckCard=$myPlayerStatus[$PS_NUM_DECK_CARDS];
	For $i=0 to $myNumDeckCard-1
		if  $myDeckCards[$i][$CI_IS_READY] Then
			$x=$myDeckCards[$i][$CI_X];
			$y=$myDeckCards[$i][$CI_Y];
			Return True
		EndIf
	Next
	Return False
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
		;other card dies.
		$ret*=1.3;
	$ret+=11.0
	EndIf
	If $mhp<=$ohit Then
		;my card dies
		$ret-=($mhit+$mhp*0.5)*3
	Else
		$ret-=Log($mhit+1)/Log(2)
	EndIf
	$ret-=Log($mhit+1)/Log(2)
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
	For $i=0 to $myNumDeckCard
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
	;trace($ti&" hits " & $tj &" gain:"&$max);
	if $max==-1 Then
		Return False
	EndIf
	Return True
EndFunc

Func getMock(ByRef $x,ByRef $y)
	$otherNumDeckCard=$otherPlayerStatus[$PS_NUM_DECK_CARDS];
	for $j=0 to $otherNumDeckCard-1
				If $otherDeckCards[$j][$CI_IS_MOCK] then
					$x=$otherDeckCards[$j][$CI_X]
					$y=$otherDeckCards[$j][$CI_Y]
					Return True
				EndIf
			Next
			Return False
EndFunc

Func decideHitMockAction(ByRef $ti,ByRef $tj)
	;Local $gainMatrix[10][10];
	$myNumDeckCard=$myPlayerStatus[$PS_NUM_DECK_CARDS];
	$otherNumDeckCard=$otherPlayerStatus[$PS_NUM_DECK_CARDS];
	$max=-1
	For $i=0 to $myNumDeckCard
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
	;trace($ti&" hits " & $tj &" gain:"&$max);
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
WEnd
	if $myPlayerStatus[$PS_CUR_CRYSTAL]>=2 Then
		;can release hero skill.
		;release hero skill.
		clickPP($PP_MY_SKILL)
		clickPP($PP_OTHER_MID)
		MouseClick("right");
	EndIf
	if $myPlayerStatus[$PS_HIT]>0 Then
		clickPP($PP_MY_HERO)
		Local $x,$y;
		If getMock($x,$y) Then
			mclick($x,$y)
		Else
			clickPP($PP_OTHER_MID)
		EndIf
		MouseClick("right");
	EndIf
	restMouse1()
EndFunc

Func attackHero()
Local $count=0;
Local $mx,$my;
Local $ox,$oy;
While $count<10
	$isAnyReady=false
	$myNumDeckCard=$myPlayerStatus[$PS_NUM_DECK_CARDS];
	$otherNumDeckCard=$otherPlayerStatus[$PS_NUM_DECK_CARDS];
	if isMyAnyReady($mx,$my) Then
		$count+=1;
		mclick($mx,$my)
		clickPP($PP_OTHER_HERO)
		Sleep(300);
		MouseClick("right");
		Sleep(600);
		If $count>=7 Then
			trace("Can't attack hero, attack Card...");
			attackCard()
			$count=10;
		EndIf
	Else
		$count+=3
	EndIf
	updateCurPlayerStatus()
WEnd
	if $myPlayerStatus[$PS_CUR_CRYSTAL]>=2 Then
		;can release hero skill.
		;release hero skill.
		clickPP($PP_MY_SKILL)
		clickPP($PP_OTHER_HERO)
		MouseClick("right");
	EndIf
	if $myPlayerStatus[$PS_HIT]>0 Then
		clickPP($PP_MY_HERO)
		Local $x,$y;
		If getMock($x,$y) Then
			mclick($x,$y)
		Else
			clickPP($PP_OTHER_HERO)
		EndIf
		MouseClick("right");
	EndIf
EndFunc


Func attackMock()
Local $count=0;
Local $i,$j;
trace("decide whether has mock")
$ret=False
While $count<=7
	if decideHitMockAction($i,$j) Then
		trace("attacking mock")
		$ret=True
		$count+=1;
		hitCard($i,$j)
		restMouse1()
		Sleep(1000);
	Else
		$count+=4
	EndIf
	updateCurPlayerStatus()
	Sleep(100)
WEnd
Return $ret
EndFunc

Func getMyMostHit()
	Local $ret=0
	$myNumDeckCard=$myPlayerStatus[$PS_NUM_DECK_CARDS];
	For $i=0 to $myNumDeckCard
		if  $myDeckCards[$i][$CI_IS_READY] Then
			$ret+=Abs($myDeckCards[$i][$CI_HIT]);
		EndIf
	Next
	Return $ret;
EndFunc



Func getMyAllHit()
	Local $ret=0
	$myNumDeckCard=$myPlayerStatus[$PS_NUM_DECK_CARDS];
	For $i=0 to $myNumDeckCard
		$ret+=Abs($myDeckCards[$i][$CI_HIT]);
	Next
	Return $ret;
EndFunc



Func getOtherAllHit()
	Local $ret=0
	$otherNumDeckCard=$otherPlayerStatus[$PS_NUM_DECK_CARDS];
	For $i=0 to $otherNumDeckCard-1
		$ret+=Abs($otherDeckCards[$i][$CI_HIT]);
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

showStatus("My[hp:"&$myHp&",mostHit:"&$myMostHit&",allHit:"&$myAllHit&",heroHit:"&$myPlayerStatus[$PS_HIT]&"]");

appendStatus("Other[hp:"&$otherHp&",allHit:"&$otherAllHit&"]")
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
	If $myHp<14 Then
		If ($otherHp-$myMostHit-$myHp+$otherAllHit)>0 Then
			return $SG_ATTACK_CARD
		EndIf
	EndIf
	If ($myHp-$otherAllHit*2)<=0 Then
		return $SG_ATTACK_CARD
	EndIf
	If $otherAllHit<=0 Then
		return $SG_ATTACK_HERO
	EndIf
	If $myHp>13 Then
		If $otherHp-$myHp>8 Then
			If $myAllHit > $otherAllHit Then
				return $SG_ATTACK_HERO
			Else
				return $SG_ATTACK_CARD
			EndIf
		EndIf
	EndIf
	If $myHp<20 And $otherHp>15 Then
		If $myAllHit<=8 And $otherAllHit-$myAllHit>8 Then
			Return $SG_GIVE_UP_GAME
		EndIf
	EndIf

	If $myHp<18 Then
		If $otherHp>23 Then
			If $otherAllHit>7 And $myAllHit<$otherAllHit Then
				Return $SG_GIVE_UP_GAME
			EndIf
		EndIf
	EndIf


	if Ceiling($myHp/$otherAllHit)<=Ceiling(($otherHp-$myMostHit)/$myAllHit)-1 Then
		return $SG_ATTACK_CARD
	else
		return $SG_ATTACK_HERO
	EndIf
EndFunc


Func AIPlayCard()
	;************
	Local $isEnd=False
	For $i =1 to 2
		captureHandCard();
		Sleep(600);
		if getInstPlayCardState()=="otherTurn" Then
			$isEnd=True
		EndIf
		If Not $isEnd Then
			updateCurPlayerStatus();
			 If attackMock() Then
				Sleep(1000)
			 EndIf
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
				case $SG_GIVE_UP_GAME
					trace("My Strategy:"&"SG_GIVE_UP_GAME")
					appendStatus("My Strategy:"&"SG_GIVE_UP_GAME");
					giveUpGame()
					$isEnd=True
			EndSwitch
			appendStatus("Gold:"&$gold);
			Sleep(1200)
		EndIf
		sendMockMessage()
		Sleep(300);
	Next

	Return $isEnd
EndFunc

