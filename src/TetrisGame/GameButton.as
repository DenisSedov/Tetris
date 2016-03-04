package TetrisGame {

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextField;

public class GameButton extends Sprite {

    private static var buttonNameArraw:Array = [["bPause","Пауза"],["bLastStep", "Предыдущий шаг"],
        ["bNextStep", "Следующий шаг"], ["bHelp", "Помощь"], ["bNew", "Новая игра"]];
    private static var buttonArray:Array = new Array(); // Массив кнопок

    public static var main:Main; // Обьект родителя
    public var caption:String;
    public var activate:Boolean;


    public function GameButton() {
        // Регистрируем новую кнопку
        buttonArray.push(this);
    }

    public function onActivated():Boolean {
        activate = !activate;
        return activate;
    }

    public static function init(parent:Sprite):void {
        var step:int = 0 ;

        for each(var item in buttonNameArraw) {
            var button:GameButton = new GameButton();

            parent.addChild(button);
            button.name = item;
            button.x = 10 + (step * 65);
            button.y = 5;

            drawButtonItems(button);
            //var t:Text = new Text();
            //t.text = item;
            //var tf:TextField = new TextField();
            //tf.text = item;

            //button.addChild(tf);

            button.addEventListener(MouseEvent.MOUSE_OVER, onMouseMove);
            button.addEventListener(MouseEvent.MOUSE_OUT, onMouseMove);
            button.addEventListener(MouseEvent.CLICK, onMouseClick);
            step++;
        }
    }

    // Отрисовка кнопок меню
    private static function drawButtonItems(button:Sprite, color:uint = 0xCCCCCC):void {
        button.graphics.lineStyle(0.1,0x999999);
        button.graphics.beginFill(color);
        button.graphics.drawRoundRect(0,0,65,15, 5);
        button.graphics.endFill();
    }

    // Обработка наведения мыши
    private static function onMouseMove(e:Event):void {
        var button:Sprite;
        if (e.target is Sprite)
            button = Sprite(e.target);
        else if (e.target is TextField)
            button = e.target.parent;
        if (e.type == "mouseOver")
            drawButtonItems(button, 0x999999);
        else
            drawButtonItems(button);
    }

    // Обработка нажатий кнопок
    private static function onMouseClick(e:Event):void {
        var button:GameButton;
        if (e.target is Sprite)
            button = GameButton(e.target);
        else if (e.target is TextField)
            button = e.target.parent;

        // "bPause","bLastStep","bNextStep", "bHelp", "bNew"
        switch (button.name) {
            case "bPause":
                button.onPause();
                break;
            case "bLastStep":
                break;
            case "bNextStep":
                break;
            case "bHelp":
                break;
            case "bNew":
                break;
        }
    }

    function onPause():void {
        if (activate)
            Main.game.pause();
        else
            Main.game.start();
    }

}

}
