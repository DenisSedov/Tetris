
package TetrisGame {

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.DRMReturnVoucherCompleteEvent;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.system.Security;
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

[SWF(width="500", height="600", frameRate="31", backgroundColor="#FFFFFF")]
public class Main extends Sprite {

    private const indentTextX:int = 350; //  Отступ для текста
    private static var format:TextFormat = new TextFormat("Arial", 12, 0x000000, "bold");

    // Для достижения очередного уровня
    private var timeLevelPlayer:uint = 0; // Время на очередном уровне
    private var scoreLevelPlayer:uint = 0; // Количество очков для достижения уровня

    public var currentTimer:Timer = new Timer(1000); // Таймер для обратного отсчета времени

    public static var game:Game; // Обьект игры
    public static var player:Player; // Обьект игрока

    private var dlgEndGame:Sprite; // Диалог завершения игры

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
        if (flashVars.api_id == null)
        {
            flashVars['api_id'] = 5353032;
            flashVars['viewer_id'] = 29421457;
            flashVars['sid'] = "07b3961a9ba30507d94732542285e0e959fc353874f8b963f381511c7c5251029fd5a1444cbe848a1d0d7";
            flashVars['secret'] = "0e8658ca00";
        }
        VK = new APIConnection(flashVars);

        //VK.callMethod()
        //VK.api('friends.get', { uid: flashVars['viewer_id'] }, fetchUserInfo, onApiRequestFail)
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
        game.x = 70;
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
            tt.x = indentTextX + (100 - tt.width) * .5;
        }
    }

    // Отрисовка верхней панели игры
    private function drawTop():void {
        var sTop: Sprite = new Sprite();
        addChild(sTop);
        sTop.name = "sTop";
        sTop.graphics.beginFill(0xCCCCCC);
        sTop.graphics.drawRect(0, 0, 500, 30);
        sTop.graphics.endFill();
        GameButton.main = this;
        GameButton.init(sTop);
    }

    // Новая игра
    public function startGame():void {
        currentTimer.start();
    }

    // Конец игры
    public function endGame():void {
        currentTimer.stop();
        game.endGame();
        endGameDialog();
    }

    private function endGameDialog():void {
        dlgEndGame = new Sprite();
        dlgEndGame.name = "dlgEndGame";
        dlgEndGame.graphics.lineStyle(0.1,0x999999);
        dlgEndGame.graphics.beginFill(0xCCCCCC);
        dlgEndGame.graphics.drawRoundRect(0,0,300,30, 5);
        dlgEndGame.graphics.endFill();
        addChild(dlgEndGame);
        dlgEndGame.x = 100;
        dlgEndGame.y = 200;

        var tf:TextField = new TextField();
        dlgEndGame.addChild(tf);
        tf.selectable = false;
        tf.autoSize = TextFieldAutoSize.LEFT;
        tf.defaultTextFormat = format;
        tf.text = "Игра окончена.";
        tf.x = (dlgEndGame.width - tf.width) * .5;
        tf.y = (dlgEndGame.height - tf.height) * .5;
        dlgEndGame.addEventListener(MouseEvent.CLICK, onMouseClickEndGame);
        addEventListener(MouseEvent.CLICK, onMouseClickEndGame);
    }

    private function onMouseClickEndGame(e:Event):void {
        dlgEndGame.removeEventListener(MouseEvent.CLICK, onMouseClickEndGame);
        removeEventListener(MouseEvent.CLICK, onMouseClickEndGame);
        removeChild(dlgEndGame);
        game.newGame();
    }

    // Обновление данных по игре
    public function reloadData():void {
        var tl:TextField = TextField(getChildByName("textLevel"));
        if (tl != null) {
            tl.text =  player.levelPlayer.toString();
            tl.x = indentTextX + (100 - tl.width) * .5;
        }
        var ts:TextField = TextField(getChildByName("textScore"));
        if (ts != null) {
            ts.text = player.scorePlayer.toString() + '/' + player.scoreLevelPlayer.toString();
            ts.x = indentTextX + (100 - ts.width) * .5;
        }
        var tr:TextField = TextField(getChildByName("textYouRecord"));
        if (tr != null) {
            tr.text = player.recordScore.toString();
            tr.x = indentTextX + (100 - tr.width) * .5;
        }
    }

    private function formatText(tf:TextField):void {
        tf.selectable = false;
        tf.autoSize = TextFieldAutoSize.LEFT;
        tf.defaultTextFormat = format;
        tf.x = indentTextX + (100 - tf.width) * .5;
    }

    // Отрисовка информации игрока
    private function drawItems():void {
        var itemsArray:Array = [["Уровень:", "textLevel"], ["Очков:", "textScore"],
                ["Оставшееся время:", "textTime"], ["Ваш рекорд:", "textYouRecord"]];

        var localY:int = 150;
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
