#include-once
#include <Debug.au3>
#include <ImageSearch.au3>
;#include <utils.au3>
#include <PHash.au3>
Global Enum $PS_HP,$PS_ARMOUR,$PS_CUR_CRYSTAL,$PS_MAX_CRYSTAL,$PS_HIT,$PS_NUM_HAND_CARDS,$PS_NUM_DECK_CARDS;
Global Enum $CI_COST,$CI_HIT,$CI_HP,$CI_X,$CI_Y,$CI_IS_MOCK,$CI_IS_READY
Global $myPlayerStatus[7];hp,armour,curCrystal,maxcrystal,numhandCards,numDeckCards
Global $myDeckCards[11][7];cost,hit,hp,x,y,isMock,isready
Global $myHandCards[11][7]
Global $otherPlayerStatus[7];hp,armour,curCrystal,maxcrystal,numhandCards,numDeckCards
Global $otherDeckCards[11][7];cost,hit,hp,x,y,isMock,isready
;*****main data***
Global $gold=0;




Func printCards($cards)
	$str="[cost:"&$cards[0]&",hp/hit:"&$cards[1]&"/"&$cards[2]&",("&$cards[3]&","&$cards[4]&",isMock:"&$cards[5]&"]";
	;trace($str)
EndFunc

Func getRight($s,$delim=":")
$sa=StringSplit($s,$delim)
return $sa[$sa[0]]
EndFunc

Func getMainCardInfo($f)
	$allS=parseImg($f)
	;trace("allS:"&$allS)
	if $allS=="0" Then return False
	$allSA=StringSplit($allS,"!");
	$myS=$allSA[1];
	;trace("MyDeckCards:["&$myS&"]");
	$otherS=$allSA[2];
	;trace("OtherDeckCards:["&$otherS&"]");
	;************parse my hand cards******

;*********parse my deck cards*********
$mySA=StringSplit($myS,",");
For $i=0 to 5
$myPlayerStatus[$i]=Int(Number(getRight($mySA[1+$i])))
Next
$myPlayerStatus[6]=Int(Number(getRight($mySA[2+6])))
;parse deck...
$myDeckS=$mySA[9]
$myHandS=$mySA[7]
;trace("myDeckS:"&$myDeckS)
$myDeckSA=StringSplit($myDeckS,"|");
$myHandSA=StringSplit($myHandS,"|");
For $i=1 to $myPlayerStatus[$PS_NUM_DECK_CARDS]
	$deckCardS=$myDeckSA[$i]
	;trace("cur deckCardS:"&$deckCardS);
	$deckCardSA=StringSplit($deckCardS,"/");
	For $j=0 to 6
		$myDeckCards[$i-1][$j]=Int(Number(getRight($deckCardSA[$j+1])))
	Next
Next
For $i=1 to $myPlayerStatus[$PS_NUM_HAND_CARDS]
	$handCardS=$myhandSA[$i]
	;trace("cur handCardS:"&$handCardS);
	$handCardSA=StringSplit($handCardS,"/");
	For $j=0 to 6
		$myHandCards[$i-1][$j]=Int(Number(getRight($handCardSA[$j+1])))
	Next
Next
$i=0
;trace("hit/hp:"&$myDeckCards[$i][$CI_HIT]&","&$myDeckCards[$i][$CI_HP])
;trace("numHandCards:"&$myPlayerStatus[$PS_NUM_HAND_CARDS]&",x/y:"&$myHandCards[$i][$CI_X]&","&$myHandCards[$i][$CI_Y])
;********parse other******
$otherSA=StringSplit($otherS,",");
For $i=0 to 5
$otherPlayerStatus[$i]=Int(Number(getRight($otherSA[1+$i])))
Next
$otherPlayerStatus[6]=Int(Number(getRight($otherSA[2+6])))
;parse deck...
$otherDeckS=$otherSA[9]
;trace("otherDeckS:"&$otherDeckS)
$otherDeckSA=StringSplit($otherDeckS,"|");
For $i=1 to $otherPlayerStatus[$PS_NUM_DECK_CARDS]
	$deckCardS=$otherDeckSA[$i]
	;trace("cur deckCardS:"&$deckCardS);
	$deckCardSA=StringSplit($deckCardS,"/");
For $j=0 to 6
	$otherDeckCards[$i-1][$j]=Int(Number(getRight($deckCardSA[$j+1])))
Next
Next
$i=2
;trace("hit/hp,isMock:"&$otherDeckCards[$i][$CI_HIT]&","&$otherDeckCards[$i][$CI_HP]&","&$otherDeckCards[$i][$CI_IS_MOCK])
;trace("x/y:"&$otherDeckCards[$i][$CI_X]&","&$otherDeckCards[$i][$CI_Y])
;*****************
if $myPlayerStatus[$PS_HIT]==-1 Then
	Local $x,$y;
	if _ImageSearchArea("simgs\c_weapon.bmp",1,459,479,531,547, $x,  $y, 10)<>"0" Then
		;have weapon, but the dll parses incorrectly.
		$myPlayerStatus[$PS_HIT]=1;
	EndIf
EndIf

;for ease of use.
Local $numDeckCards=$myPlayerStatus[$PS_NUM_DECK_CARDS]

If $myPlayerStatus[$PS_HIT]>0 Then
	$myDeckCards[$numDeckCards][$CI_IS_READY]=1
	$myDeckCards[$numDeckCards][$CI_HIT]=$myPlayerStatus[$PS_HIT]
Else
	$myDeckCards[$numDeckCards][$CI_IS_READY]=0
	$myDeckCards[$numDeckCards][$CI_HIT]=0
EndIf
$myDeckCards[$numDeckCards][$CI_HP]=$myPlayerStatus[$PS_HP]
$myDeckCards[$numDeckCards][$CI_X]=645
$myDeckCards[$numDeckCards][$CI_Y]=533
;trace("hero hit:"&$myPlayerStatus[$PS_HIT])
EndFunc

Global $numAttackAtions;
Global $attackActions[10][2];[0] attck [1]. 0 for hero, numDeck mean no hit.
Func getActions($f)
	$allS=parseImgNew($f,0);
	;trace("allS:"&$allS);
	$allSA=StringSplit($allS,"#");
	;trace("num#:"&$allSA[0]);
	If $allSA[0]<=1 Then
		$numAttackAtions=0;
		Return
	EndIf
	$actionsS=$allSA[2];
	trace("$actionsS:"&$actionsS)
	If $actionsS=="" Then
		$numAttackAtions=0;
		Return
	EndIf

	$actionsSA=StringSplit($actionsS,"|");
	If $actionsSA[0]<=0 Then
		$numAttackAtions=0;
		Return
	EndIf
	$numAttackAtions=$actionsSA[0];
	;trace("$numAttackAtions:"&$numAttackAtions)
	for $i=0 to $numAttackAtions-1
		$attack=StringSplit($actionsSA[$i+1],",")
		$attackActions[$i][0]=$attack[1];
		$attackActions[$i][1]=$attack[2];
	Next
	trace("$numAttackAtions:"&$numAttackAtions)
EndFunc


