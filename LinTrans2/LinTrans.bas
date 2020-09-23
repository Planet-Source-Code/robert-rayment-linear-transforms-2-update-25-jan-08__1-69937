Attribute VB_Name = "Module1"
'LinTrans.bas

Option Explicit

Public Type BITMAP
    bmType As Long
    bmWidth As Long
    bmHeight As Long
    bmWidthBytes As Long
    bmPlanes As Integer
    bmBitsPixel As Integer
    bmBits As Long
End Type
Public Declare Function GetObject Lib "gdi32" Alias "GetObjectA" _
 (ByVal hObject As Long, ByVal nCount As Long, lpObject As Any) As Long
Public PicInfo As BITMAP

Public Declare Function GetStretchBltMode Lib "gdi32.dll" (ByVal hdc As Long) As Long
Public Declare Function SetStretchBltMode Lib "gdi32" _
   (ByVal hdc As Long, ByVal nStretchMode As Long) As Long

Public Const HALFTONE = 4

Public Type BITMAPINFOHEADER ' 40 bytes
   biSize As Long
   biWidth As Long
   biHeight As Long
   biPlanes As Integer
   biBitCount As Integer
   biCompression As Long
   biSizeImage As Long
   biXPelsPerMeter As Long
   biYPelsPerMeter As Long
   biClrUsed As Long
   biClrImportant As Long
End Type
Public BHI As BITMAPINFOHEADER

Public Declare Function StretchDIBits Lib "gdi32.dll" _
   (ByVal hdc As Long, _
   ByVal x As Long, ByVal y As Long, _
   ByVal dx As Long, ByVal dy As Long, _
   ByVal SrcX As Long, ByVal SrcY As Long, _
   ByVal wSrcWidth As Long, ByVal wSrcHeight As Long, _
   ByRef lpBits As Any, _
   ByRef BInfo As BITMAPINFOHEADER, _
   ByVal wUsage As Long, _
   ByVal dwRop As Long) As Long

' For fitting a bitmap into picturebox Pic(1) from Pic(0)
Public Declare Function StretchBlt Lib "gdi32" _
   (ByVal hdc As Long, ByVal x As Long, _
    ByVal y As Long, ByVal nWidth As Long, ByVal nHeight As Long, _
    ByVal hSrcDC As Long, ByVal xSrc As Long, ByVal ySrc As Long, _
    ByVal nSrcWidth As Long, ByVal nSrcHeight As Long, ByVal dwRop As Long) As Long
' rs&=StretchBlt(hdcD,xD,yD,wiD,htD,hdcS,xS,yS,wiS,htS,SRCCOPY)

Public Const SRCCOPY = &HCC0020

Public Declare Function CreateCompatibleDC Lib "gdi32" (ByVal hdc As Long) As Long

Public Declare Function GetDIBits Lib "gdi32" _
   (ByVal aHDC As Long, ByVal hBitmap As Long, ByVal nStartScan As Long, _
    ByVal nNumScans As Long, lpBits As Any, lpBI As BITMAPINFOHEADER, _
    ByVal wUsage As Long) As Long

Public Declare Function SelectObject Lib "gdi32" (ByVal hdc As Long, ByVal hObject As Long) As Long
Public Declare Function DeleteDC Lib "gdi32" (ByVal hdc As Long) As Long

Public Declare Sub FillMemory Lib "kernel32.dll" Alias "RtlFillMemory" _
   (ByRef Destination As Any, ByVal Length As Long, ByVal Fill As Byte)

''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''

' Source data
Public picDATAORG() As Byte
' Destination data to Display
Public picDATA() As Byte

' Source coords
Public x1s As Single, y1s As Single, x2s As Single, y2s As Single
Public picwidth As Long
Public picheight  As Long
' Destination coords
Public x1d As Single, y1d As Single, x2d As Single, y2d As Single
Public x3d As Single, y3d As Single, x4d As Single, y4d As Single
' Circle centre & radius
Public xcd As Single, ycd As Single, zradius As Single
' Cylinder length & cyclinder or cone axis angle
Public zL As Single, zang As Single
' Cone height
Public zH As Single

Public Const pi# = 3.14159265

