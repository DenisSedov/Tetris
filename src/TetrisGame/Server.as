package TetrisGame {

import flash.events.Event;
import flash.net.URLLoader;
import flash.net.URLRequest;

import com.adobe.serialization.json.JSON;

import flash.net.URLRequestHeader;
import flash.net.URLRequestMethod;
import flash.net.URLVariables;
import flash.utils.Dictionary;


// Класс работы с сервером
public class Server {
    private static const url:String = "http://localhost:3000/";
    private static const userUrl:String = "users";
    private static const levelUrl:String = "levels";

    public function Server() {
    }

    // Запрос данных по пользователю
    public static function getUserData(username:String):void {
        var request:URLRequest = new URLRequest();
        request.url = url + userUrl + "/userdata";
        request.requestHeaders = [new URLRequestHeader("Content-Type", "application/json")];
        request.method = URLRequestMethod.GET;
        var variables:URLVariables = new URLVariables();
        variables.username = username; //"Denis";
        variables.format = "json";
        request.data = variables;
        var loader:URLLoader = new URLLoader();
        loader.addEventListener(Event.COMPLETE, userComplete);
        //loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, notAllowed);
        //loader.addEventListener(IOErrorEvent.IO_ERROR, notFound);
        loader.load(request);

    }

    // Запрос данных по уровню
    public static function getLevelData(level:uint):void {
        var request:URLRequest = new URLRequest();
        request.url = url + levelUrl + "/leveldata";
        request.requestHeaders = [new URLRequestHeader("Content-Type", "application/json")];
        request.method = URLRequestMethod.GET;
        var variables:URLVariables = new URLVariables();
        variables.level = level.toString(); //"1";
        variables.format = "json";
        request.data = variables;
        var loader:URLLoader = new URLLoader();
        loader.addEventListener(Event.COMPLETE, userComplete);
        //loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, notAllowed);
        //loader.addEventListener(IOErrorEvent.IO_ERROR, notFound);
        loader.load(request);

    }

    // Присвоение очередного уровня
    public static function nextLevel():void {

    }

    public static function userComplete(e:Event):void {
        var variables:URLVariables = new URLVariables( e.target.data );
        trace (variables.res);
    }

    public static function getLevel(l:uint):Dictionary {
        var res:Dictionary = new Dictionary();
        res["point"] = 40;
        res["time"] = 60;
        return res;
    }



}
}
