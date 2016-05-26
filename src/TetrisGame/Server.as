package TetrisGame
{

import flash.events.Event;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLRequestHeader;
import flash.net.URLRequestMethod;
import flash.net.URLVariables;

import com.adobe.serialization.json.JSON;

// Класс работы с сервером
public class Server
{
    private static const URL:String = "https://fathomless-earth-78839.herokuapp.com/";//"http://localhost:3000/";
    private static const USER_URL:String = "users";
    private static const LEVEL_URL:String = "levels";

    public function Server()
    {
    }

    private static function setRequest(urlRequest:String, method:String, variables:URLVariables, func:*):void {
        var request:URLRequest = new URLRequest();
        request.url = urlRequest;
        request.requestHeaders = [ new URLRequestHeader( "Content-Type", "application/json" ) ];
        request.method = method;
        variables.format = "json";

        request.data = variables;
        var loader:URLLoader = new URLLoader();
        if( func == null )
            func = onComplete;
        loader.addEventListener( Event.COMPLETE, func );
        loader.load( request );
    }

    // Запрос данных по пользователю
    public static function getUserData(func:*, username:String):void
    {
        var variables:URLVariables = new URLVariables();
        variables.username = username;
        setRequest( URL + USER_URL + "/userdata", URLRequestMethod.GET, variables, func );
    }

    public static function setUserData(player:Player):void
    {
        var variables:URLVariables = new URLVariables();
        variables.username = player.username;
        variables.point = player.recordScore;
        variables.level = player.levelPlayer;
        setRequest( URL + USER_URL + "/setdata", URLRequestMethod.GET, variables, null );
    }

    public static function getLevelData(func:*, level:int):void
    {
        var variables:URLVariables = new URLVariables();
        variables.level = level;
        setRequest( URL + LEVEL_URL + "/leveldata", URLRequestMethod.GET, variables, func );
    }

    public static function onComplete(e:Event):void
    {
        var variables:Object =  com.adobe.serialization.json.JSON.decode( e.target.data );
    }
}
}
