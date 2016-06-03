package TetrisGame
{

import flash.display.Loader;
import flash.display.MovieClip;
import flash.display.Sprite;

public class Square extends Sprite
{
    private var _color:int;
    private static var _assetManager:AssetManager = new AssetManager();

    public function Square(color:int)
    {
        _color = color;
        if( _assetManager.isLoaded( "swf/Square.swf" ) )
        {
            addChild(getSquare(_assetManager.getAsset( "swf/Square.swf" ) as Loader, color ));
        }
        else
        {
            _assetManager.addAsset( "swf/Square.swf" );
            _assetManager.addEventListener( AssetEvent.ASSET_COMPLETE, onCompleteAsset );
        }
    }

    private function getSquare(loader:Loader, frame:int = 1):MovieClip
    {
        var MovieClass:Class = loader.contentLoaderInfo.applicationDomain.getDefinition( "Square" ) as Class;
        var newMovie:MovieClip = new MovieClass() as MovieClip;
        newMovie.gotoAndStop( frame );
        return newMovie;
    }

    private function onCompleteAsset(e:AssetEvent):void
    {
        var loader:Loader = e.data as Loader;
        switch( loader.contentLoaderInfo.url )
        {
            case AssetManager.getURL( "swf/Square.swf" ):
                addChild( getSquare( loader, _color ) );
                break;
        }
    }
}
}
