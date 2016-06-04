package TetrisGame
{

import flash.display.Bitmap;
import flash.display.DisplayObject;
import flash.display.Loader;
import flash.display.MovieClip;
import flash.events.Event;
import flash.net.URLRequest;
import flash.utils.Dictionary;

public class AssetManager
{
    private const SERVER_URL:String = "https://fathomless-earth-78839.herokuapp.com/";
    private const LIMIT_REQUEST:int = 5;

    private var _dictionaryAssets:Dictionary = new Dictionary(); // URL - Loader Загруженные assets
    private var _arrayCallBack = new Array(); // object { function callback, URL, className }  Запросы на загрузку
    private var _arrayLoaderURL:Vector.<String> = new Vector.<String>(); // Стек запросов URL
    private var _arrayDeffered:Array = new Array(); // Стек отложенных запросов

    private static var _instance:AssetManager = new AssetManager();

    public static function get instance():AssetManager
    {
        return _instance;
    }

    public function AssetManager()
    {
        if( _instance )
        {
            throw Error('AssetManager class is singleton');
        }
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
    public function getAsset(fileName:String, calback:*, className:String = ""):DisplayObject
    {
        // Если assets загружен
        if ( isLoaded( fileName ) )
        {
            // Возвращаем копию объекта
            return  cloneAsset( _dictionaryAssets[ getURL( fileName ) ], className );
        }
        else
        {
            var url:String = getURL( fileName );
            // Добавляем в стек загрузки
            _arrayCallBack.push( { calBack:calback, URL:url, className:className } );
            // Если не загружался, ставим его в очередь загрузки
            addAsset( fileName, className );
        }
        return null;
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

    // Возвращает число активных запросов
    private function getCountActiveRequest():int
    {
        var countAsset:int = 0;
        for( var valye:* in _dictionaryAssets )
        {
            countAsset++;
        }
        return _arrayLoaderURL.length - countAsset;
    }

    private function getIndexOfFileName(value:String):int
    {
        for( var i:int = 0; i < _arrayDeffered.length; i++ )
        {
            var object:Object = _arrayDeffered[ i ];
            if( object.fileName == value )
            {
                return i;
            }
        }
        return -1;
    }

    // Добавление нового запроса
    private function addAsset(fileName:String, className:String):void
    {
        var url:String = getURL( fileName );
        // Проверяем выполнялся ли запрос с таким URL
        if( _arrayLoaderURL.indexOf( url ) < 0 )
        {
            // Проверяем очередь загрузки, если превышает лимит, то откладываем
            if( getIndexOfFileName( fileName ) < 0 && getCountActiveRequest() > LIMIT_REQUEST )
            {
                _arrayDeffered.push( { fileName:fileName, className:className } );
                return;
            }
            // Добавляем в стек запросов
            _arrayLoaderURL.push( url );
            // Выполняем запрос, если о не выполнялся
            var request:URLRequest = new URLRequest( url );
            var loader:Loader = new Loader();
            loader.contentLoaderInfo.addEventListener( Event.COMPLETE, onComplete );
            loader.load( request );
        }
    }

    // Загрузка данных
    private function onComplete(e:Event):void
    {
        var assetLoader:Loader = e.target.loader as Loader;
        // Добавляем в КЭШ
        _dictionaryAssets[ assetLoader.contentLoaderInfo.url ] = assetLoader;
        // Рассылаем слушателям пришедший обьект
        var objectCallBack:Object;
        var displayAsset:DisplayObject;
        //Рассылаем полученные данные по URL
        for( var i:uint = 0; i < _arrayCallBack.length; i++ )
        {
            objectCallBack = _arrayCallBack[ i ];
            // Если URL не совпадают, то пропускаем
            if( objectCallBack.URL != assetLoader.contentLoaderInfo.url )
            {
                continue;
            }
            // Копируем объект
            displayAsset = cloneAsset(assetLoader, objectCallBack.className);
            // Отсылаем объект подписчику
            objectCallBack.calBack( { fileName:getFileName( objectCallBack.URL ), target:displayAsset } );
            // Удаляем CallBack из стека
            _arrayCallBack.splice( i, 1 );
            i--;
        }
        // Выполняем отложенный запрос
        if( _arrayDeffered.length != 0 )
        {
            // Удаляет элемент из стека отложенных запросов _arrayDeffered
            var objectRequest:Object = _arrayDeffered.shift();
            addAsset( objectRequest.fileName, objectRequest.className );
        }
    }

}
}
