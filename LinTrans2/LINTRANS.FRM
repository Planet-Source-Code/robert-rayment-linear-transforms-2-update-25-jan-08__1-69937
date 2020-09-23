VERSION 5.00
Object = "{F9043C88-F6F2-101A-A3C9-08002B2F49FB}#1.2#0"; "COMDLG32.OCX"
Begin VB.Form Form1 
   AutoRedraw      =   -1  'True
   BackColor       =   &H00E0E0E0&
   BorderStyle     =   1  'Fixed Single
   Caption         =   "Form1"
   ClientHeight    =   7545
   ClientLeft      =   150
   ClientTop       =   600
   ClientWidth     =   10350
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   503
   ScaleMode       =   3  'Pixel
   ScaleWidth      =   690
   StartUpPosition =   2  'CenterScreen
   Begin VB.CommandButton cmdTransform 
      BackColor       =   &H00E0E0E0&
      Caption         =   "TRANSFORM"
      Height          =   315
      Left            =   3840
      TabIndex        =   13
      Top             =   45
      Width           =   2535
   End
   Begin VB.PictureBox Pic 
      AutoRedraw      =   -1  'True
      BackColor       =   &H00FFFFFF&
      BorderStyle     =   0  'None
      Height          =   3075
      Index           =   6
      Left            =   6885
      ScaleHeight     =   205
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   204
      TabIndex        =   6
      Top             =   4185
      Width           =   3060
   End
   Begin VB.PictureBox Pic 
      AutoRedraw      =   -1  'True
      BackColor       =   &H00FFFFFF&
      BorderStyle     =   0  'None
      Height          =   3075
      Index           =   5
      Left            =   3585
      ScaleHeight     =   205
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   204
      TabIndex        =   5
      Top             =   4185
      Width           =   3060
   End
   Begin VB.PictureBox Pic 
      AutoRedraw      =   -1  'True
      BackColor       =   &H00FFFFFF&
      BorderStyle     =   0  'None
      Height          =   3075
      Index           =   4
      Left            =   360
      ScaleHeight     =   205
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   204
      TabIndex        =   4
      Top             =   4185
      Width           =   3060
   End
   Begin MSComDlg.CommonDialog CommonDialog1 
      Left            =   9825
      Top             =   3300
      _ExtentX        =   847
      _ExtentY        =   847
      _Version        =   393216
   End
   Begin VB.PictureBox Pic 
      AutoRedraw      =   -1  'True
      AutoSize        =   -1  'True
      BackColor       =   &H00FFFFFF&
      Height          =   870
      Index           =   0
      Left            =   9075
      ScaleHeight     =   810
      ScaleWidth      =   1725
      TabIndex        =   3
      Top             =   3075
      Width           =   1785
   End
   Begin VB.PictureBox Pic 
      AutoRedraw      =   -1  'True
      BackColor       =   &H00FFFFFF&
      BorderStyle     =   0  'None
      Height          =   3075
      Index           =   3
      Left            =   6900
      ScaleHeight     =   205
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   204
      TabIndex        =   2
      Top             =   645
      Width           =   3060
   End
   Begin VB.PictureBox Pic 
      AutoRedraw      =   -1  'True
      BackColor       =   &H00FFFFFF&
      BorderStyle     =   0  'None
      Height          =   3015
      Index           =   2
      Left            =   3705
      ScaleHeight     =   201
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   200
      TabIndex        =   1
      Top             =   615
      Width           =   3000
   End
   Begin VB.PictureBox Pic 
      AutoRedraw      =   -1  'True
      BackColor       =   &H00FFFFFF&
      BorderStyle     =   0  'None
      Height          =   3000
      Index           =   1
      Left            =   420
      ScaleHeight     =   200
      ScaleMode       =   3  'Pixel
      ScaleWidth      =   200
      TabIndex        =   0
      Top             =   645
      Width           =   3000
   End
   Begin VB.Label Label2 
      Caption         =   "Part wrapping for these three :-"
      Height          =   195
      Left            =   285
      TabIndex        =   14
      Top             =   3720
      Width           =   2730
   End
   Begin VB.Label Label1 
      BackColor       =   &H00E0E0E0&
      Caption         =   "Source"
      Height          =   225
      Index           =   6
      Left            =   7905
      TabIndex        =   12
      Top             =   3945
      Width           =   720
   End
   Begin VB.Label Label1 
      BackColor       =   &H00E0E0E0&
      Caption         =   "Source"
      Height          =   225
      Index           =   5
      Left            =   4770
      TabIndex        =   11
      Top             =   3945
      Width           =   765
   End
   Begin VB.Label Label1 
      BackColor       =   &H00E0E0E0&
      Caption         =   "Source"
      Height          =   225
      Index           =   4
      Left            =   1290
      TabIndex        =   10
      Top             =   3930
      Width           =   765
   End
   Begin VB.Label Label1 
      BackColor       =   &H00E0E0E0&
      Caption         =   "Source"
      Height          =   225
      Index           =   3
      Left            =   7800
      TabIndex        =   9
      Top             =   450
      Width           =   765
   End
   Begin VB.Label Label1 
      BackColor       =   &H00E0E0E0&
      Caption         =   "Source"
      Height          =   225
      Index           =   2
      Left            =   4695
      TabIndex        =   8
      Top             =   390
      Width           =   1050
   End
   Begin VB.Label Label1 
      BackColor       =   &H00E0E0E0&
      Caption         =   "Source"
      Height          =   225
      Index           =   1
      Left            =   1260
      TabIndex        =   7
      Top             =   405
      Width           =   765
   End
   Begin VB.Menu File 
      Caption         =   "Open BMP, GIF or JPG File"
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
' LinTrans.frm  by Robert Rayment 16/3/01
' Re-worked to speed up & make more useable. 20 Jan 2008

