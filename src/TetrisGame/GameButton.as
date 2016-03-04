package TetrisGame {

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextField;

public class GameButton extends Sprite {

                                                // name, caption, activatedEnabled
    private static var buttonInitArraw:Array = [["bPause","Пауза", true],["bLastStep", "Предыдущий шаг", false],
        ["bNextStep", "Следующий шаг", false], ["bHelp", "Помощь", true], ["bNew", "Новая игра", false]];

    private static var buttonArray:Array = new Array(); // Массив кнопок

    public static var main:Main; // Обьект родителя
    public var caption:String;

    private var activatedEnabled:Boolean;
    private var _activate:Boolean = false;


    public function GameButton() {
        // Регистрируем новую кнопку
        buttonArray.push(this);
    }

    public function get activate():Boolean {
        return _activate;
    }

    public function set activate(value:Boolean):void {
        _activate = value;
        // Меняем отрисовку
        drawButtonItems(this);
    }

    //
    private function setDefault():void {
        switch (name) {
            case "bHelp":
                activate = true;
                break;
        }
    }

    public function onActivated():Boolean {
        if (activatedEnabled)
            activate = !activate;
        return activate;
    }

    public static function init(parent:Sprite):void {
        var step:int = 0 ;

        for each(var item in buttonInitArraw) {
            var button:GameButton = new GameButton();

            parent.addChild(button);
            button.name = item[0];
            button.x = 10 + (step * 65);
            button.y = 5;
            button.caption = item[1];
            button.activatedEnabled = item[2];
            button.setDefault();

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
    private static function drawButtonItems(button:GameButton, color:uint = 0xCCCCCC):void {
        button.graphics.lineStyle(0.1,0x999999);
        if (button.activate)
            color = 0xFFFFCC;
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
            drawButtonItems(GameButton(button), 0x999999);
        else
            drawButtonItems(GameButton(button));
    }

    // Обработка нажатий кнопок
    private static function onMouseClick(e:Event):void {
        var button:GameButton;
        if (e.target is Sprite)
            button = GameButton(e.target);
        else if (e.target is TextField)
            button = e.target.parent;
        button.onActivated();
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
                Main.game.visibleNextFigure(button.activate);
                break;
            case "bNew":
                Main.game.newGame();
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
