B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=7.3
@EndOfDesignText@
'Class module
'version 1.20
'See this page for the list of constants:
'http://developer.android.com/intl/fr/reference/android/hardware/Camera.Parameters.html
'Note that you should use the constant values instead of the names.
Sub Class_Globals
	Private nativeCam As Object
	Private cam As Camera ,CamIsInitialized As Boolean 
	Private r As Reflector
	Private target As Object
	Private event As String
	Public Front As Boolean, IsPreviewing As Boolean, CameraOrientation As Int 'switch to 2 orientation values, one for front, one for back
	Type CameraInfoAndId (CameraInfo As Object, Id As Int)
	Type CameraSize (Width As Int, Height As Int)
	Private parameters As Object', JPG As Jpeg 
End Sub

Public Sub Initialize (Panel1 As Panel, FrontCamera As Boolean, TargetModule As Object, EventName As String) As Boolean 
	target = TargetModule
	event = EventName
	Front = FrontCamera
	Panel1.Visible=True
	Dim id As Int
	id = FindCamera(Front).id
	If id = -1 Then
		Front = Not(Front) 'try different camera
		id = FindCamera(Front).id
		If id = -1 Then Return False
	End If
	'JPG.Initialize("JPEG")
	cam.Initialize2(Panel1, "camera", id)
	Return True
End Sub

Private Sub FindCamera (frontCamera As Boolean) As CameraInfoAndId
	Dim ci As CameraInfoAndId, cameraInfo As Object, cameraValue As Int, numberOfCameras As Int = r.RunStaticMethod("android.hardware.Camera", "getNumberOfCameras", Null, Null)
	If frontCamera Then cameraValue = 1 Else cameraValue = 0
	Try
		cameraInfo = r.CreateObject("android.hardware.Camera$CameraInfo")
		For i = 0 To numberOfCameras - 1
			r.RunStaticMethod("android.hardware.Camera", "getCameraInfo", Array As Object(i, cameraInfo), Array As String("java.lang.int", "android.hardware.Camera$CameraInfo"))
			r.target = cameraInfo
			If r.GetField("facing") = cameraValue Then 
				ci.cameraInfo = r.target
				ci.Id = i
				Return ci
			End If
		Next
	Catch
	End Try
	ci.id = -1
	Return ci
End Sub

Private Sub SetDisplayOrientation
	r.target = r.GetActivity
	r.target = r.RunMethod("getWindowManager")
	r.target = r.RunMethod("getDefaultDisplay")
	r.target = r.RunMethod("getRotation")
	Dim previewResult As Int, result As Int, degrees As Int = r.target * 90, ci As CameraInfoAndId = FindCamera(Front), orientation As Int = r.GetField("orientation")
	r.target = ci.CameraInfo
	If Front Then
		previewResult = (orientation + degrees) Mod 360
		result = previewResult
		previewResult = (360 - previewResult) Mod 360
	Else
		previewResult = (orientation - degrees + 360) Mod 360
		result = previewResult
		Log(previewResult)
	End If
	r.target = nativeCam
	r.RunMethod2("setDisplayOrientation", previewResult, "java.lang.int")
	r.target = parameters
	r.RunMethod2("setRotation", result, "java.lang.int")
	CommitParameters
End Sub

Private Sub Camera_Ready (Success As Boolean)
	CamIsInitialized=Success
	If Success Then
		r.target = cam
		nativeCam = r.GetField("camera")
		r.target = nativeCam
		parameters = r.RunMethod("getParameters")
		SetDisplayOrientation
	End If
	If SubExists(target, event & "_ready") Then CallSub2(target, event & "_ready", Success) Else Log(event & "_ready is missing/required")
End Sub

Sub Camera_Preview (Data() As Byte)
	If SubExists(target, event & "_preview") Then CallSub2(target, event & "_preview", Data) 'Else Log(event & "_preview is missing")
End Sub

Public Sub TakePicture As Boolean 
	If CamIsInitialized Then 
		cam.TakePicture
		Return True
	End If
End Sub

Public Sub BytesToBmp(Data() As Byte) As Bitmap', Degrees As Int) As Bitmap
  Dim bm As Bitmap, ips As InputStream', bm2 As BitmapExtended
  ips.InitializeFromBytesArray(Data, 0, Data.Length)
  bm.Initialize2(ips)
  ips.Close
  Return(bm)
  'If Degrees = 0 Then Return(bm)
  'Return bm2.rotateBitmap(bm,-90)