'Update 25/1/08

' Simplified CommonDialog info

'Update 23/1/08

' Some redundant debugging maths lines removed.

Option Explicit


' Prog to map an image rectangle onto a
' non-re-entrant quadrilateral, circle,
' cylinder, right-circular cone & a sphere.

' NB All these transforms are compressing so no
' holes will appear and can go from source to
' destination.

' For magnified images would need to work from
' all destination points to get source.

Private PathSpec$  'App path
Private PathName$
Private InitialDir$
Private FileSpec$
Private FileName$

Private Sub cmdTransform_Click()
'' Source coords
'Public x1s As Single, y1s As Single, x2s As Single, y2s As Single
'' destination coords
'Public x1d As Single, y1d As Single, x2d As Single, y2d As Single
'Public x3d As Single, y3d As Single, x4d As Single, y4d As Single
'' Circle centre & radius
'Public xcd As Single, ycd As Single, zradius As Single
'' Cylinder length & cyclinder or cone axis angle
'Public zL As Single, zang As Single
'' Cone height
'Public zH As Single
Dim X1 As Single
Dim Y1 As Single
Dim X2 As Single
Dim Y2 As Single
Dim X3 As Single
Dim Y3 As Single
Dim X4 As Single
Dim Y4 As Single

   If Len(FileSpec$) = 0 Then Exit Sub
   
   ' These inputs & outputs could be automated
   ' Full size input rectangle  (s for source)
   x1s = 0: y1s = 0: x2s = 199: y2s = 199

'========================================================================
   ' Non re-entrant output quadrilateral (Clockwise)
   ' x1d,y1d tied to top-left of image (d for destination)
   x1d = 90: y1d = 100:     x2d = 110: y2d = 100
   x4d = 10: y4d = 170:     x3d = 190: y3d = 160
   
   Map2Quadrilateral Pic(2) 'x1s, y1s, x2s, y2s, x1d, y1d, x2d, y2d, x3d, y3d, x4d, y4d
   
   ' THE FOLLOWING COULD BE OMITTED
   ' Show destination quadrilateral
   Pic(2).Line (x1d, y1d)-(x2d, y2d)
   Pic(2).Line (x2d, y2d)-(x3d, y3d)
   Pic(2).Line (x3d, y3d)-(x4d, y4d)
   Pic(2).Line (x4d, y4d)-(x1d, y1d)
'========================================================================
   
   ' Circle center & radius
   xcd = 100: ycd = 100: zradius = 90
   
   Map2Circle Pic(3) 'x1s, y1s, x2s, y2s, xcd, ycd, zradius
   
   ' THE FOLLOWING COULD BE OMITTED
   ' Show destination circle
   Pic(3).Circle (xcd, ycd), zradius
'========================================================================

   ' Cylinder coords, end radius, Length & axis angle
   xcd = 60: ycd = 60: zradius = 40: zL = 120: zang = pi# / 4
   
   Map2Cylinder Pic(4) 'x1s, y1s, x2s, y2s, xcd, ycd, zradius, zL, zang
   
   ' THE FOLLOWING COULD BE OMITTED
   ' Show destination cylinder
   X1 = xcd + zradius * Cos(zang)
   Y1 = ycd - zradius * Sin(zang)
   X2 = X1 + zL * Cos(zang)
   Y2 = Y1 + zL * Sin(zang)
   X4 = xcd - zradius * Cos(zang)
   Y4 = ycd + zradius * Sin(zang)
   X3 = X4 + zL * Cos(zang)
   Y3 = Y4 + zL * Sin(zang)
   Pic(4).Line (X1, Y1)-(X2, Y2)
   Pic(4).Line (X2, Y2)-(X3, Y3)
   Pic(4).Line (X3, Y3)-(X4, Y4)
   Pic(4).Line (X4, Y4)-(X1, Y1)
