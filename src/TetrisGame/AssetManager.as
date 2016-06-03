package TetrisGame
{
import TetrisGame.AssetEvent;

import flash.display.BitmapData;
import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.TimerEvent;
import flash.net.URLRequest;
import flash.utils.Dictionary;
import flash.utils.Timer;

public class AssetManager extends EventDispatcher
{
    private static const SERVER_URL:String = "https://fathomless-earth-78839.herokuapp.com/";
    private static const LIMIT_REQUEST:int = 5;

    private static var _countActiveRequest:int = 0;
    private static var _timerRequest:Timer = new Timer( 500 );
    private static var _assets:Dictionary = new Dictionary(); // URL - Loader Загруженные assets
    private static var _dictionaryLoaderRequest = new Dictionary(); // URL - Loader Выполняемые запросы
    private static var _dictionaryDeferredRequest:Dictionary = new Dictionary(); // Стек отложенных запросов

    public function AssetManager()
    {
    }

    // Получение URL объекта
    public static function getURL(fileName:String):String
    {
        if( fileName.indexOf(SERVER_URL) > 0 )
        {
            return fileName;
        }
        return SERVER_URL + fileName;
    }

    // Получение Asset
    public function getAsset(fileName:String):Loader
    {
        if ( isLoaded( fileName ) )
        {
            return _assets[ getURL( fileName ) ];
        }
        return null;
    }

    // Добавление нового запроса
    public function addAsset(fileName:String):void
    {
        var url:String = getURL( fileName );
        // Если число запросов превысило допустимый
        if( _countActiveRequest > LIMIT_REQUEST && !_dictionaryDeferredRequest.hasOwnProperty( url ) &&
                !_dictionaryLoaderRequest.hasOwnProperty( url ))
        {
            // Добавляем с стек запросов
            _dictionaryDeferredRequest[ url ] = this;
            // Добавляем таймер проверки очереди
            if( !_timerRequest.running )
            {
                _timerRequest.start();
                _timerRequest.addEventListener( TimerEvent.TIMER, onTimerRequest );
            }
            return;
        }
        // Если asset загружается но не загрузился
        if( _dictionaryLoaderRequest.hasOwnProperty( url ) )
        {
            return;
        }
        var request:URLRequest = new URLRequest( url );
        var loader:Loader = new Loader();
        _dictionaryLoaderRequest[ url ] = loader;
        loader.contentLoaderInfo.addEventListener( Event.COMPLETE, onComplete );
        // Добавляем счетчик активных запросов
        _countActiveRequest++;
        loader.load( request );
    }

    // Проверка доступности выполнения запроса
    private static function onTimerRequest(e:TimerEvent):void
    {
        // Убираем обраочик, если больше не требуется выполнение
        if( _countActiveRequest == 0 )
        {
            _timerRequest.stop();
            _timerRequest.removeEventListener( TimerEvent.TIMER_COMPLETE, onTimerRequest );
            return;
        }
        if( _countActiveRequest < LIMIT_REQUEST )
        {
            //Берем первый запрос из очереди
            var firstAsset:AssetManager;
            for( var firstKey:String in _dictionaryDeferredRequest )
            {
                firstAsset = _dictionaryDeferredRequest[ firstKey ];
                break;
            }
            // Убираем запрос из стека
            delete _dictionaryDeferredRequest[ firstKey ];
            var url:String = firstKey;
            // Выполняем запрос
            firstAsset.addAsset( url );
        }
    }

    // Загрузка данных
    private function onComplete(e:Event):void
    {
        // Убавляем счетчик активных ссылок
        _countActiveRequest--;
        var assetLoader:Loader = e.target.loader as Loader;
        // Добавляем в КЭШ
        _assets[ assetLoader.contentLoaderInfo.url ] = assetLoader;
        // Создаем событие с нашим Loader
        var event:AssetEvent = new AssetEvent( AssetEvent.ASSET_COMPLETE , false, false, this, assetLoader );
        dispatchEvent( event );
    }

    // Проверяет загружен ли аасет или нет
    public function isLoaded(fileName:String):Boolean
    {
        return _assets.hasOwnProperty( getURL( fileName ) );
    }
}
}
