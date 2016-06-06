package TetrisGame
{

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Loader;
import flash.display.MovieClip;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.net.URLRequest;
import flash.utils.Dictionary;

public class AssetManager
{
    private const SERVER_URL:String = "https://fathomless-earth-78839.herokuapp.com/";
    private const LIMIT_REQUEST:int = 5;

    // Asset который загрузился, пришел обект SWF или JPG
    private var _dictionaryAssets:Dictionary = new Dictionary(); // URL - Loader Загруженных assets
    // Список всех запросов на загрузку, отложенных и выполняемых
    private var _arrayCallBack = new Array(); // object { function callback, URL, className }
    // Стек уникальных URL которые запрашивались
    private var _arrayLoaderURL:Vector.<String> = new Vector.<String>(); // Стек запросов URL
    // Стек отложенных запросов
    private var _arrayWaiting:Array = new Array(); // object { filename, className }

    private static var _instance:AssetManager;

    public static function get instance():AssetManager
    {
        if( !_instance )
        {
            new AssetManager();
        }
        return _instance;
    }

    public function AssetManager()
    {
        if( _instance )
        {
            throw Error('AssetManager class is singleton');
        }
        _instance = this;
    }

    // Получение URL объекта
    private function getURL(fileName:String):String
    {
        return SERVER_URL + fileName;
    }

    // Возвращает исходное имя, обратная getURL
    private function getFileName(url:String):String
    {
        return url.replace( SERVER_URL, "" );
    }

    // Проверяет загружен ли аасет или нет
    public function isLoaded(fileName:String):Boolean
    {
        return _dictionaryAssets.hasOwnProperty( getURL( fileName ) );
    }

    // Получение Asset
    public function getAsset(fileName:String, calback:Function, className:String = ""):void
    {
        try
        {
            // Если assets загружен
            if ( isLoaded( fileName ) )
            {
                // Возвращаем копию объекта
                var displayAsset:DisplayObject = cloneAsset( _dictionaryAssets[ getURL( fileName ) ], className );
                // Отсылаем объект подписчику
                calback( { fileName:fileName, target:displayAsset } );
            }
            else
            {
                var url:String = getURL( fileName );
                // Добавляем в стек загрузки
                _arrayCallBack.push( { calBack:calback, URL:url, className:className } );
                // Если не загружался, ставим его в очередь загрузки
                loadAsset( fileName, className );
            }
        }
        catch ( error:Error )
        {
            trace( "<getAssetError> " + error.message );
        }
    }

    // Создаем новый asset
    private function cloneAsset(loader:Loader, className:String):DisplayObject
    {
        var result:DisplayObject;
        var cloneObject:DisplayObject = loader.content;
        if( cloneObject as Bitmap )
        {
            result = new Bitmap( ( cloneObject as Bitmap ).bitmapData.clone() );
        }
        else if( cloneObject as MovieClip )
        {
            var MovieClass:Class = loader.contentLoaderInfo.applicationDomain.getDefinition( className ) as Class;
            var newMovie:MovieClip = new MovieClass() as MovieClip;
            // Устанавливаем дефолтное значение
            newMovie.gotoAndStop( 1 );
            result = newMovie;
        }
        return result;
    }

    // Возвращает число активных запросов, которые в процессе выполнения
    private function getCountActiveRequest():int
    {
        var countAsset:int = 0;
        // Подсчитываем количество загруженных Asset
        for( var valye:* in _dictionaryAssets )
        {
            countAsset++;
        }
        // Разница между запросами которые посланы на загрузку и запросами которые загрузились
        return _arrayLoaderURL.length - countAsset;
    }

    // Проверяет имеется ли значение в стеке отложенных запросов, и возвращает индекс
    private function getIndexWaitingFileName(value:String):int
    {
        for( var i:int = 0; i < _arrayWaiting.length; i++ )
        {
            var object:Object = _arrayWaiting[ i ];
            if( object.fileName == value )
            {
                return i;
            }
        }
        return -1;
    }

    // Добавление нового запроса
    private function loadAsset(fileName:String, className:String):void
    {
        var url:String = getURL( fileName );
        // Проверяем выполнялся ли запрос с таким URL
        if( _arrayLoaderURL.indexOf( url ) >= 0 )
        {
            return;
        }
        // Проверяем очередь загрузки, если превышает лимит, то откладываем
        if( getIndexWaitingFileName( fileName ) < 0 && getCountActiveRequest() > LIMIT_REQUEST )
        {
            _arrayWaiting.push( { fileName:fileName, className:className } );
            return;
        }
        // Добавляем в стек запросов
        _arrayLoaderURL.push( url );
        // Выполняем запрос, если о не выполнялся
        var request:URLRequest = new URLRequest( url );
        var loader:Loader = new Loader();
        loader.contentLoaderInfo.addEventListener( Event.COMPLETE, onComplete );
        loader.addEventListener( IOErrorEvent.IO_ERROR, ioError );
        loader.load( request );
    }

    // Ошибки загрузки файлов
    private function ioError(e:IOErrorEvent):void
    {
        trace( e.toString() );
    }

    // Загрузка данных
    private function onComplete(e:Event):void
    {
        try
        {
            var assetLoader:Loader = e.target.loader as Loader;
            // Добавляем в КЭШ
            _dictionaryAssets[ assetLoader.contentLoaderInfo.url ] = assetLoader;
            // Рассылаем слушателям пришедший обьект
            //Рассылаем полученные данные по URL
            for( var i:int = _arrayCallBack.length - 1; i >= 0; i-- )
            {
                var objectCallBack:Object = _arrayCallBack[ i ];
                // Если URL не совпадают, то пропускаем
                if( objectCallBack.URL != assetLoader.contentLoaderInfo.url )
                {
                    continue;
                }
                // Копируем объект
                var displayAsset:DisplayObject = cloneAsset(assetLoader, objectCallBack.className);
                // Отсылаем объект подписчику
                objectCallBack.calBack( { fileName:getFileName( objectCallBack.URL ), target:displayAsset } );
                // Удаляем CallBack из стека
                _arrayCallBack.splice( i, 1 );
                //i--;
            }
            // Выполняем отложенный запрос, один выполнился, соответсвенно очереди смещается на один
            if( _arrayWaiting.length == 0 )
            {
                return;
            }
            // Удаляет элемент из стека отложенных запросов _arrayDeffered
            var objectRequest:Object = _arrayWaiting.shift();
            loadAsset( objectRequest.fileName, objectRequest.className );
        }
        catch( error:Error )
        {
            trace( "<onCompleteError> " + error.message );
        }
    }
}
}
