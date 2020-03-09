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


#Define IDD_DLG1 1000 
#Define SCAN_SIZE 1
#Define SCAN_CRC 2
#Define SCAN_DATE 3
#Define SCAN_NAME 4

#Define SCANBYNAME 6

Declare Function crc32(szfile As String) As Integer

Dim Shared hInstance As HINSTANCE
Dim Shared As HWND hFind,hOptions,hAbout,hWinMain,hAlert
Dim Shared As Boolean StopScan,F,O,A
Dim Shared As Integer scantype,bar,total,i,ver
Dim Shared As ZString*MAX_PATH f1,f2

Function Alert(ByVal hWin As HWND,ByVal uMsg As UINT,ByVal wParam As WPARAM,ByVal lParam As LPARAM) As Integer
	Dim As Long id, Event, x, y
	Dim ts As TCITEM
	Dim rsrc As HRSRC 
	Select Case uMsg
		Case WM_INITDIALOG
			Dim As ZString*32 buff,txt
			'
			hAlert=hWin
			SetDlgItemText(hWin,1401,f1)
			SetDlgItemText(hWin,1403,f2)
			'
			If ((FileExists(f1)<>FALSE) And (FileExists(f2)<>FALSE)) Then
				EndDialog(hWin,0)
			EndIf
			'
			Select Case scantype
				Case SCAN_CRC
					buff="crc32sum"
				Case SCAN_SIZE
					buff="size"
				Case SCAN_DATE
					buff="time created"
				Case SCAN_NAME
					buff="similliar name"
			End Select
			sprintf(txt,!"is same %s with:",buff)
			SetDlgItemText(hWin,1402,txt)
		Case WM_CLOSE
			EndDialog(hWin, 0)
		Case WM_COMMAND
			id=LoWord(wParam)
			Event=HiWord(wParam)
			Select Case id
				Case 1404
					Dim As ZString*MAX_PATH txt,buff
					GetDlgItemText(hWin,1401,txt,SizeOf(txt))
					Kill(txt)
					sprintf(buff,"%s is deleted!",txt)
					SendDlgItemMessage(hWinMain,1105,LB_ADDSTRING,0,Cast(LPARAM,StrPtr(buff)))
					EndDialog(hWIn,0)
				Case 1405
					Dim As ZString*MAX_PATH txt,buff
					GetDlgItemText(hWin,1403,txt,SizeOf(txt))
					Kill(txt)
					sprintf(buff,"%s is deleted!",txt)
					SendDlgItemMessage(hWinMain,1105,LB_ADDSTRING,0,Cast(LPARAM,StrPtr(buff)))
					EndDialog(hWIn,0)
				Case 1406
					stopscan=TRUE
					EndDialog(hWIn,0)
				Case 1407
					EndDialog(hWIn,0)
			End Select
		Case Else
			Return FALSE
			'
	End Select
	Return TRUE
End Function

Function dbscan(db As String,scaninfo As String,fname As String)As Boolean
Dim f As Integer
Dim As ZString*MAX_PATH fn,sum

	f=FreeFile
	Close #1
	Open db For Input As #f
	While Not Eof(f)
		Input #f,fn,sum
		If fn<>fname Then
			If ucase(scaninfo)=UCase(sum) Then 
				f1=fn
				f2=fname
				Return TRUE
			EndIf
		EndIf
	Wend
	Close #f
End Function


Sub verifyscan(fname As String,scaninfo As Integer)
Dim ret As Boolean
Dim As ZString*MAX_PATH buff

	If ver=SCANBYNAME Then
  		_splitpath(fname,NULL,NULL,buff,NULL)
		ret=dbscan("temp.tmp",buff,fname)
	Else
		ret=dbscan("temp.tmp",Str(scaninfo),fname)
	EndIf

	If ret=TRUE Then
		DialogBoxParam(hInstance, Cast(zstring ptr,1400), hWinMain, @Alert, NULL)
	EndIf
End Sub

Sub record(fname As String,info As Integer)
Dim As ZString*MAX_PATH buff,oname
	If ver=SCANBYNAME Then
  		_splitpath(fname,NULL,NULL,oname,NULL)
		buff=oname
	Else
		buff=Str(info)
	EndIf
	
	
	Open "temp.tmp" For Append As #1
	Print #1,""""+fname+""","""+buff+""""
	Close #1
End Sub

Sub listfiles (path As String, depth As Integer,Steps As Integer)
Const allfiles = 55
Dim As Integer whichfolder, a
Dim As String folders(1 To 128), temp,fname
				Dim As LPFILETIME tcreate,taccess,twrite
				Dim hFile As HFILE
temp = Dir(path + "\*", allfiles)

	Do
		While temp = "." Or temp = ".."
			temp = Dir("", allfiles)
		Wend
		If (temp = "") Or (StopScan=TRUE) Then Exit Sub
		
		Open path + "\" + temp For Input As #2
		If Err Then
			whichfolder += 1: folders(whichfolder) = path + "\" + temp
		Else
			fname=path+"\"+temp
			SetDlgItemText(hFind,1005,fname)
			Select Case scantype

				Case SCAN_CRC
					ver=crc32(fname)
				Case SCAN_SIZE
					ver=FileLen(fname)
				Case SCAN_DATE
					'not avaliable on BETA
				Case SCAN_NAME
					ver=SCANBYNAME
			End Select
			
			If steps=0 Then
				total=total+1
				record(fname,ver)
			Else
				i=i+1
				bar=i/total*100
				'
				SetDlgItemText(hFind,1102,Str(bar)+"%")
				'
				SendDlgItemMessage(hFind,1006,PBM_SETPOS,bar,bar)
				verifyscan(fname,ver)
			EndIf
			Close #2
		End If
		
		temp = Dir("", allfiles)
	Loop Until temp = ""

	For a = 1 To whichfolder
		listfiles(folders(a), depth + 1,steps)
	Next a
End Sub

Function PathSelect As Boolean
Dim As ZString*MAX_PATH sPath,buff
Dim structFolder As BROWSEINFO
Dim ret As HANDLE
	structFolder.hwndOwner=hFind
	structFolder.lpszTitle = StrPtr("Select folder...")
	ret = SHBrowseForFolder(@structFolder)
	If ret Then
		sPath = String(MAX_PATH, 0)
		SHGetPathFromIDList(ret, sPath)
		CoTaskMemFree(ret)
	End If
	If Len(spath)=3 Then
		SetDlgItemText(hFind,1002,Left(spath,2))
	Else
		SetDlgItemText(hFind,1002,spath)
	EndIf
	If lstrlen(spath)>0 Then
		Return TRUE
	Else
		Return FALSE
	EndIf
End function

