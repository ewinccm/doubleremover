# DoubleRemover
# Copyright (C) 2008 Edwin Pelleng
# http://eprojex.890m.com
# 
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
# 
# Edwin Pelleng(ewin_p@eprojex.890m.com)
#
#  Copyright (c) 2008 Edwin Pelleng
# See "gnu.txt" for details
# You must set path to FreeBASIC compiler the GNU BASIC COMPILER
# If you not have the FreeBASIC compiler, you can download at http://www.freebasic.net

DoubleRemover.exe:
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