Public Sub Map2Quadrilateral(Pic As PictureBox) '(x1s, y1s, x2s, y2s, x1d, y1d, x2d, y2d, x3d, y3d, x4d, y4d)
' Rectangular picture to non-re-entrant quadrilateral
' x1s, y1s, x2s, y2s     'Source rectangle (Pic(1))
' x1d, y1d, x2d, y2d, x3d, y3d, x4d, y4d
' ie Destination quadrilateral (clockwise) on Pic(2)
' Will need correcting if not clockwise with
' x1d,y1d tied to x1s,y1s
Dim zmag As Single
Dim zstep As Single
Dim zadL As Single
Dim zadR As Single
Dim zwi As Single
Dim zht As Single
Dim zstepL As Single
Dim zstepR As Single
Dim zdxL As Single
Dim zdyL As Single
Dim zdxR As Single
Dim zdyR As Single
Dim xs As Single
Dim ys As Single
Dim X1 As Single
Dim Y1 As Single
Dim X2 As Single
Dim Y2 As Single
Dim zaxy As Single
Dim zstepxy As Single
Dim zdx As Single
Dim zdy As Single

Dim RB As Byte, GB As Byte, BB As Byte

   ReDim picDATA(0 To 3, 0 To picwidth - 1, 0 To picheight - 1)
   FillMemory picDATA(0, 0, 0), picwidth * picheight * 4, 255   ' ie White
   ' or omit for a black background
   
   
   ' Get approx. magnification (could be refined)
   zmag = Sqr((x1d - x3d) ^ 2 + (y1d - y3d) ^ 2)
   zmag = zmag / Sqr((x1s - x2s) ^ 2 + (y1s - y2s) ^ 2)
   If zmag > 1 Then zstep = 0.2 Else zstep = 0.5
   ' ie decrease zstep if image being magnified
   
   ' Angle of left & right lines
   zadL = zATan2((y4d - y1d), (x4d - x1d))
   zadR = zATan2((y3d - y2d), (x3d - x2d))
   
   zwi = x2s - x1s ' Source width
   zht = y2s - y1s ' Source height
   
   ' Slope step along left & right lines
   zstepL = Sqr((y1d - y4d) ^ 2 + (x1d - x4d) ^ 2) / zht
   zstepR = Sqr((y3d - y2d) ^ 2 + (x3d - x2d) ^ 2) / zht
   
   ' x & y step along left & right lines
   zdxL = zstepL * Cos(zadL)
   zdyL = zstepL * Sin(zadL)
   zdxR = zstepR * Cos(zadR)
   zdyR = zstepR * Sin(zadR)
   
   ' eg y1s = 0:  y2s = 199
   For ys = y1s To y2s Step zstep 'Source y
      ' Move start & end points down
      ' left- & right-hand side of quadrilateral
      X1 = x1d + (ys - y1s) * zdxL
      Y1 = y1d + (ys - y1s) * zdyL
      X2 = x2d + (ys - y1s) * zdxR
      Y2 = y2d + (ys - y1s) * zdyR
      ' Find steps along line (X1,Y1)->(X2,Y2)
      zaxy = zATan2((Y2 - Y1), (X2 - X1))
      zstepxy = Sqr((Y2 - Y1) ^ 2 + (X2 - X1) ^ 2) / zwi
      zdx = zstepxy * Cos(zaxy)
      zdy = zstepxy * Sin(zaxy)
      ' Move along strip
      ' eg x1s = 0: x2s = 199
      For xs = x1s To x2s Step zstep  'Source x
         ' GetPixel from picDATAORG(0 To 3, 0 to picwidth, 0 to picheight)
         ' SetPixel to picDATA
         BB = picDATAORG(0, xs, y2s - ys)
         GB = picDATAORG(1, xs, y2s - ys)
         RB = picDATAORG(2, xs, y2s - ys)
         ' Manipulation of color bytes
         ' could be put here
         picDATA(0, X1, y2s - Y1) = BB
         picDATA(1, X1, y2s - Y1) = GB
         picDATA(2, X1, y2s - Y1) = RB
         
         X1 = X1 + zdx * zstep
         Y1 = Y1 + zdy * zstep
      Next xs
   Next ys

   ' StretchDIBits picDATA to pic(2)
   DISPLAY Pic
   'Pic.Refresh
End Sub