'========================================================================

   ' Cone coords, end radius, Height & axis angle
   xcd = 70: ycd = 130: zradius = 60: zH = 140: zang = -pi# / 4
   
   Map2Cone Pic(5) 'x1s, y1s, x2s, y2s, xcd, ycd, zradius, zH, zang
   
   ' THE FOLLOWING COULD BE OMITTED
   ' Show destination cone
   X1 = xcd + zradius * Cos(zang)
   Y1 = ycd - zradius * Sin(zang)
   X4 = xcd - zradius * Cos(zang)
   Y4 = ycd + zradius * Sin(zang)
   X2 = xcd + zH * Cos(zang)
   Y2 = ycd + zH * Sin(zang)
   Pic(5).Line (X1, Y1)-(X2, Y2)
   Pic(5).Line (X2, Y2)-(X4, Y4)
   Pic(5).Line (X4, Y4)-(X1, Y1)
'========================================================================

   ' Sphere center & radius
   xcd = 100: ycd = 100: zradius = 90
   
   Map2Sphere Pic(6) 'x1s, y1s, x2s, y2s, xcd, ycd, zradius
   
   ' THE FOLLOWING COULD BE OMITTED
   ' Show destination circle
   Pic(6).Circle (xcd, ycd), zradius
End Sub

Private Sub File_Click()
' Open a image file and transfer to picDATAORG()
' Public picwidth As Long
' Public picheight  As Long

Dim Title$
Dim Choice$
Dim i As Long
   
Dim mHDC  As Long
Dim mBMPold As Long
   
   On Error GoTo cancelload
   
   Title$ = "Get a BMP, GIF or JPG file"
   Choice$ = "*.BMP,*.GIF,*.JPG|*.BMP;*.GIF;*.JPG"
   With CommonDialog1
      .DialogTitle = Title$
      .CancelError = True
      .Filter = Choice$
      .InitDir = InitialDir$
      .FileName = ""
      .ShowOpen
      FileSpec$ = .FileName
   End With
   
   If Len(FileSpec$) = 0 Then Exit Sub
   
   InitialDir$ = FileSpec$
   Caption = "Linear Transforms   " & CommonDialog1.FileTitle
   
   'Pic(0).AutoSize = True  ' Done @ Form_Load
   Pic(0).Picture = LoadPicture(FileSpec$)
   GetObject Pic(0).Image, Len(PicInfo), PicInfo
   
   picwidth = PicInfo.bmWidth
   picheight = PicInfo.bmHeight
   
   'Stretch whole Image onto Pic(1) from Pic(0)
   SetStretchBltMode Pic(1).hdc, HALFTONE
   StretchBlt Pic(1).hdc, 0, 0, 200, 200, _
      Pic(0).hdc, 0, 0, picwidth, picheight, SRCCOPY
   Pic(1).Refresh
   For i = 2 To 6
      Pic(i).Cls
   Next i
   
   picwidth = Pic(1).Width
   picheight = Pic(1).Height
   
   ' Get PIC(1).Image pixels to PICDATAORG()
   ReDim picDATAORG(0 To 3, 0 To picwidth - 1, 0 To picheight - 1)
   ' Public BHI As BITMAPINFOHEADER
   With BHI
      .biSize = 40
      .biPlanes = 1
      .biWidth = picwidth
      .biHeight = picheight
      .biBitCount = 32
   End With
   mHDC = CreateCompatibleDC(0)
   mBMPold = SelectObject(mHDC, Pic(1).Image)
   If GetDIBits(mHDC, Pic(1).Image, 0, picheight, picDATAORG(0, 0, 0), BHI, 0) = 0 Then
      MsgBox "DIB ERROR", vbCritical, "LinTran"
      FileSpec$ = ""
      Exit Sub
   End If
   SelectObject mHDC, mBMPold
   DeleteDC mHDC
   Exit Sub
'============
cancelload:
Close
FileSpec$ = ""
End Sub

Private Sub Form_Load()
   Caption = "Linear Transforms"
   Pic(0).AutoSize = True
   Pic(0).Visible = False
   
   ' Set up PictureBoxes
   PositionPicBoxes
   
   Show
   
   ' Get app path
   PathSpec$ = App.Path
   If Right$(PathSpec$, 1) <> "\" Then PathSpec$ = PathSpec$ & "\"
   InitialDir$ = PathSpec$

End Sub

Private Sub PositionPicBoxes()
Dim i As Long
   For i = 1 To 6
      With Pic(i)
         .Width = 200
         .Height = 200
         If i <= 3 Then
            .Top = 42
            .Left = 20 + (i - 1) * 220
         Else
            .Top = 282
            .Left = 20 + (i - 4) * 220
         End If
      End With
      Line (Pic(i).Left - 1, Pic(i).Top - 1)-(Pic(i).Left + 200, Pic(i).Top + 200), 0, B
      Label1(i).Top = Pic(i).Top - Label1(i).Height - 2
   Next i
   Label1(1).Caption = "Source"
   Label1(2).Caption = "Quadrilateral"
   Label1(3).Caption = "Circle"
   Label1(4).Caption = "Cylinder"
   Label1(5).Caption = "Cone"
   Label1(6).Caption = "Sphere"
End Sub

