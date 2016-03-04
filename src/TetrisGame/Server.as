package TetrisGame {

import flash.events.Event;
import flash.net.URLLoader;
import flash.net.URLRequest;

import com.adobe.serialization.json.JSON;

import flash.net.URLRequestHeader;
import flash.net.URLRequestMethod;
import flash.net.URLVariables;


// Класс работы с сервером
public class Server {
    private const url:String = "http://localhost:3000/";
    private const userUrl:String = "users";
    private const levelUrl:String = "level";

    public function Server() {
    }


    public function getUserData(username:String):void {
        var request:URLRequest = new URLRequest();
        request.url = url + userUrl + "/userdata";
        request.requestHeaders = [new URLRequestHeader("Content-Type", "application/json")];
        request.method = URLRequestMethod.GET;
        var variables:URLVariables = new URLVariables();
        variables.username = "Denis";
        variables.format = "json";
        request.data = variables;
        var loader:URLLoader = new URLLoader();
        loader.addEventListener(Event.COMPLETE, userComplete);
        //loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, notAllowed);
        //loader.addEventListener(IOErrorEvent.IO_ERROR, notFound);
        loader.load(request);

    }

    public function userComplete(e:Event):void {
        var variables:URLVariables = new URLVariables( e.target.data );
        trace (variables.res);
    }

    //public function

}
}
