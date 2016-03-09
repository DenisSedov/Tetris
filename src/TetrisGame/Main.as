
package TetrisGame {

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextFormat;
import flash.utils.Timer;
import flash.events.TimerEvent;
import flash.events.KeyboardEvent;
import flash.text.TextField;

import mx.controls.Text;
import mx.utils.StringUtil;

import spark.components.Button;

public class Main extends Sprite {

    private const indentRightX:int = 275; // Отступ справа для фигуры

    //private var scorePlayer:uint = 0; // Количество очков
    //private var levelPlayer:uint = 1; // Уровень игрока
    //private var currentTimePlayer:uint = 0; // Оставлшееся время игрока

    // Для достижения очередного уровня
    private var timeLevelPlayer:uint = 0; // Время на очередном уровне
    private var scoreLevelPlayer:uint = 0; // Количество очков для достижения уровня

    private var currentTimer:Timer = new Timer(1000); // Таймер для обратного отсчета времени

    public static var game:Game; // Обьект игры
    public static var player:Player; // Обьект игрока
    public static var gameInterface:GameInterface; // Главный обьект всего пространства

    private var buttonArray:Array; // Массив кнопок

    public function Main() {

        //var server:Server = new Server();
        //server.getUserData("Denis");
        //trace("main");


        // Создаем игрока
        player = new Player(this);
        // Расставляем обьекты по сцене
        drawTop(); // Верхняя панель
        // Отрисовка информации
        drawItems();
        // Создаем игру
        game = new Game(player, this);
        addChild(game);
        game.y = 30;
        game.x = 85;
        game.newGame();

        currentTimer.addEventListener(TimerEvent.TIMER, onCurrentTime);
        currentTimer.start();
    }

    // Таймер работает всегда, отсчитывет время игры
    private function onCurrentTime(e:TimerEvent):void {
        // Уменьшение времени игрока
        player.currentTimePlayer--;
        // Отрисовка оставшегося времени
        drawTime();
    }

    // Формирование оставшегося времени
    private function drawTime():void {
        var tt:TextField = TextField(getChildByName("textTime"));
        var time:int = player.currentTimePlayer;
        var minutes:int = int(time/60);
        var seconds:int = time -(minutes * 60);
        var zero1:String = '';
        var zero2:String = '';
        if (minutes < 10)
            zero1 = '0';
        if (seconds < 10)
            zero2 = '0';
        if (tt != null) {
            tt.text = StringUtil.substitute("{0}{1}:{2}{3}",zero1, minutes, zero2, seconds);
        }
    }

    // Отрисовка верхней панели игры
    private function drawTop():void {
        var sTop: Sprite = new Sprite();
        addChild(sTop);
        sTop.name = "sTop";
        sTop.graphics.beginFill(0xCCCCCC);
        sTop.graphics.drawRect(0, 0, 350, 25);
        sTop.graphics.endFill();
        GameButton.main = this;
        GameButton.init(sTop);
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

    // Новая игра
    public function startGame():void {

    }

    // Конец игры
    public function endGame():void {
        currentTimer.stop();
        game.endGame();
    }

    // Обновление данных по игре
    public function reloadData():void {
        var tl:TextField = TextField(getChildByName("textLevel"));
        if (tl != null) {
            tl.text =  player.levelPlayer.toString();

        }
        var ts:TextField = TextField(getChildByName("textScore"));
        if (ts != null) {
            ts.text = player.scorePlayer.toString();
        }
    }

    // Отрисовка информации игрока
    private function drawItems():void {

        var itemsPlayer:Sprite = new Sprite();
        addChild(itemsPlayer);
        itemsPlayer.name = "itemsPlayer";
        itemsPlayer.graphics.beginFill(0xCCCCCC);
        itemsPlayer.graphics.drawRect(250, 100, 100, 230);
        itemsPlayer.graphics.endFill();

        // Уровень
        var textLevel:TextField = new TextField();
        textLevel.text = "Уровень:";
        textLevel.name = "textLevel";
        itemsPlayer.addChild(textLevel);
        textLevel.x = indentRightX;
        textLevel.y = 100;

        // Очков
        var textScore:TextField = new TextField();
        textScore.text = "Очков:"
        textScore.name = "textScore";
        textScore.x = indentRightX;
        textScore.y = 150;
        addChild(textScore);

        // Оставшееся время
        var textTime:TextField = new TextField();
        textTime.text = "Оставшееся время:"
        textTime.name = "textTime";
        textTime.x = indentRightX;
        textTime.y = 200;
        addChild(textTime);

    //Ваш рекорд
    // Лучший результат



    }




}
}
