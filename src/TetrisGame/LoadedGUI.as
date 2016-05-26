package TetrisGame
{

import flash.display.Loader;
import flash.display.LoaderInfo;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.TimerEvent;
import flash.net.URLRequest;
import flash.utils.Dictionary;
import flash.utils.Timer;

/* Класс загрузки графических объектов*/
public class LoadedGUI extends Sprite
{
    private static const SERVER_URL:String = "https://fathomless-earth-78839.herokuapp.com/";
    private static const LIMIT_REQUEST:int = 5;

    private static var _dictionaryGUI:Dictionary = new Dictionary(); // [URL] = Object (GUI)
    private static var _dictionaryLoaderRequest:Dictionary = new Dictionary(); // [LoadedGUI] = Loader
    private static var _dictionaryDeferredRequest:Dictionary = new Dictionary(); // [LoaderGUI] = URL
    private static var _countActiveRequest:int = 0;
    private static var _timerRequest:Timer = new Timer(500);

    private var _params:LoadedParams = new LoadedParams();
    private var _name:String;
    private var _directory:String;
    private var _targetObject:Object;

    public function get Params():LoadedParams
    {
        return _params;
    }

    public function LoadedGUI(name:String, directory:String, params:LoadedParams = null)
    {
        _name = name;
        _directory = directory;
        if( params )
        {
            _params = params;
        }
        var url:String = getURL();
        // Проверяем данные в КЭШе
        if( _dictionaryGUI.hasOwnProperty( url ) )
        {
            // Данные уже загружены
            var objectGUI = _dictionaryGUI[ url ];
            if( objectGUI is Loader )
            {
                addChild( objectGUI );
                _dictionaryLoaderRequest[ this ] = objectGUI;
            }
            else if( objectGUI is Class )
            {
                var newMovie:MovieClip = new objectGUI() as MovieClip;
                _targetObject = newMovie;
                setParams();
                addChild( newMovie );
            }
        }
        // Загружаем данные с сервера
        else
        {
            // Добавляем в список запросов
            if( _countActiveRequest < LIMIT_REQUEST )
            {
                loadGUI( url );
            }
            else
            {
                // Добавляем в очередь запросов
                _dictionaryDeferredRequest[ this ] = url;
                // Добавляем таймер проверки очереди
                if( !_timerRequest.running )
                {
                    _timerRequest.start();
                    _timerRequest.addEventListener( TimerEvent.TIMER, onTimerRequest );
                }
            }
        }
    }

    // Загрузка данных с сервера
    private function loadGUI(url:String):Loader
    {
        var request:URLRequest = new URLRequest( url );
        var loader:Loader = new Loader();
        loader.contentLoaderInfo.addEventListener( Event.COMPLETE, onComplete, false, 0, true);
        _dictionaryLoaderRequest[ this ] = loader;
        _dictionaryGUI[ url ] = loader;
        _countActiveRequest++;
        loader.load(request);
        addChild(loader);
        return loader;
    }

    // Получение URL объекта
    private function getURL():String
    {
        return SERVER_URL + _directory + '/' + _name;
    }

    private function getNameLoadedClass():String
    {
        return _name.substring( 0, _name.indexOf( '.' ) );
    }

    // Загрузка содержимого
    private function onComplete(e:Event):void
    {
        var loaderInfo:LoaderInfo = LoaderInfo( e.target );
        // Уменьшаем счетчик запросов
        _countActiveRequest--;
        switch( loaderInfo.contentType )
        {
            case "image/jpeg":
                    addChild( loaderInfo.content );
                    _dictionaryGUI[ loaderInfo.url ] = loaderInfo.content;
                    break;
            case "application/x-shockwave-flash":
                    var MovieClass:Class = e.target.applicationDomain.getDefinition( getNameLoadedClass() ) as Class;
                    _dictionaryGUI[ loaderInfo.url ] = MovieClass;
                    for( var object:* in _dictionaryLoaderRequest )
                    {
                        var loaderRequest = _dictionaryLoaderRequest[ object ];
                        if( loaderRequest != loaderInfo.loader )
                        {
                            continue;
                        }
                        var newMovie:MovieClip = new MovieClass() as MovieClip;
                        var loadedGUI:LoadedGUI = object as LoadedGUI;
                        loadedGUI._targetObject = newMovie;
                        loadedGUI.setParams();
                        loadedGUI.addChild( newMovie );
                        delete _dictionaryLoaderRequest[ object ];
                    }
                    break;
        }
    }

    public function setParams():void
    {
        if( _targetObject as MovieClip )
        {
            var currentMovie:MovieClip = _targetObject as MovieClip;
            currentMovie.gotoAndStop( _params.currentStopFrame );
        }
    }

    // Проверка доступности выполнения запроса
    private static function onTimerRequest(e:TimerEvent):void
    {
        if( _countActiveRequest < LIMIT_REQUEST )
        {
            var loadedGUI:LoadedGUI;
            var url:String;
            var loader;Loader;
            //Берем первый запрос из очереди
            for( var key:* in _dictionaryDeferredRequest)
            {
                loadedGUI = key as LoadedGUI;
                url = _dictionaryDeferredRequest[ key ] as String;
                // Выполняем запрос
                loader = loadedGUI.loadGUI( url );
                break;
            }
            // Регистрируем новый Loader
            for( var key:* in _dictionaryDeferredRequest )
            {
                if(url != _dictionaryDeferredRequest[key])
                {
                    continue;
                }
                _dictionaryLoaderRequest[key] = loader;
                _dictionaryGUI[url] = loader;
                delete _dictionaryDeferredRequest[key];
            }
        }
        if( _countActiveRequest == 0 )
        {
            _timerRequest.stop();
            _timerRequest.removeEventListener( TimerEvent.TIMER_COMPLETE, onTimerRequest );
        }
    }
}
}