Public Sub Map2Circle(Pic As PictureBox) '(x1s, y1s, x2s, y2s, xcd, ycd, zradius)
' Rectangular picture to circle
' x1s, y1s, x2s, y2s     'Source rectangle (Pic(1))
' xcd, ycd, zradius      'Circle centre & radius on Pic(3)
Dim zmag As Single
Dim zstep As Single
Dim zwi As Single
Dim zht As Single
Dim xs As Single
Dim ys As Single
Dim X1 As Single
Dim Y1 As Single
Dim X2 As Single
Dim zdx As Single
Dim zStepV As Single
Dim zxd As Single

Dim RB As Byte, GB As Byte, BB As Byte
   
   ReDim picDATA(0 To 3, 0 To picwidth - 1, 0 To picheight - 1)
   FillMemory picDATA(0, 0, 0), picwidth * picheight * 4, 255   ' ie White
   
   ' Get approx. magnification (could be refined)
   zmag = 2 * zradius
   zmag = zmag / Sqr((x1s - x2s) ^ 2 + (y1s - y2s) ^ 2)
   If zmag > 1 Then zstep = 0.2 Else zstep = 1
   ' ie decrease zstep if image being magnified
   
   zwi = x2s - x1s ' Source width
   zht = y2s - y1s ' Source height
   
   ' Step along vertical y axis
   zStepV = 2 * zradius / zht
   
   For ys = y1s To y2s Step zstep ' Source y
      ' Find start & end points of next horizontal strip
      zH = zradius ^ 2 - (zradius - (ys - y1s) * zStepV) ^ 2
      If zH >= 0 Then
         zxd = Sqr(zH)
         X1 = xcd - zxd
         X2 = xcd + zxd
         zdx = 2 * zxd / zwi
         Y1 = ycd - zradius + (ys - y1s) * zStepV
         ' Move along strip
         For xs = x1s To x2s Step zstep  ' Source x
            ' GetPixel from picDATAORG(0 To 3, 0 to picwidth, 0 to picheight)
            ' SetPixel to picDATA
            BB = picDATAORG(0, xs, y2s - ys)
            GB = picDATAORG(1, xs, y2s - ys)
            RB = picDATAORG(2, xs, y2s - ys)
            ' Manipulation of color bytes
            ' could be put here
            picDATA(0, X1, y2s - Y1) = BB
            picDATA(1, X1, y2s - Y1) = GB
            picDATA(2, X1, y2s - Y1) = RB
            X1 = X1 + zdx * zstep
         Next xs
      End If
   Next ys
   ' StretchDIBits picDATA to pic(3)
   DISPLAY Pic
   'Pic.Refresh
End Sub

Public Sub Map2Cylinder(Pic As PictureBox) '(x1s, y1s, x2s, y2s, xcd, ycd, zradius, zL, zang)
' Rectangular picture to cylinder
' x1s, y1s, x2s, y2s     'Source rectangle (Pic(1))
' xcd, ycd, zradius      'Circle centre & radius on Pic(4)
'                        'nb viewed edge on
' zL, zang               'Length of cylinder and axis angle
Dim zmag As Single
Dim zstep As Single
Dim zwi As Single
Dim zht As Single
Dim zstepL As Single
Dim xs As Single
Dim ys As Single
Dim X0 As Single
Dim Y0 As Single
Dim X1 As Single
Dim Y1 As Single
Dim X2 As Single
Dim Y2 As Single
Dim X3 As Single
Dim Y3 As Single
Dim X4 As Single
Dim Y4 As Single
Dim zStepxL As Single
Dim zStepyL As Single
Dim zthetastep As Single
Dim ztheta1 As Single
Dim ztheta2 As Single
Dim zdV As Single

