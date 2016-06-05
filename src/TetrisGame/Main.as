package TetrisGame
{

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.utils.Timer;
import flash.events.TimerEvent;
import flash.text.TextField;

import mx.utils.StringUtil;

import vk.APIConnection;

public class Main extends Sprite
{
    public var currentTimer:Timer = new Timer( 500 ); // Таймер для обратного отсчета времени

    private static const TEXT_FORMAT:TextFormat = new TextFormat( "Arial", 12, 0x000000, "bold" );

    public static var game:Game; // Обьект игры
    public static var player:Player; // Обьект игрока

    private var _assetManager = AssetManager.instance;
    private var _flashVars:Object;
    private var _APIConnectionVK: APIConnection;

    public function Main()
    {
        if ( stage )
        {
            init();
        }
        else
        {
            addEventListener( Event.ADDED_TO_STAGE, init );
        }
    }

    private function init(e: Event = null): void
    {
        if( e )
        {
            removeEventListener( e.type, init );
        }
        _flashVars = stage.loaderInfo.parameters as Object;
        _flashVars[ 'api_id' ] = 5353032;
        _flashVars[ 'viewer_id' ] = 29421457;
        _flashVars[ 'sid' ] = "07b3961a9ba30507d94732542285e0e959fc353874f8b963f381511c7c5251029fd5a1444cbe848a1d0d7";
        _flashVars[ 'secret' ] = "0e8658ca00";
        _APIConnectionVK = new APIConnection( _flashVars );
        var background:Sprite = new Sprite();
        background.name = "Background";
        addChild( background );

        _assetManager.getAsset( "img/background.jpg", onCompleteAsset );
        // Создаем игрока
        player = new Player( this, _flashVars[ 'viewer_id' ] );
        // Расставляем обьекты по сцене
        drawTop(); // Верхняя панель
        // Отрисовка информации
        drawItems();
        // Создаем игру
        game = new Game( player, this );
        addChild( game );
        game.y = 30;
        game.x = 85;
        game.newGame();

        currentTimer.addEventListener( TimerEvent.TIMER, onCurrentTime );
        currentTimer.start();
    }

    // object.fileName
    // object.target
    private function onCompleteAsset(object:Object):void
    {
        switch( object.fileName )
        {
            case "img/background.jpg":
                var background:Sprite = getChildByName( "Background" ) as Sprite;
                if( background )
                {
                    background.addChildAt( object.target, 0 );
                }
                break;
            case "swf/TopPanel.swf":
                var panel:Sprite = getChildByName( "TopPanel" ) as Sprite;
                if ( panel )
                {
                    panel.addChildAt( object.target, 0 );
                }
        }
    }

    // Таймер работает всегда, отсчитывет время игры
    private function onCurrentTime(e:TimerEvent):void
    {
        // Уменьшение времени игрока
        player.currentTimePlayer--;
        // Отрисовка оставшегося времени
        drawTime();
    }

    // Формирование оставшегося времени
    public function drawTime():void
    {
        var textField:TextField = TextField( getChildByName( "textTime" ) );
        if ( textField == null )
        {
            return;
        }
        var time:int = player.currentTimePlayer;
        var minutes:int = int( time / 60 );
        var seconds:int = time -( minutes * 60 );
        var zero1:String = '';
        var zero2:String = '';
        if( minutes < 10 )
            zero1 = '0';
        if( seconds < 10 )
            zero2 = '0';
        textField.text = StringUtil.substitute( "{0}{1}:{2}{3}", zero1, minutes, zero2, seconds );
        textField.x = 250 + ( 100 - textField.width ) * .5;
    }

    // Отрисовка верхней панели игры
    private function drawTop():void
    {
        var topPanel:Sprite = new Sprite();
        addChild( topPanel );
        topPanel.name = "TopPanel";
        _assetManager.getAsset( "swf/TopPanel.swf", onCompleteAsset, "TopPanel" );
        GameButton.main = this;
        GameButton.init( topPanel );
    }

    // Конец игры
    public function endGame():void
    {
        currentTimer.stop();
        game.endGame();
    }

    // Обновление данных по игре
    public function reloadData():void
    {
        var tl:TextField = TextField( getChildByName( "textLevel" ) );
        if( tl )
        {
            tl.text =  player.levelPlayer.toString();
            tl.x = 250 + ( 100 - tl.width ) * .5;
        }
        var ts:TextField = TextField( getChildByName( "textScore" ) );
        if( ts )
        {
            ts.text = player.scorePlayer.toString() + '/' + player.scoreLevelPlayer.toString();
            ts.x = 250 + ( 100 - ts.width ) * .5;
        }
        var tr:TextField = TextField(getChildByName( "textYouRecord" ) );
        if( tr )
        {
            tr.text = player.recordScore.toString();
            tr.x = 250 + ( 100 - tr.width) * .5;
        }
    }

    private function formatText(textField:TextField):void {
        textField.selectable = false;
        textField.autoSize = TextFieldAutoSize.LEFT;
        textField.defaultTextFormat = TEXT_FORMAT;
        textField.x = 250 + ( 100 - textField.width ) * .5;
    }

    // Отрисовка информации игрока
    private function drawItems():void {
        var itemsArray:Array = [["Уровень:", "textLevel"], ["Очков:", "textScore"],
                                ["Оставшееся время:", "textTime"], ["Ваш рекорд:", "textYouRecord"]];
        var localY:int = 100;
        for each( var item in itemsArray )
        {
            var tf:TextField = new TextField();
            addChild( tf );
            tf.text = item[ 0 ];
            formatText( tf );
            tf.y = localY;
            tf.text = item[ 0 ];

            var af:TextField = new TextField();
            af.name = item[ 1 ];
            addChild( af );
            af.y = localY + 20;
            formatText( af );
            localY += 50;
        }
        drawTime();
        reloadData();
    }
}
}
