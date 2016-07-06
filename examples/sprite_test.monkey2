#Import "../gamegraphics"
 
#Import "images/numbers.png"
#Import "images/classic_small_bold.ttf"

Using mojo..
Using std..

Function Main()
	New AppInstance
	New SpriteWindow()
	App.Run()
End

Class SpriteWindow Extends Window

	Field sprite :Sprite
	Field angle := 0.0
	Field scale := 5.0

	Method New()					
		Super.New( "Test", 1280, 720, WindowFlags.Resizable )
		sprite = New Sprite( "asset::numbers.png", 8, 32, 32, False )
		sprite.AddAnimationClip( "countUp", New Int[]( 0, 1, 2, 3, 4, 5, 6, 7 ) )
		sprite.AddAnimationClip( "countDown", New Int[]( 7, 6, 5, 4, 3, 2, 1, 0 ) )
		sprite.frameRate = 2
	End
	
	Method OnRender( canvas:Canvas ) Override
		App.RequestRender()
		angle -= 0.05
		sprite.Draw( canvas, "countUp", Width/4, Height/2, angle, scale, scale )
		sprite.Draw( canvas, "countDown", Width/2, Height/2, angle, scale, scale )
		sprite.Draw( canvas, "noClip", 3*Width/4, Height/2, angle, scale, scale )
  	End
  	
  	Method OnKeyEvent( event:KeyEvent ) Override
		If Keyboard.KeyDown( Key.LeftGui ) And Keyboard.KeyHit( Key.Q ) Then App.Terminate()
	End
	
End