Dim RB As Byte, GB As Byte, BB As Byte

   ReDim picDATA(0 To 3, 0 To picwidth - 1, 0 To picheight - 1)
   FillMemory picDATA(0, 0, 0), picwidth * picheight * 4, 255   ' ie White
   
   ' Get approx. magnification (could be refined)
   zmag = zL
   zmag = zmag / Sqr((x1s - x2s) ^ 2 + (y1s - y2s) ^ 2)
   If zmag > 1 Then zstep = 0.2 Else zstep = 0.5
   ' ie decrease zstep if image being magnified
   
   ' Calc destination cylinder coords
   X1 = xcd + zradius * Cos(zang)
   Y1 = ycd - zradius * Sin(zang)
   zwi = x2s - x1s ' Source width
   zht = y2s - y1s ' Source height
   zstepL = zL / zwi ' Step along zL
   zStepxL = zstepL * Cos(zang)  ' Step x & y along zL
   zStepyL = zstepL * Sin(zang)
   
   ' Circular cross-section angle increment
   ' zthetastep = zstep * 2 * pi# / zht 'Show half of BMP on cylinder
   zthetastep = zstep * pi# / zht  'Show whole of BMP on cylinder
   ztheta1 = -pi# / 2 'Starting angle
   ' For ys = y1s To y1s + (0.5 * zht) Step zstep 'Source y 'Top half BMP
   ' For ys = y1s + (0.25 * zht) To y1s + (0.75 * zht) Step zstep 'Source y Middle BMO
   For ys = y1s To y2s Step zstep 'Source y Whole BMP
      X0 = X1
      Y0 = Y1
      For xs = x1s To x2s Step zstepL  ' Source x
         X1 = X0 + (xs - x1s) * zStepxL ' * zstepL
         Y1 = Y0 + (xs - x1s) * zStepyL ' * zstepL
         ' GetPixel from picDATAORG(0 To 3, 0 to picwidth, 0 to picheight)
         ' SetPixel to picDATA
         BB = picDATAORG(0, xs, y2s - ys)
         GB = picDATAORG(1, xs, y2s - ys)
         RB = picDATAORG(2, xs, y2s - ys)
         ' Manipulation of color bytes
         ' could be put here
         picDATA(0, X1, y2s - Y1) = BB
         picDATA(1, X1, y2s - Y1) = GB
         picDATA(2, X1, y2s - Y1) = RB
      Next xs
      
      ztheta2 = ztheta1 + zthetastep
      zdV = zradius * (Sin(ztheta1) - Sin(ztheta2))
      X1 = X0 + zdV * Cos(zang)
      Y1 = Y0 - zdV * Sin(zang)
      ztheta1 = ztheta2
   Next ys

   ' StretchDIBits picDATA to pic(4)
   DISPLAY Pic
   'Pic.Refresh
End Sub

Public Sub Map2Cone(Pic As PictureBox) '(x1s, y1s, x2s, y2s, xcd, ycd, zradius, zH, zang)
' Rectangular picture to right circular cone
' x1s, y1s, x2s, y2s     'Source rectangle (Pic(1))
' xcd, ycd, zradius      'Circle centre & radius on Pic(5)
'                        'nb viewed edge on
' zH, zang               'Height of cone and axis angle
Dim zmag As Single
Dim zstep As Single
Dim zwi As Single
Dim zht As Single
Dim xs As Single
Dim ys As Single
Dim X1 As Single
Dim Y1 As Single
Dim zdx As Single
Dim zdy As Single
Dim X0 As Single
Dim Y0 As Single
Dim zthetastep As Single
Dim ztheta1 As Single
Dim ztheta2 As Single
Dim zdV As Single

Dim zang0 As Single
Dim zradius0 As Single
Dim zangcone As Single
Dim zstepH As Single
Dim zHa As Single
Dim zLa As Single
Dim zrad As Single

