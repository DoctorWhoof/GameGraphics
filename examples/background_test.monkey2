#Import "../gamegraphics"
'   
#Import "images/starfield.png"
#Import "images/grid.png"

Using mojo..
Using std..

Function Main()
	New AppInstance
	New BGWindow()
	App.Run()
End

Class BGWindow Extends Window

	Field bg :Background
	Field grid :Background
	
	Field x:= 0.0
	Field y:= 0.0
	Field scale := 3.0
	Field speed := 10.0
	Field colorTint:= New Color( 0.25, 1.0, 0.5 )
	
	Field parallax := 1.0
	Field parallaxCam:Rect<Double>
	Field camera:= New Vec2<Double>()

	Property Parallax:Double()
		Return parallax
	Setter( p:Double )
		parallax = p
		parallaxCam.Left = camera.X * parallax
		parallaxCam.Top = camera.Y * parallax
		parallaxCam.Right = ( camera.X * parallax ) + Width
		parallaxCam.Bottom = ( camera.Y * parallax ) + Height
	End

	Method New()					
		Super.New( "Test", 1280, 720, WindowFlags.Resizable )
		bg = New Background( "asset::starfield.png", True )
		grid = New Background( "asset::grid.png", True )
		parallaxCam = New Rect<Double>( 0, 0, Width, Height )
		bg.Handle = New Vec2f( 0, 0 )
'   		bg.debug = True
	End
	
	Method OnRender( canvas:Canvas ) Override
		App.RequestRender()
		
		If Keyboard.KeyDown( Key.Left )
			camera.X -= speed
		Else If Keyboard.KeyDown( Key.Right )
			camera.X += speed
		End
		
		If Keyboard.KeyDown( Key.Up )
			camera.Y -= speed
		Else If Keyboard.KeyDown( Key.Down )
			camera.Y += speed
		End
		
		canvas.Color = colorTint

		Parallax = 0.1
		canvas.Alpha = 1.0
		canvas.PushMatrix()
		canvas.Translate( -parallaxCam.Left, -parallaxCam.Top )
		bg.Draw( canvas, 0, 0, scale, parallaxCam )
		canvas.PopMatrix()
		
		Parallax = 0.25
		canvas.Alpha = 0.25
		canvas.PushMatrix()
		canvas.Translate( -parallaxCam.Left, -parallaxCam.Top )
		grid.Draw( canvas, 0, 0, scale, parallaxCam )
		canvas.PopMatrix()	
		
		Parallax = 1.0
		canvas.Alpha = 0.5
		canvas.PushMatrix()
		canvas.Translate( -parallaxCam.Left, -parallaxCam.Top )
		grid.Draw( canvas, 0, 0, scale, parallaxCam )
		canvas.PopMatrix()

		canvas.Alpha = 1.0
		canvas.DrawText( "Use arrow keys to move camera", 10, 10 )
		canvas.DrawText( Int(parallaxCam.Left) + "," + Int(parallaxCam.Top) + "; " + Int(parallaxCam.Right) + "," + Int(parallaxCam.Bottom), 10, canvas.Font.Height + 10 )
  	End
  	  	
   	Method OnKeyEvent( event:KeyEvent ) Override
		If Keyboard.KeyDown( Key.LeftGui ) And Keyboard.KeyHit( Key.Q ) Then App.Terminate()
	End
	
End