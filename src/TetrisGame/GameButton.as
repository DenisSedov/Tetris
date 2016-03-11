package TetrisGame {

import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;

public class GameButton extends Sprite {

                                                // name, caption, activatedEnabled
    private static var buttonInitArraw:Array = [["bPause","Пауза", true],//["bLastStep", "Предыдущий шаг", false],
        /*["bNextStep", "Следующий шаг", false],*/ ["bHelp", "Помощь", true], ["bNew", "Новая игра", false]];

    private static var buttonArray:Array = new Array(); // Массив кнопок

    public static var main:Main; // Обьект родителя
    public var caption:String;

    private var activatedEnabled:Boolean;
    private var _activate:Boolean = false;

    private static var format:TextFormat = new TextFormat("Arial", 14, 0x708090, "bold");


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

    // Устанавливаем значения по умолчанию
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
            var tray:int = 0;
            parent.addChild(button);
            button.name = item[0];
            button.x = 25 + (step * 100);
            button.y = 5;
            button.caption = item[1];
            button.activatedEnabled = item[2];
            button.setDefault();
            var tf:TextField = new TextField();
            button.addChild(tf);
            drawButtonItems(button);
            tf.selectable = false;
            tf.autoSize = TextFieldAutoSize.LEFT;
            tf.defaultTextFormat = format;
            tf.text = item[1];
            tf.x = (button.width - tf.width) * .5;
            tf.y = (button.height - tf.height) * .5;

            button.addEventListener(MouseEvent.MOUSE_OVER, onMouseMove);
            button.addEventListener(MouseEvent.MOUSE_OUT, onMouseMove);
            button.addEventListener(MouseEvent.CLICK, onMouseClick);
            //tray += 10;
            step++;
        }
    }

    // Отрисовка кнопок меню
    private static function drawButtonItems(button:GameButton, color:uint = 0xCCCCCC):void {
        button.graphics.lineStyle(0.1,0x999999);
        if (button.activate)
            color = 0xFFFFCC;
        button.graphics.beginFill(color);
        button.graphics.drawRoundRect(0,0,100,20, 5);
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
                search("bPause").onPause();
                break;
        }
    }

    private static function search(name:String): GameButton {
        for each(var item:GameButton  in buttonArray) {
            if (item.name == name) {
                return item;
            }
        }
        return null;
    }

    private function onPause():void {
        if (activate)
            Main.game.pause();
        else
            Main.game.start();
    }
}

}
