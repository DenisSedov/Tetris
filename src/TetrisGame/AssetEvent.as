package TetrisGame
{
import flash.events.Event;

public class AssetEvent extends Event
{
    static public const ASSET_COMPLETE:String = "AssetComplete";

    private var _data:Object;
    private var _asset:AssetManager;

    public function get asset ():AssetManager
    {
        return _asset;
    }

    public function get data ():Object
    {
        return _data;
    }

    public function AssetEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false, asset:AssetManager = null, data:Object = null):void
    {
        super( type, bubbles, cancelable );
        _asset = asset;
        _data = data;
    }
}
}