End Sub

Private Sub Camera_PictureTaken (Data() As Byte)
	If SubExists(target, event & "_PictureTaken") Then CallSub2(target, event & "_PictureTaken", Data) 'Else Log(event & "_PictureTaken is missing")
End Sub

Public Sub StartPreview As Boolean 
	If CamIsInitialized Then 
		cam.StartPreview
		IsPreviewing=True
		Return True
	End If
End Sub

Public Sub StopPreview As Boolean 
	If CamIsInitialized Then
		cam.StopPreview
		IsPreviewing=False
		Return True
	End If
End Sub

Public Sub Release As Boolean 
	If CamIsInitialized Then
		cam.Release
		IsPreviewing=False
		Return True
	End If
End Sub

'Saves the data received from PictureTaken event
Public Sub SavePictureToFile(Data() As Byte, Dir As String, FileName As String)
	Dim out As OutputStream = File.OpenOutput(Dir, FileName, False)
	out.WriteBytes(Data, 0, Data.Length)
	out.Close
End Sub

Public Sub SetParameter(Key As String, Value As String)
	r.target = parameters
	r.RunMethod3("set", Key, "java.lang.String", Value, "java.lang.String")
End Sub

Public Sub GetParameter(Key As String) As String
	r.target = parameters
	Return r.RunMethod2("get", Key, "java.lang.String")
End Sub

Public Sub CommitParameters
	Try
		r.target = nativeCam
		r.RunMethod4("setParameters", Array As Object(parameters), Array As String("android.hardware.Camera$Parameters"))
	Catch
		'ToastMessageShow("Error setting parameters.", True)
		Log(LastException)
	End Try
End Sub

Public Sub GetColorEffect As String
	Return GetParameter("effect")
End Sub

Public Sub SetColorEffect(Effect As String)
	SetParameter("effect", Effect)
End Sub

Public Sub GetSupportedPicturesSizes As CameraSize()
	r.target = parameters
	Dim list1 As List = r.RunMethod("getSupportedPictureSizes")
	Dim cs(list1.Size) As CameraSize
	For i = 0 To list1.Size - 1
		r.target = list1.Get(i)
		cs(i).Width = r.GetField("width")
		cs(i).Height = r.GetField("height")
	Next
	Return cs
End Sub

Public Sub SetPictureSize(Width As Int, Height As Int)
	r.target = parameters
	r.RunMethod3("setPictureSize", Width, "java.lang.int", Height, "java.lang.int")
End Sub

Public Sub SetJpegQuality(Quality As Int)
	r.target = parameters
	r.RunMethod2("setJpegQuality", Quality, "java.lang.int")
End Sub

Public Sub SetFlashMode(Mode As String)
	r.target = parameters
	r.RunMethod2("setFlashMode", Mode, "java.lang.String")
End Sub

Public Sub GetFlashMode As String
	r.target = parameters
	Return r.RunMethod("getFlashMode")
End Sub

Public Sub GetSupportedFlashModes As List
	r.target = parameters
	Return r.RunMethod("getSupportedFlashModes")
End Sub

Public Sub GetSupportedColorEffects As List
	r.target = parameters
	Return r.RunMethod("getSupportedColorEffects")
End Sub

Public Sub GetPreviewSize As CameraSize
	r.target = parameters
	r.target = r.RunMethod("getPreviewSize")
	Dim cs As CameraSize
	cs.Width = r.GetField("width")
	cs.Height = r.GetField("height")
	Return cs
End Sub

Public Sub GetPictureSize As CameraSize
	r.target = parameters
	r.target = r.RunMethod("getPictureSize")
	Dim cs As CameraSize
	cs.Width = r.GetField("width")
	cs.Height = r.GetField("height")
	Return cs
End Sub