Dim RB As Byte, GB As Byte, BB As Byte

   ReDim picDATA(0 To 3, 0 To picwidth - 1, 0 To picheight - 1)
   FillMemory picDATA(0, 0, 0), picwidth * picheight * 4, 255   ' ie White
   
   zang0 = zang
   zradius0 = zradius
   ' Get approx. magnification (could be refined)
   zmag = zH
   zmag = zmag / Sqr((x1s - x2s) ^ 2 + (y1s - y2s) ^ 2)
   If zmag > 1 Then zstep = 0.2 Else zstep = 0.5
   ' ie decrease zstep if image being magnified
   
   ' Calc destination cone coords
   X1 = xcd + zH * Cos(zang0)    ' Coords at point of cone
   Y1 = ycd + zH * Sin(zang0)
   X0 = X1
   Y0 = Y1
   
   zangcone = zATan2(zradius, zH)
   
   zwi = x2s - x1s ' Source width
   zht = y2s - y1s ' Source height
   
   zstepH = zH / zwi ' Step along zH
   
   ' Circular cross-section angle increment
   ' zthetastep = zstep * 2 * pi# / zwi 'Show half of BMP on cone
   zthetastep = zstep * pi# / zwi  ' Show whole of BMP on cone
   
   ' Starting values
   zHa = 0  ' Axis length
   zLa = 0  ' Slant length
   zrad = 0 ' Radius
   zdx = 0  ' Cross section dx
   zdy = 0  ' Cross section dy
   
   ' For ys = y1s To y1s + (0.5 * zht) Step zstep 'Source y 'Top half BMP
   ' For ys = y1s + (0.25 * zht) To y1s + (0.75 * zht) Step zstep 'Source y Middle BMO
   For ys = y1s To y2s Step zstep ' Source y Whole BMP
      ztheta1 = pi# / 2           ' Starting angle for each cross-section
      For xs = x1s To x2s Step zstep  ' Source x
         ztheta2 = ztheta1 + zthetastep
         zdV = zrad * (Sin(ztheta1) - Sin(ztheta2))   ' Distance along cross-section
         zdx = zdV * Sin(zang)   ' Cross-section x & y components
         zdy = zdV * Cos(zang)
         X1 = X1 - zdx     ' Move along cross-section x & y components
         Y1 = Y1 + zdy
         ztheta1 = ztheta2
         ' GetPixel from picDATAORG(0 To 3, 0 to picwidth, 0 to picheight)
         ' SetPixel to picDATA
         BB = picDATAORG(0, xs, y2s - ys)
         GB = picDATAORG(1, xs, y2s - ys)
         RB = picDATAORG(2, xs, y2s - ys)
         ' Manipulation of color bytes
         ' could be put here
         picDATA(0, X1, y2s - Y1) = BB
         picDATA(1, X1, y2s - Y1) = GB
         picDATA(2, X1, y2s - Y1) = RB
      Next xs
      ' Calc new distance down axis, radius & slope
      ' to give new starting X1,Y1
      zHa = zHa + zstepH * zstep
      zrad = zHa * Tan(zangcone)
      zLa = Sqr(zrad ^ 2 + zHa ^ 2)
      X1 = X0 - zLa * Cos(zang + zangcone)
      Y1 = Y0 - zLa * Sin(zang + zangcone)
   Next ys

   ' StretchDIBits picDATA to pic(5)
   DISPLAY Pic
   'Pic.Refresh
End Sub

Public Sub Map2Sphere(Pic As PictureBox) '(x1s, y1s, x2s, y2s, xcd, ycd, zradius)
' NB Not full sphere effect
' Rectangular picture to sphere
' x1s, y1s, x2s, y2s     'Source rectangle (Pic(1))
' xcd, ycd, zradius      'Circle centre & radius on Pic(6)
Dim zmag As Single
Dim zwi As Single
Dim zht As Single
Dim xs As Single
Dim ys As Single
Dim X1 As Single
Dim Y1 As Single
Dim zStepV As Single
Dim zthetastep As Single
Dim ztheta1 As Single
Dim ztheta2 As Single
Dim zdV As Single
Dim zrad As Single

Dim zstepx As Single
Dim zstepy As Single

Dim RB As Byte, GB As Byte, BB As Byte

   ReDim picDATA(0 To 3, 0 To picwidth - 1, 0 To picheight - 1)
   FillMemory picDATA(0, 0, 0), picwidth * picheight * 4, 255   ' ie White
   
   ' Get approx. magnification (could be refined)
   zmag = 2 * zradius
   zmag = zmag / Sqr((x1s - x2s) ^ 2 + (y1s - y2s) ^ 2)
   If zmag > 1 Then
      zstepx = 0.2
      zstepy = 0.2
   Else
      zstepx = 0.3
      zstepy = 0.5
   End If
   ' ie decrease zstep if image being magnified
   
   zwi = x2s - x1s ' Source width
   zht = y2s - y1s ' Source height
   
   ' Step along vertical y axis
   zStepV = 2 * zradius / zht
   
   ' Circular cross-section angle increment
   ' zthetastep = zstepx * 2 * pi# / zwi 'Show half of BMP on cone
   zthetastep = zstepx * pi# / zwi  'Show whole of BMP on cone
   
   For ys = y1s To y2s Step zstepy ' Source y
      ztheta1 = pi# / 2            ' Starting angle for each cross-section
      ' Distance from center to disc
      zH = zradius - (ys - y1s) * zStepV
      ' Radius^2 of cross-section disc
      zrad = zradius ^ 2 - zH ^ 2
      If zrad >= 0 Then
         zrad = Sqr(zrad)
         ' Find left point of next horizontal disc
         X1 = xcd - zrad
         Y1 = ycd - zH
         
         ' Move along disc
         For xs = x1s To x2s Step zstepx  ' Source x whole BMP
         ' For xs = x1s To x1s + (0.5 * zwi) Step zstepx ' Source x half BMP
         ' For xs = x1s + (0.25 * zwi) To x1s + (0.75 * zwi) Step zstepx 'Source x middle half BMP
            ztheta2 = ztheta1 + zthetastep
            zdV = zrad * (Sin(ztheta1) - Sin(ztheta2))   ' Distance along cross-section
            X1 = X1 + zdV     ' Move along cross-section x components
            ztheta1 = ztheta2
            ' GetPixel from picDATAORG(0 To 3, 0 to picwidth, 0 to picheight)
            ' SetPixel to picDATA
            BB = picDATAORG(0, xs, y2s - ys)
            GB = picDATAORG(1, xs, y2s - ys)
            RB = picDATAORG(2, xs, y2s - ys)
            
            ' Manipulation of color bytes
            ' could be put here
            
            'EG Intensity
