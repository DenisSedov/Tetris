package TetrisGame {

import flash.display.Loader;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;

import com.adobe.serialization.json.JSON;

import flash.net.URLRequestHeader;
import flash.net.URLRequestMethod;
import flash.net.URLVariables;
import flash.system.LoaderContext;
import flash.utils.Dictionary;


// Класс работы с сервером
public class Server {
    private static const url:String = "https://fathomless-earth-78839.herokuapp.com/";//"http://localhost:3000/";
    private static const userUrl:String = "users";
    private static const levelUrl:String = "levels";

    public function Server() {
    }

    private static function setRequest(urlRequest:String, method:String, variables:URLVariables, func:*):void {
        var request:URLRequest = new URLRequest();
        request.url = urlRequest;
        //request.requestHeaders = [new URLRequestHeader("Content-Type", "application/json")];
        request.method = method;
        variables.format = "json";

        request.data = variables;
        var loader:URLLoader = new URLLoader();
        if (func == null)
            func = onComplete;
        loader.addEventListener(Event.COMPLETE, func);
        loader.addEventListener(ProgressEvent.PROGRESS, onProgressInternal);
        loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, onErrorInternal);
        loader.load(request);
    }

    private static function onProgressInternal(e:ProgressEvent):void {
        trace(e.toString());
    }

    private static function onErrorInternal(e:SecurityErrorEvent):void {
        trace(e.toString());
    }

    // Запрос данных по пользователю
    public static function getUserData(func:*, username:String):void {
        var variables:URLVariables = new URLVariables();
        variables.username = username;
        setRequest(url + userUrl + "/userdata", URLRequestMethod.GET, variables, func);
    }

    public static function setUserData(player:Player):void {
        var variables:URLVariables = new URLVariables();
        variables.username = player.username;
        variables.point = player.recordScore;
        variables.level = player.levelPlayer;
        setRequest(url + userUrl + "/setdata", URLRequestMethod.GET, variables, null);
    }

    public static function getLevelData(func:*, level:int):void {
        var variables:URLVariables = new URLVariables();
        variables.level = level;
        setRequest(url + levelUrl + "/leveldata", URLRequestMethod.GET, variables, func);

    }

    // Присвоение очередного уровня
    public static function nextLevel():void {

    }

    public static function userComplete(e:Event):void {
        var variables:Object =  com.adobe.serialization.json.JSON.decode(e.target.data);
        trace (variables);
    }

    public static function onComplete(e:Event):void {
        var variables:Object =  com.adobe.serialization.json.JSON.decode(e.target.data);
        trace (variables);
    }

    public static function getLevel(l:uint):Dictionary {
        var res:Dictionary = new Dictionary();
        res["point"] = 40;
        res["time"] = 60;
        return res;
    }



}
}
