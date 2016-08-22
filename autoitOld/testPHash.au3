#include <Debug.au3>
#include <utils.au3>
setupDebug()
init()

Func init()
	;ShellExecute("getDll.bat");
		;Global $hdll=DllOpen("PHashDll.dll");
		;trace("error:"&@error)
		;trace("hdll:"&$hdll)
		;trace(fnPHashDll())
		;trace(fnPHashDllS("abc"))
		;trace(getHash("a.bmp"))
		;trace(getHash(".\a.bmp"))
		;trace(getHash("b.bmp"));
		;DllClose($hdll);
		$f1="h10.bmp"
		$f2="h6.bmp"
		$f3="h2.bmp";h5==h8
		$f2=$f3
		$a=getHash($f1);
		$b=getHash($f2);
		$c= getBinDiff($a,$b)
		trace("a:"&$a)
		trace("b:"&$b)
		trace("c:"&$c)
		trace(isDiffImg($f1,$f2))
EndFunc





Func dllcallErrorDect()
If @error Then
	Switch @error
		case 1
			_DebugReport("unable to use the DLL file")
		case 2
			_DebugReport("unknown [return type]")
		case 3
			_DebugReport("[function] not found in the DLL file")
		case 4
			_DebugReport("bad number of parameters")
		case 5
			_DebugReport("bad parameter")
	EndSwitch
	exit
	EndIf
EndFunc