'            Dim i As Single
'            i = Sqr(1& * BB * BB + 1& * GB * GB + 1& * RB * RB)
'            If i > 255 Then i = 255
'            picDATA(0, X1, y2s - Y1) = i
'            picDATA(1, X1, y2s - Y1) = i
'            picDATA(2, X1, y2s - Y1) = i
         
            picDATA(0, X1, y2s - Y1) = BB
            picDATA(1, X1, y2s - Y1) = GB
            picDATA(2, X1, y2s - Y1) = RB
         
         
         Next xs
      End If
   Next ys

   ' StretchDIBits picDATA to pic(5)
   DISPLAY Pic
   'Pic.Refresh
End Sub

Public Sub DISPLAY(Pic As PictureBox)
' Public BHI As BITMAPINFOHEADER
Dim xlo As Long, ylo As Long
Dim GetMode As Long
   xlo = 0
   ylo = 0
   GetMode = GetStretchBltMode(Pic.hdc)

   SetStretchBltMode Pic.hdc, HALFTONE
   
   With BHI
      .biSize = 40
      .biPlanes = 1
      .biWidth = picwidth
      .biHeight = picheight
      .biBitCount = 32
   End With
   
   Call StretchDIBits(Pic.hdc, _
   0, 0, _
   Pic.Width, Pic.Height, _
   xlo, ylo, _
   Pic.Width, Pic.Height, _
   picDATA(0, 0, 0), _
   BHI, 0, vbSrcCopy)
   
   SetStretchBltMode Pic.hdc, GetMode
   
   Pic.Refresh
   'Pic.Picture = Pic.Image
End Sub


Public Function zATan2(y As Single, x As Single) As Single
' Const pi# = 3.14159265
' Input:  deltay(Y),deltax(X) - real
' Output: atan(Y/X) for -pi#/2 to pi#/2
   If x <> 0 Then
      zATan2 = Atn(y / x)
      If (x < 0) Then
         If (y < 0) Then zATan2 = zATan2 - pi# Else zATan2 = zATan2 + pi#
      End If
   Else  ' x=0
      If Abs(y) > 0 Then   ' Must be an overflow
         If y > 0 Then zATan2 = pi# / 2 Else zATan2 = -pi# / 2
      Else  ' 0/0
         zATan2 = 0
      End If
   End If
End Function

Public Sub ExtrPath_Name(FileSpec$, PathName$, FileName$)
' NOT USED
' In:  FileSpec$ = Full FileSpec
' Out: PathName$ & FileName$
' NB Could use Split function but VB5 doesn't have it?
Dim p As Long
Dim pbs As Long

   PathName$ = " "
   FileName$ = " "
   If FileSpec$ = "" Then Exit Sub
   ' Find pbs on last backslash \
   p = 0: pbs = 0
   Do: p = InStr(p + 1, FileSpec$, "\")
       If p <> 0 Then pbs = p Else Exit Do
   Loop
   If pbs > 0 Then
      PathName$ = Left$(FileSpec$, pbs)
      FileName$ = Mid$(FileSpec$, pbs + 1)
   End If
End Sub

