#include <Debug.au3>
$ohit=5
$ohp=4
Local $myDeckCards[]=[4,5]
;Local $otherDeckCards[]=[3,2]
Local $otherDeckCards[]=[4,5]

Local $ret=0.0;
		$ret=$ohp+$ohit*1.5
		Func getHitGain($i,$j)
	;mycard[$i] hit othercard[$j].
	;if other die +=11
	;if my die -=hithp/2
	;other +=other:hp+1.5*hit.
	$mhit=$myDeckCards[0]
	$mhp=$myDeckCards[1]
	$ohit=$otherDeckCards[0]
	$ohp=$otherDeckCards[1]
	Local $ret=0.0;
	$ret=$ohp+Number($ohit,3)*1.5
	If $mhit>=$ohp Then
	$ret+=11.0
	EndIf
	If $mhp<=$ohit Then
	$ret-=$mhit+$mhp*0.5
	EndIf
	;trace("gain:"&$ret)
	return $ret
EndFunc

_DebugSetup();
		_DebugOut("gain:"&getHitGain(0,1))