'Converts a preview image formatted in YUV format to JPEG.
'Note that you should not save every preview image as it will slow down the whole process.
Public Sub PreviewImageToJpeg(data() As Byte, quality As Int) As Byte()
	Dim size, previewFormat As Object
	r.target = parameters
	size = r.RunMethod("getPreviewSize")
	previewFormat = r.RunMethod("getPreviewFormat")
	r.target = size
	Dim width = r.GetField("width"), height = r.GetField("height") As Int
	Dim yuvImage As Object = r.CreateObject2("android.graphics.YuvImage", Array As Object(data, previewFormat, width, height, Null), Array As String("[B", "java.lang.int", "java.lang.int", "java.lang.int", "[I"))
	r.target = yuvImage
	Dim rect1 As Rect
	rect1.Initialize(0, 0, r.RunMethod("getWidth"), r.RunMethod("getHeight"))
	Dim out As OutputStream
	out.InitializeToBytesArray(100)
	r.RunMethod4("compressToJpeg", Array As Object(rect1, quality, out), Array As String("android.graphics.Rect", "java.lang.int", "java.io.OutputStream")) 
	Return out.ToBytesArray
End Sub

Public Sub PreviewImageToBMP(data() As Byte, quality As Int, Width As Int, Height As Int, UseOuterBoundary As Boolean ) As Bitmap
	Dim  I As InputStream, temp As Bitmap, temp2 As Bitmap , BG As Canvas ,Size As Point , Orientation As Int 
	If Not(Front) Then Orientation = CameraOrientation
	data = PreviewImageToJpeg(data, quality)
	I.InitializeFromBytesArray(data, 0, data.Length)
	temp.Initialize2(I)
	If Orientation = 0 And Width = temp.Width And temp.Height = Height Then
		Return temp
	Else If Orientation = 180 Or Orientation = 0 Then
		Size = API.Thumbsize(temp.Width,temp.Height,   Width,Height,  True,UseOuterBoundary)
	Else
		Size = API.Thumbsize(temp.Width,temp.Height,   Height,Width, True,UseOuterBoundary)
	End If
	temp2.InitializeMutable(Size.x,Size.y)
	BG.Initialize2(temp2)
	BG.DrawBitmapRotated( temp, Null, SetRect(0,0, temp2.Width,temp2.Height), Orientation)
	Return temp2
End Sub

Sub SetRect(X As Int, Y As Int, Width As Int, Height As Int) As Rect 
	Dim Rect1 As Rect 
	Rect1.Initialize(X,Y,X+Width,Y+Height)
	Return Rect1
End Sub
Public Sub GetSupportedFocusModes As List
    r.target = parameters
    Return r.RunMethod("getSupportedFocusModes")
End Sub

Public Sub SetContinuousAutoFocus As Boolean 
    Dim modes As List = GetSupportedFocusModes
    If modes.IndexOf("continuous-picture") > -1 Then
        SetFocusMode("continuous-picture")
		Return True
    Else If modes.IndexOf("continuous-video") > -1 Then
        SetFocusMode("continuous-video")
        Return True
    End If
End Sub

Public Sub SetFocusMode(Mode As String)
    r.target = parameters
    r.RunMethod2("setFocusMode", Mode, "java.lang.String")
End Sub

Public Sub GetFocusDistances As Float()
	Dim F(3) As Float
	r.target = parameters
	r.RunMethod4("getFocusDistances", Array As Object(F), Array As String("[F"))
	Return F
End Sub
'This method should only be called if you need to immediately release the camera.
'For example if you need to start another application that depends on the camera.
Public Sub CloseNow
	cam.Release
	r.target = cam
	r.RunMethod2("releaseCameras", True, "java.lang.boolean")
End Sub
'Calls AutoFocus and then takes the picture if focus was successfull.
Public Sub FocusAndTakePicture
	cam.AutoFocus
End Sub
Private Sub Camera_FocusDone (Success As Boolean) As Boolean 
	If Success Then
		TakePicture
		Return True
	End If
End Sub

Public Sub ToggleFlash As String
	Dim flashModes As List = GetSupportedFlashModes, Flash As String = GetFlashMode'[off, auto, on, torch, red-eye]
	If flashModes.IsInitialized = False Then Return False
	If Flash = "off" Then 
		If flashModes.IndexOf("torch") > -1 Then 
			Flash = "torch"	
		Else 
			Flash = flashModes.Get((flashModes.IndexOf(Flash) + 1) Mod flashModes.Size)
		End If 
	Else 
		Flash = "off"
	End If 
	SetFlashMode(Flash)
	CommitParameters	
	Return Flash
End Sub


'PreviewFormat
'17  = NV21 (YCrCb) 'default
'R = Y + 1.402 * (Cr-128)
'G = Y - 0.34414 * (Cb-128) - 0.71414 * (Cr-128)
'B = Y + 1.772 * (Cb-128)