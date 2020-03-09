set path=C:\Program Files\FreeBASIC;C:\FreeBASIC;%windir%
cls
@echo	DoubleRemover Makefile
@echo	(c)2008 Edwin Pelleng
@echo	ewin_p@eprojex.890m.com
@echo	===================================
@echo	COMPILING...
fbc -s gui -w 2 DoubleRemover.Bas DoubleRemover.rc
@echo	COMPRESSING...
if exist upx.exe upx --best DoubleRemover.exe
@echo	CLEANING...
del *.obj