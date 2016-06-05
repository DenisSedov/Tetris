package TetrisGame
{

import flash.display.MovieClip;
import flash.display.Sprite;

public class Square extends Sprite
{
    private var _color:int;
    private static var _assetManager:AssetManager = AssetManager.instance;

    public function Square(color:int)
    {
        _color = color;
        _assetManager.getAsset( "swf/Square.swf", onCompleteAsset, "Square" );
    }

    // object.fileName
    // object.target
    private function onCompleteAsset(object:Object):void
    {
        switch( object.fileName )
        {
            case "swf/Square.swf":
                var assetSquare:MovieClip = object.target as MovieClip;
                assetSquare.gotoAndStop( _color );
                addChild( assetSquare );
                break;
        }
    }
}
}
