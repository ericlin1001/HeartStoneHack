
Global $dm = ObjCreate("dm.dmsoft")
Global $foobar;

$tt = $dm.Ver()
MsgBox(0, "version:", $tt)

Func setupFoobar()
	$foobar = $dm.CreateFoobarRect($hwnd,10,100,200,250)
EndFunc

Func ptrace($mess)
	$dm.FoobarPrintText($foobar,$mess,"ff0000")
	$dm.FoobarUpdate($foobar)
EndFunc
;$tt= $dm.moveto(100,200)

