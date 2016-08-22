#include-once
#include <Debug.au3>
#include <ImageSearch.au3>
#include <utils.au3>
#include <PHash.au3>
Global Enum $PS_HP,$PS_ARMOUR,$PS_CUR_CRYSTAL,$PS_MAX_CRYSTAL,$PS_NUM_HAND_CARDS,$PS_NUM_DECK_CARDS;
Global Enum $CI_COST,$CI_HIT,$CI_HP,$CI_X,$CI_Y,$CI_IS_MOCK,$CI_IS_READY
Global $myPlayerStatus[6];hp,armour,curCrystal,maxcrystal,numhandCards,numDeckCards
Global $myDeckCards[10][7];cost,hit,hp,x,y,isMock,isready
Global $myHandCards[10][7]
Global $otherPlayerStatus[6];hp,armour,curCrystal,maxcrystal,numhandCards,numDeckCards
Global $otherDeckCards[10][7];cost,hit,hp,x,y,isMock,isready



init()

Func init()
	;trace();
	setupDebug()
	getMainCardInfo("a.bmp")
	;trace("end");
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
;*********parse my*********
$mySA=StringSplit($myS,",");
For $i=0 to 4
$myPlayerStatus[$i]=Int(Number(getRight($mySA[1+$i])))
Next
$myPlayerStatus[5]=Int(Number(getRight($mySA[2+5])))
;parse deck...
$myDeckS=$mySA[8]
;trace("myDeckS:"&$myDeckS)
$myDeckSA=StringSplit($myDeckS,"|");
For $i=1 to $myPlayerStatus[$PS_NUM_DECK_CARDS]
	$deckCardS=$myDeckSA[$i]
	;trace("cur deckCardS:"&$deckCardS);
	$deckCardSA=StringSplit($deckCardS,"/");
For $j=0 to 6
	$myDeckCards[$i-1][$j]=Int(Number(getRight($deckCardSA[$j+1])))
Next
Next
$i=1
;trace("hit/hp:"&$myDeckCards[$i][$CI_HIT]&","&$myDeckCards[$i][$CI_HP])
;trace("x/y:"&$myDeckCards[$i][$CI_X]&","&$myDeckCards[$i][$CI_Y])
;********parse other******
$otherSA=StringSplit($otherS,",");
For $i=0 to 4
$otherPlayerStatus[$i]=Int(Number(getRight($otherSA[1+$i])))
Next
$otherPlayerStatus[5]=Int(Number(getRight($otherSA[2+5])))
;parse deck...
$otherDeckS=$otherSA[8]
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
EndFunc


