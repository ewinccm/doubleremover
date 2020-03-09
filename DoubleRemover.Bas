/'
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
# Copyright (c) 2008 Edwin Pelleng
# See "gnu.txt" for details
# You must set path to FreeBASIC compiler the GNU BASIC COMPILER
# If you not have the FreeBASIC compiler, you can download at http://www.freebasic.net
'/

#include once "windows.bi"
#Include Once "win/commdlg.bi"
#Include Once "win/shlwapi.bi"
#Include Once "file.bi"
#Include Once "crt/stdio.bi"
#Include Once "crt/win32/stdlib.bi"

#Include "DoubleRemover.bi"

#Inclib "crc32"

#Define version "0.2 ALPHA 2"

declare function DlgProc(byval hWnd as HWND, byval uMsg as UINT, byval wParam as WPARAM, byval lParam as LPARAM) as integer
'''
''' Program start
'''

	''
	'' Create the Dialog
	''
	'set crc32 method to default
	scantype=SCAN_CRC
	'	
	SetErrorMode(SEM_NOGPFAULTERRORBOX) 'no error box if application error
	InitCommonControls
	hInstance=GetModuleHandle(NULL)
	DialogBoxParam(hInstance, Cast(zstring ptr,IDD_DLG1), NULL, @DlgProc, NULL)
	''
	'' Program has ended
	''

	ExitProcess(0)
	end

'''
''' Program end
'''
Sub verify
Dim buff As ZString*MAX_PATH
	SetDlgItemText(hFind,1104,"Step 2: Verifycation files...")
	GetDlgItemText(hFind,1002,buff,SizeOf(buff))
	listfiles(buff,0,1)
	'
	EnableWindow(GetDlgItem(hFind,1008),TRUE)
	EnableWindow(GetDlgItem(hFind,1009),FALSE)
	'
	SetDlgItemText(hFind,1104,"(idle)")
	SetDlgItemText(hFind,1005,"Finish scan...")
End Sub

Sub scanning
Dim As ZString*MAX_PATH buff
Dim As ZString*64 lb

Dim vthread As Any ptr
	sprintf(lb,!"Start scan: %s - %s",Time,Date)
	SendDlgItemMessage(hFind,1105,LB_ADDSTRING,0,Cast(LPARAM,StrPtr(lb)))
	'
	EnableWindow(GetDlgItem(hFind,1008),FALSE)
	EnableWindow(GetDlgItem(hFind,1009),TRUE)
	'
	SetDlgItemText(hFind,1104,"Step 1: Identify files...")
	GetDlgItemText(hFind,1002,buff,SizeOf(buff))
	listfiles(buff,0,0)
	vthread=ThreadCreate(@verify,0)
End Sub

Function Find(ByVal hWin As HWND,ByVal uMsg As UINT,ByVal wParam As WPARAM,ByVal lParam As LPARAM) As Integer
	Dim As Long id, Event, x, y
	Dim hMainDlg As HWND
	Dim ts As TCITEM
	Dim sthread As Any ptr

	Select Case uMsg
		Case WM_INITDIALOG
			hFind=hWin
		Case WM_CLOSE
			EndDialog(hWin, 0)
		Case WM_COMMAND
			id=LoWord(wParam)
			Event=HiWord(wParam)
			Select Case id
				Case 1003
					PathSelect
				Case 1008
					Dim buff As ZString*MAX_PATH
					'Progress bar reset
					i=0:bar=0:total=0
					'
					GetDlgItemText(hWin,1002,buff,SizeOf(buff))
					If lstrlen(buff)=0 Then
						If PathSelect=FALSE Then GoTo cancel
					EndIf
					kill"temp.tmp" 'delete the old temporary file
					StopScan=FALSE
					sthread=ThreadCreate(@scanning,0)
					cancel:
					'nothing
				Case 1009
					Dim As ZString*64 lb
					sprintf(lb,!"Terminate scan: %s - %s",Time,Date)
					SendDlgItemMessage(hWin,1105,LB_ADDSTRING,0,Cast(LPARAM,StrPtr(lb)))
					StopScan=TRUE
			End Select
		Case Else
			Return FALSE
			'
	End Select
	Return TRUE
End Function

Function Options(ByVal hWin As HWND,ByVal uMsg As UINT,ByVal wParam As WPARAM,ByVal lParam As LPARAM) As Integer
	Dim As Long id, Event, x, y
	Dim hMainDlg As HWND
	Dim ts As TCITEM

	Select Case uMsg
		Case WM_INITDIALOG
			hOptions=hWin
			CheckDlgButton(hWin,1202,BST_CHECKED)
		Case WM_CLOSE
			EndDialog(hWin, 0)
		Case WM_COMMAND
			id=LoWord(wParam)
			Event=HiWord(wParam)
			Select Case id
				Case 1201
					scantype=SCAN_SIZE
				Case 1202
					scantype=SCAN_CRC
				Case 1203
					scantype=SCAN_DATE
				Case 1204
					scantype=SCAN_NAME
			End Select
		Case Else
			Return FALSE
			'
	End Select
	Return TRUE
