#include-once
;#include <utils.au3>
Func getCardInfo($file,ByRef $ready,ByRef $cost,ByRef $hp,ByRef $hit)
Local $ret=DllCall("PHashDll.dll","str","_getCardInfo@4","str",$file);
if  (Not @error) And IsArray($ret) Then
	Local $r=$ret[0];
	$retArr=StringSplit($r,"|");
	$ready=$retArr[2];retArr[0]=length, retArr[1]=(xxx,xxx,xxx)
	$cost=$retArr[3];
	$hp=$retArr[4];
	$hit=$retArr[5];
	;trace("count:"&$retArr[6])
	return True
EndIf
return False;
EndFunc

Func parseImg($file)
	Local $hDll=DllOpen("ParseCardsDll.dll");
Local $ret;
$ret=DllCall($hDll,"str","_parseImg@4","str",$file);
if  (Not @error) And IsArray($ret) Then
	Local $r=$ret[0];
	DllClose($hDll)
	return $r
EndIf
DllClose($hDll)
return "0"
EndFunc

Func parseInt($file)
	Local $hDll=DllOpen("ParseCardsDll.dll");
Local $ret;
$ret=DllCall($hDll,"int","_parseInt@4","str",$file);
if  (Not @error) And IsArray($ret) Then
	Local $r=$ret[0];
	DllClose($hDll)
	return $r
EndIf
DllClose($hDll)
return -1
EndFunc

Func getHash($file)
Local $hash=-1;
Local $ret=DllCall("PHashDll.dll","UINT64","_getHash@4","str",$file);
if  (Not @error) And IsArray($ret) Then
	$hash=$ret[0];
EndIf
return $hash;
EndFunc

Func getBinDiff($a,$b)
Local $r=-1;
Local $ret=DllCall("PHashDll.dll","int","_getBinDiff@16","UINT64",$a,"UINT64",$b);
if  (Not @error) And IsArray($ret) Then
	$r=$ret[0];
EndIf
return $r;
EndFunc

Func isDiffImg($f1,$f2,$thre=5)
Local $r=-1;
Local $ret=DllCall("PHashDll.dll","int","_isDiffImg@12","str",$f1,"str",$f2,"int",$thre);
if  (Not @error) And IsArray($ret) Then
	$r=$ret[0];
EndIf
return $r;
EndFunc