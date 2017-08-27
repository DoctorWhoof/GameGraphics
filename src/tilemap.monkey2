
#Import "tilegraphics"

'   Class TileMap Extends TileGraphics
'   
'   	Method New( path:String, filter:Bool = True )
'   		Local flags:TextureFlags = Null
'   		
'   		Local atlasTextture := Texture.Load( path, flags )
'   		Assert( atlasTextture, " ~n ~nGameGraphics: Image " + path + " not found.~n ~n" )
'   		
'   		Local newImage := New Image( atlasTextture )
'   		If Not filter Then newImage.TextureFilter = TextureFilter.Nearest
'   		images = New Image[]( newImage )
'   	End
'   	
'   	Method Draw( canvas:Canvas, x:Double, y:Double, scale:Double, camera:Rect<Double> )
'   
'   		total = 0
'   
'   		GetVisibleTiles( x, y, scale, camera )
'   		
'   		For Local tY := tileStartY Until tileEndY
'   			For Local tX := tileStartX Until tileEndX
'   				local absX := ( tX * tileWidth ) + x
'   				local absY := ( tY * tileHeight ) + y
'   				If images[0]
'   					total += 1
'   					canvas.DrawImage( images[0], absX, absY, 0, scale, scale )
'   					If debug
'   						DrawRectOutline( canvas, absX, absY, tileWidth, tileHeight )
'   						canvas.DrawText( tX + "," + tY, absX + 4, absY + 4 )
'   					End
'   				End
'   			Next
'   		Next
'   	End
'   	
'   	Method ToString:String()
'   		Local t := ""
'   		t += ( "TileMap: " + tileStartX + "," + tileStartY + "; " + tileEndX + "," + tileEndY + "; " )
'   		Return t
'   	End
'   	
'   End


Strict
Import gameoven.shapes.tiles

Class TileMap Extends TileGraphics

	Field columns 			:Int
	Field rows 				:Int

	Field tile 				:Int[][]
	Field rotation 			:Int[][]
	Field transparency 		:Float[][]
	Field flipX 			:Int[][]
	Field flipY 			:Int[][]

	Field generateColliders	:= False
	Field reverseCollision	:= False		'does what it says!

	Field infiniteEdge		:= -1			'number of the tile to be drawn beyond tilemap edges (0 means no infinite edge )
	Field solidTiles		:= [0,1,2,4,5,6,8,9,10,12,13,14,15]			'Which tile indices are considered solid

	Protected

	Field emptyTiles 		:= New Stack< Int[] >
	Field fullTiles 	 	:= New Stack< Int[] >

	Field collidingEntities := New Stack<Entity>
	Field halfWidth			:= 1.0
	Field halfHeight		:= 1.0
	Field colliderWidth		:= 1.0
	Field colliderHeight	:= 1.0
	Field colColumns		:= 1
	Field colRows			:= 1
	Field colliderMap		:Int[][]

	Field solidColliders	:Int[]			'Wich indices are solid. AutoTileMap uses this to change indices to cell indices.

	Field emptyTile			:= -1			'Notice that in regular tilemaps -1 represents an empty tile, while in autoTileMaps a 0 means empty tile

	Public

	Method New()
		Super.New()
		handle.Set( 0, 0 )
