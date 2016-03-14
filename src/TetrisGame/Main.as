
package TetrisGame {

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.utils.Timer;
import flash.events.TimerEvent;
import flash.events.KeyboardEvent;
import flash.text.TextField;

import mx.controls.Text;
import mx.utils.StringUtil;

import spark.components.Button;

import vk.APIConnection;

public class Main extends Sprite {

    private const indentRightX:int = 275; // Отступ справа для фигуры
    private static var format:TextFormat = new TextFormat("Arial", 12, 0x000000, "bold");

    //private var scorePlayer:uint = 0; // Количество очков
    //private var levelPlayer:uint = 1; // Уровень игрока
    //private var currentTimePlayer:uint = 0; // Оставлшееся время игрока

    // Для достижения очередного уровня
    private var timeLevelPlayer:uint = 0; // Время на очередном уровне
    private var scoreLevelPlayer:uint = 0; // Количество очков для достижения уровня

    public var currentTimer:Timer = new Timer(1000); // Таймер для обратного отсчета времени

    public static var game:Game; // Обьект игры
    public static var player:Player; // Обьект игрока
   // public static var gameInterface:GameInterface; // Главный обьект всего пространства

    private var buttonArray:Array; // Массив кнопок

    private var flashVars:Object;
    private var VK: APIConnection;

    public function Main() {

        if (stage)
            init();
        else
            addEventListener(Event.ADDED_TO_STAGE, init);
    }

    private function onApiRequestFail(data: Object): void {
        var dat:Object = data;

    }

    private function fetchUserInfo(data: Object): void {
        var dat:Object = data;

    }

    private function init(e: Event = null): void {
        if (e)
            removeEventListener(e.type, init);

        flashVars = stage.loaderInfo.parameters as Object;
        flashVars['api_id'] = 5353032;
        flashVars['viewer_id'] = 29421457;
        flashVars['sid'] = "07b3961a9ba30507d94732542285e0e959fc353874f8b963f381511c7c5251029fd5a1444cbe848a1d0d7";
        flashVars['secret'] = "0e8658ca00";

        VK = new APIConnection(flashVars);

        //VK.callMethod()
        VK.api('friends.get', { uid: flashVars['viewer_id'] }, fetchUserInfo, onApiRequestFail)
        var texture:DisplayObject = LoaderTexture.getBackground();
        addChild(texture);

        // Создаем игрока
        player = new Player(this, flashVars['viewer_id']);
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
    public function drawTime():void {
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
            tt.x = 250 + (100 - tt.width) * .5;
        }
    }

    // Отрисовка верхней панели игры
    private function drawTop():void {
        var sTop: Sprite = new Sprite();
        addChild(sTop);
        sTop.name = "sTop";
        sTop.graphics.beginFill(0xCCCCCC);
        sTop.graphics.drawRect(0, 0, 350, 30);
        sTop.graphics.endFill();
        GameButton.main = this;
        GameButton.init(sTop);
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
            tl.x = 250 + (100 - tl.width) * .5;
        }
        var ts:TextField = TextField(getChildByName("textScore"));
        if (ts != null) {
            ts.text = player.scorePlayer.toString() + '/' + player.scoreLevelPlayer.toString();
            ts.x = 250 + (100 - ts.width) * .5;
        }
        var tr:TextField = TextField(getChildByName("textYouRecord"));
        if (tr != null) {
            tr.text = player.recordScore.toString();
            tr.x = 250 + (100 - tr.width) * .5;
        }
    }

    private function formatText(tf:TextField):void {
        tf.selectable = false;
        tf.autoSize = TextFieldAutoSize.LEFT;
        tf.defaultTextFormat = format;
        tf.x = 250 + (100 - tf.width) * .5;
    }

    // Отрисовка информации игрока
    private function drawItems():void {
        var itemsArray:Array = [["Уровень:", "textLevel"], ["Очков:", "textScore"],
                ["Оставшееся время:", "textTime"], ["Ваш рекорд:", "textYouRecord"]];

        var localY:int = 100;
        for each(var item in itemsArray) {
            var tf:TextField = new TextField();
            addChild(tf);
            tf.text = item[0];
            formatText(tf);
            tf.y = localY;
            tf.text = item[0];

            var af:TextField = new TextField();
            af.name = item[1];
            addChild(af);
            af.y = localY + 20;
            formatText(af);

            localY += 50;
        }
        drawTime();
        reloadData();
    }

}
}
