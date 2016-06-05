package TetrisGame
{

import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

public class GameButton extends Sprite
{
    public static var main:Main; // Обьект родителя

    public var caption:String;
                                             // name, caption, _activatedEnabled
    private static const INIT_ARRAY:Array = [["bPause","Пауза", true], ["bHelp", "Помощь", true], ["bNew", "Новая игра", false]];
    private static const TEXT_FORMAT:TextFormat = new TextFormat( "Arial", 14, 0x708090, "bold" );

    private static var _buttonArray:Vector.<GameButton> = new Vector.<GameButton>(); // Массив кнопок
    private static var _assetManager = AssetManager.instance;

    private var _buttonClip:MovieClip;
    private var _activatedEnabled:Boolean;
    private var _activate:Boolean = false;

    public function GameButton()
    {
        // Регистрируем новую кнопку
        _buttonArray.push( this );
        _assetManager.getAsset( "swf/GameButton.swf", onCompleteAsset, "GameButton" );
    }

    // object.fileName
    // object.target
    private function onCompleteAsset(object:Object):void
    {
        switch( object.fileName )
        {
            case  "swf/GameButton.swf":
                _buttonClip = object.target;
                addChildAt( _buttonClip, 0 );
                drawButtonItems();
                break;
        }
    }

    public function get activate():Boolean
    {
        return _activate;
    }

    public function set activate(value:Boolean):void
    {
        _activate = value;
        // Меняем отрисовку
        this.drawButtonItems();
    }

    // Устанавливаем значения по умолчанию
    private function setDefault():void
    {
        switch(name)
        {
            case "bHelp":
                    activate = true;
                    break;
        }
    }

    public function onActivated():Boolean
    {
        if( _activatedEnabled )
            activate = !activate;
        return activate;
    }

    public static function init(parent:Sprite):void
    {
        var step:int = 0;
        for each( var item in INIT_ARRAY )
        {
            var button:GameButton = new GameButton();
            parent.addChild( button );
            button.name = item[ 0 ];
            button.x = 15 + ( step * 110 );
            button.y = 5;
            button.caption = item[ 1 ];
            button._activatedEnabled = item[ 2 ];
            button.setDefault();

            var textField:TextField = new TextField();
            button.addChild( textField );
            button.drawButtonItems();
            textField.selectable = false;
            textField.autoSize = TextFieldAutoSize.LEFT;
            textField.defaultTextFormat = TEXT_FORMAT;
            textField.text = item[ 1 ];
            textField.x = ( 100 - textField.width ) * .5;
            textField.y = ( 20 - textField.height ) * .5;

            button.addEventListener(MouseEvent.MOUSE_OVER, onMouseMove);
            button.addEventListener(MouseEvent.MOUSE_OUT, onMouseMove);
            button.addEventListener(MouseEvent.CLICK, onMouseClick);
            step++;
        }
    }

    // Отрисовка кнопок меню
    private function drawButtonItems(mouseMove:Boolean = false):void
    {
        if ( _buttonClip == null)
        {
            return;
        }
        var frame:uint = 1;
        if ( mouseMove )
        {
            frame = 2;
        }
        if (activate)
        {
            frame = 3;
        }
        _buttonClip.gotoAndStop(frame);
    }

    // Обработка наведения мыши
    private static function onMouseMove(e:Event):void
    {
        GameButton( e.currentTarget ).drawButtonItems( e.type == "mouseOver" );
    }

    // Обработка нажатий кнопок
    private static function onMouseClick(e:Event):void
    {
        var button:GameButton = GameButton( e.currentTarget );
        button.onActivated();
        // "bPause","bLastStep","bNextStep", "bHelp", "bNew"
        switch( button.name )
        {
            case "bPause":
                    button.onPause();
                    break;
            case "bLastStep":
                    break;
            case "bNextStep":
                    break;
            case "bHelp":
                    Main.game.visibleNextFigure( button.activate );
                    break;
            case "bNew":
                    Main.game.newGame();
                    search( "bPause" ).onPause();
                    break;
        }
    }

    private static function search(name:String):GameButton
    {
        for each( var item:GameButton in _buttonArray)
        {
            if ( item.name == name )
            {
                return item;
            }
        }
        return null;
    }

    private function onPause():void
    {
        if (activate)
        {
            Main.game.pause();
        }
        else
        {
            Main.game.start();
        }
    }
}
}
