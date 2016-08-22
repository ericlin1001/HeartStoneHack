#include-once
#include <ParseMainCard.au3>
Func doHit($i,$j)
	$i-=1;
	$j-=1;
	If $j>=$otherPlayerStatus[$PS_NUM_DECK_CARDS] Then
		trace("don't need to attack "&$i&" hit "&$j);
		Return;
	EndIf
	If $i==-1 Then
		clickPP($PP_MY_HERO)
	Else
		Local $mx=$myDeckCards[$i][$CI_X]
		Local $my=$myDeckCards[$i][$CI_Y]
		mclick($mx,$my)
	EndIf
	If $j==-1 Then
		clickPP($PP_OTHER_HERO)
	Else
		Local $ox=$otherDeckCards[$j][$CI_X]
		Local $oy=$otherDeckCards[$j][$CI_Y]
		mclick($ox,$oy)
	EndIf
	Sleep(300);
	MouseClick("right");
EndFunc

Func useHeroSkill()
	if $myPlayerStatus[$PS_CUR_CRYSTAL]>=2 Then
	If $myPlayerStatus[$PS_HP]<=10 And getOtherAllHit()>3  Then
		;don't use skill
	Else
		If $myPlayerStatus[$PS_HP] >= 5 Then
			clickPP($PP_MY_SKILL)
			clickPP($PP_OTHER_MID);
			clickPP($PP_OTHER_HERO)
			Sleep(700);
		EndIf
	EndIf
EndIf
EndFunc


Func WarlockAIPlayCard()
Local $isEnd=false;
trace("WarlockAIPlayCard()...");
;captureAllHandCards();
If captureHandCard() Then
	Sleep(600);
EndIf
;return false;
getAttackActions();
For $i=0 to $numAttackAtions-1
doHit($attackActions[$i][0],$attackActions[$i][1]);
Next
if getInstPlayCardState()=="otherTurn" Then
	return True
EndIf
useHeroSkill();

If captureHandCard() Then
	Sleep(600);
EndIf
getAttackActions();
trace("$numAttackAtions2:"&$numAttackAtions);
For $i=0 to $numAttackAtions-1
doHit($attackActions[$i][0],$attackActions[$i][1]);
Next

If $numAttackAtions>0 Then
Sleep(600)
EndIf
updateCurPlayerStatus()
Local $x,$y;
If isMyAnyReady($x,$y) Then
	Return generalAIPlayCard(1);
EndIf
Return $isEnd
EndFunc