
package TetrisGame {

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.text.TextFormat;
import flash.utils.Timer;
import flash.events.TimerEvent;
import flash.events.KeyboardEvent;
import flash.text.TextField;
import spark.components.Button;


public class Main extends Sprite {

    private const indentRightX:int = 175; // Отступ справа для фигуры

    private var scorePlayer:uint = 0; // Количество очков
    private var levelPlayer:uint = 1; // Уровень игрока
    private var currentTimePlayer:uint = 0; // Оставлшееся время игрока

    // Для достижения очередного уровня
    private var timeLevelPlayer:uint = 0; // Время на очередном уровне
    private var scoreLevelPlayer:uint = 0; // Количество очков для достижения уровня

    private var currentTimer:Timer = new Timer(1000); // Таймер для обратного отсчета времени

    public static var game:Game; // Обьект игры
    public static var player:Player; // Обьект игрока
    public static var gameInterface:GameInterface; // Главный обьект всего пространства

    public function Main() {
        var server:Server = new Server();
        server.getUserData("Denis");
        trace("main");
        // Создаем игрока
        player = new Player();
        // Создаем игру
        game = new Game(player, this);
        addChild(game);
        game.y = 25;
        game.newGame();
        // Отрисовка информации

       // drawTop();
        drawItems();
        currentTimer.addEventListener(TimerEvent.TIMER, onCurrentTime);
    }

    // Таймер работает всегда, отсчитывет время игры
    private function onCurrentTime(e:TimerEvent):void {
        if (currentTimePlayer > 0) {
            currentTimePlayer--;
        }
    }

    // Отрисовка верхней панели игры
    private function drawTop():void {
        var bPause:Button = new Button();
        bPause.name = "bPause";
        bPause.label = "Пауза";
        //addChild(bPause);
        bPause.height = 50;
        bPause.width = 50;
        bPause.x = 300;
        bPause.y = 300;

    }

    // Форматирование текста надписей
    private function getFormatText():TextFormat {
        var tf:TextFormat = new TextFormat();
        tf.align =  "center";
        tf.bold = true;
        tf.color = 0xFF0000;
        tf.font = "Courier";
        return tf;
    }

    // Обновление данных по игре
    public function reloadData():void {
        var tl:TextField = TextField(getChildByName("textLevel"));
        if (tl != null) {
            tl.text = levelPlayer.toString();

        }
        var ts:TextField = TextField(getChildByName("textScore"));
        if (ts != null) {
            ts.text = scorePlayer.toString();
        }
    }

    // Отрисовка информации игрока
    private function drawItems():void {

        // Уровень
        var textLevel:TextField = new TextField();
        textLevel.text = "Уровень:";
        textLevel.name = "textLevel";
        textLevel.x = indentRightX;
        textLevel.y = 100;
        addChild(textLevel);
        // Очков
        var textScore:TextField = new TextField();
        textScore.text = "Очков:"
        textScore.name = "textScore";
        textScore.x = indentRightX;
        textScore.y = 150;
        addChild(textScore);

    // Оставшееся время
    //Ваш рекорд
    // Лучший результат



    }




}
}