End Function

Function About(ByVal hWin As HWND,ByVal uMsg As UINT,ByVal wParam As WPARAM,ByVal lParam As LPARAM) As Integer
	Dim As Long id, Event, x, y
	Dim hMainDlg As HWND
	Dim ts As TCITEM
	Dim rsrc As HRSRC 
	Dim buff As ZString*128
	
	Select Case uMsg
		Case WM_INITDIALOG
			hAbout=hWin
			rsrc = FindResource(0, "GNU", RT_RCDATA)
			If rsrc Then 
				Dim hg As HGLOBAL 
				Dim As Any ptr textdata
				hg = LoadResource(hInstance, rsrc)
				textdata = LockResource(hg)
				SetDlgItemText(hWin,1301,textdata)
			EndIf
			sprintf(buff,!"DoubleRemover ver. %s\n(c)2008 Edwin R. Pelleng\ne-mail: ewin_p@eprojex.890m.com\nweb: http://eprojex.890m.com",version)
			SetDlgItemText(hWin,1302,buff)
		Case WM_CLOSE
			EndDialog(hWin, 0)
		Case WM_COMMAND
			id=LoWord(wParam)
			Event=HiWord(wParam)
			Select Case id
				Case -1
			End Select
		Case Else
			Return FALSE
			'
	End Select
	Return TRUE
End Function


function DlgProc(byval hWin as HWND,byval uMsg as UINT,byval wParam as WPARAM,byval lParam as LPARAM) as integer
	dim as long id, event, x, y
	Dim hStatic As HWND
	Dim ts As TCITEM
	select case uMsg
		case WM_INITDIALOG
			hWinMain=hWin
			hStatic=GetDlgItem(hWin,1005)
			ts.lParam=Cast(lparam,CreateDialogParam(hInstance,Cast(ZString ptr,1100),hStatic,@Find,NULL))
			SendMessage(hStatic,TCM_INSERTITEM,0,Cast(LPARAM,@ts))
			'set dlg icon
			SendMessage(hWin,WM_SETICON,0,Cast(LPARAM,LoadIcon(hInstance,"TWINS")))
			'
			F=TRUE:O=FALSE:A=FALSE
		case WM_CLOSE
			EndDialog(hWin, 0)
			'
		case WM_COMMAND
			id=loword(wParam)
			event=hiword(wParam)
			select case id
				Case 1001
					ShowWindow(hOptions,SW_HIDE)
					ShowWindow(hAbout,SW_HIDE)
					If F=TRUE then
						ShowWindow(hFind,SW_SHOW)
					Else
						F=TRUE
						hStatic=GetDlgItem(hWin,1005)
						ts.lParam=Cast(lparam,CreateDialogParam(hInstance,Cast(ZString ptr,1100),hStatic,@Find,NULL))
						SendMessage(hStatic,TCM_INSERTITEM,0,Cast(LPARAM,@ts))
					endif
					'
					EnableWindow(GetDlgItem(hWin,1001),FALSE)
					EnableWindow(GetDlgItem(hWin,1002),TRUE)
					EnableWindow(GetDlgItem(hWin,1003),TRUE)
					'
				Case 1002
					ShowWindow(hFind,SW_HIDE)
					ShowWindow(hAbout,SW_HIDE)
					If O=TRUE then
						ShowWindow(hOptions,SW_SHOW)
					Else
						O=TRUE
						hStatic=GetDlgItem(hWin,1005)
						ts.lParam=Cast(lparam,CreateDialogParam(hInstance,Cast(ZString ptr,1200),hStatic,@Options,NULL))
						SendMessage(hStatic,TCM_INSERTITEM,0,Cast(LPARAM,@ts))
					endif
					EnableWindow(GetDlgItem(hWin,1001),TRUE)
					EnableWindow(GetDlgItem(hWin,1002),FALSE)
					EnableWindow(GetDlgItem(hWin,1003),TRUE)
				Case 1003
					ShowWindow(hFind,SW_HIDE)
					ShowWindow(hOptions,SW_HIDE)
					If A=TRUE then
						ShowWindow(hAbout,SW_SHOW)
					Else
						A=TRUE
						hStatic=GetDlgItem(hWin,1005)
						ts.lParam=Cast(lparam,CreateDialogParam(hInstance,Cast(ZString ptr,1300),hStatic,@About,NULL))
						SendMessage(hStatic,TCM_INSERTITEM,0,Cast(LPARAM,@ts))
					endif
					EnableWindow(GetDlgItem(hWin,1001),TRUE)
					EnableWindow(GetDlgItem(hWin,1002),TRUE)
					EnableWindow(GetDlgItem(hWin,1003),FALSE)
				case 1004
					EndDialog(hWin, 0)
					'
			end select
		case else
			return FALSE
			'
	end select
	return TRUE

end function