'   		xHandle = 0
'   		yHandle = 0
	End


	Method Setup:Void( columns:Int, rows:Int, tileWidth:Int, tileHeight:Int )
		'Warning: discards existing map data.
		Self.columns = columns
		Self.rows = rows
		Self.tileWidth = tileWidth
		Self.tileHeight = tileHeight
		tile = Array2D( columns, rows )
		rotation = Array2D( columns, rows )
		flipX = Array2D( columns, rows )
		flipY = Array2D( columns, rows )
		transparency = FloatArray2D( columns, rows )
		For Local x:Int = 0 Until columns
			For Local y:Int = 0 Until rows
				transparency[x][y] = 1
			Next
		Next
		halfWidth = tileWidth/2.0
		halfHeight = tileHeight/2.0
		solidColliders = solidTiles
	End


	Method OnStart:Void()
		name = "Tilemap"
		SetEntitySize()
	End


	Method GenerateColliders:Void()
		GenerateColliders( tile, tileWidth, tileHeight, solidTiles )
	End


	Method GenerateColliders:Void( colMap:Int[][], colWidth:Float, colHeight:Float, solidIndices:Int[] )
		generateColliders = True
		solidColliders = solidIndices

		If not entity
			Error( "Tilemap: GenerateColliders() requires this shape to be assigned to an entity first!")
		End

		entity.transform.Size( columns * tileWidth, rows * tileHeight )
		entity.transform.UpdateWorldRect()
		entity.AddCollider( New Collider )
		entity.collider.passive = True
		entity.collider.solid = False
		entity.cull = True

		local n := 0
		For local y:= 0 To ( Render.camera.height/colHeight ) + 1
			For local x:= 0 To ( Render.camera.width/colWidth ) + 1
				local colEntity := New Entity( "tilecollider", entity.layer )
				colEntity.transform.Size( colWidth, colHeight )
				colEntity.AddCollider( New Collider )
				colEntity.collider.passive = True
				colEntity.enabled = False
				colEntity.Parent( entity )
				collidingEntities.Push( colEntity )
				n += 1
			Next
		Next

		colliderWidth = colWidth
		colliderHeight = colHeight
		halfWidth = colWidth/2.0
		halfHeight = colHeight/2.0
		colColumns = entity.transform.worldRect.width / colWidth
		colRows = entity.transform.worldRect.height / colHeight
		colliderMap = colMap
		' Print( "Tilemap:	Created " + n + " dormant collision tiles" )
	End


	Method SetEntitySize:Void()
		entity.transform.Size( columns * tileWidth, rows * tileHeight )
		entity.transform.UpdateWorldRect()
	End


	Method OnUpdate:Void()

		local n := 0
		If generateColliders
			GetVisibleTiles( colliderWidth, colliderHeight )
			For Local y:Int = tileStartY To tileEndY
				For Local x:Int = tileStartX To tileEndX

					local absX := ( x * colliderWidth ) + x1 + halfWidth
					local absY := ( y * colliderHeight ) + y1 + halfHeight

					If x < colColumns And x>-1 And y>-1 And y < colRows		'cull tiles beyond map array
						local value:= colliderMap[x][y]
						If ArrayContains( solidColliders, value )
							If n >= collidingEntities.Length() Then Continue
							local col := collidingEntities.Get( n )
							col.enabled = True
							col.transform.WorldPosition( absX, absY )
							n += 1
						End
					End

				Next
			Next
		End
		GetVisibleTiles( tileWidth, tileHeight )

		'Disables colliding entities not necessary in this frame
		For local remaining := n Until collidingEntities.Length()
			collidingEntities.Get( remaining ).enabled = False
		End
	End


	Method OnDraw:Void()
		For Local y:Int = tileStartY To tileEndY
			For Local x:Int = tileStartX To tileEndX

				local absX := ( x * tileWidth ) + x1
				local absY := ( y * tileHeight ) + y1

				If x < columns And x>-1 And y>-1 And y < rows		'cull tiles beyond map array
					local value:= tile[x][y]
					if value > -1
						Render.canvas.SetAlpha( transparency[x][y] * finalAlpha )
						If img[value]
							Render.canvas.DrawImage( img[value], absX, absY, rotation[x][y], drawScaleX, drawScaleY )
							' Render.canvas.DrawText( value, absX, absY )
						End
					End
				Else
					If infiniteEdge > -1
						'extends map using infiniteEdge image frame
						If img[infiniteEdge] Then Render.canvas.DrawImage( img[infiniteEdge], absX, absY, 0, drawScaleX, drawScaleY )
					End
				End

			Next
		Next
		' If Render.drawWireframe Then DrawBorder( x1, y1, width, height, 1, 1, 0 )
	End


	Method Randomize:Void(minValue:Int=0, maxValue:Int=1)
		For Local x := 0 Until columns
			For Local y := 0 Until rows
				tile[x][y] = Round(Rnd(minValue,maxValue))
			Next
		Next
	End


	Method FindEmptyTiles:Void()
		emptyTiles.Clear()
		fullTiles.Clear()
		For Local y:Int = 0 Until rows
			For Local x:Int = 0 Until columns
				If ArrayContains( solidTiles, tile[x][y] )
					fullTiles.Push( [x,y] )
				Else
					emptyTiles.Push( [x,y] )
				End
			Next
		Next
		' Print( "Found " + emptyTiles.Length + " empty tiles out of " + (rows * columns) )
	End


	Method GetTileCoords:Float[]( x:Int, y:Int )
		local absX :Float = (( x * tileWidth ) + x1 ) - ( entity.transform.worldRect.width/2 ) + ( tileWidth/2 )
		local absY :Float = (( y * tileHeight ) + y1 ) - ( entity.transform.worldRect.height/2 ) + ( tileHeight/2 )
		Return [ absX, absY ]
	End

	Method GetRandomEmptyTile:Int[]()
		Return emptyTiles.Get( Rnd( emptyTiles.Length() ) )
	End


	Method GetRandomFullTileCoords:Float[]( requireTileBelow:Bool = False )
		If fullTiles.Length < 1 Then Print( "AutoTileMap:	No full cells! Use FindEmptyTiles() to populate the empty cells list")
		If Not entity Then Error("AutoTileMap:	GetRandomEmptyTileCoords requires an entity")
		local fullTile := fullTiles.Get( Rnd( fullTiles.Length() ) )
		local absX :Float = (( fullTile[0] * tileWidth ) + x1 ) - ( entity.transform.worldRect.width/2 ) + ( tileWidth/2 )
		local absY :Float = (( fullTile[1] * tileHeight ) + y1 ) - ( entity.transform.worldRect.height/2 ) + ( tileHeight/2 )
		If requireTileBelow
			If Not GetTile( fullTile[0], fullTile[1]+1 )
				Return GetRandomFullTileCoords( requireTileBelow )
			Else
				Return [ absX, absY ]
			End
		Else
			Return [ absX, absY ]
		End
	End


	Method GetRandomEmptyTileCoords:Float[]()
		If emptyTiles.Length < 1 Then Print( "AutoTileMap:	No empty cells! Use FindEmptyTiles() to populate the empty cells list")
		If Not entity Then Error("AutoTileMap:	GetRandomEmptyTileCoords requires an entity")
		local emptyTile := emptyTiles.Get( Rnd( emptyTiles.Length() ) )
		local absX :Float = (( emptyTile[0] * tileWidth ) + x1 ) - ( entity.transform.worldRect.width/2 ) + ( tileWidth/2 )
		local absY :Float = (( emptyTile[1] * tileHeight ) + y1 ) - ( entity.transform.worldRect.height/2 ) + ( tileHeight/2 )
		Return [ absX, absY ]
	End

End
