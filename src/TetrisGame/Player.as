package TetrisGame
{

import flash.events.Event;

import com.adobe.serialization.json.JSON;

// Класс игрока, содержит все данные относящиеся к игроку
public class Player
{
    public var username:String;
    public var recordScore:uint;
    public var scoreLevelPlayer:Number = -1; // Количество очков для достижения уровня

    private var _main:Main;
    private var _scorePlayer:Number = -1; // Текущее количество очков
    private var _levelPlayer:Number = -1; // Уровень игрока
    private var _currentTimePlayer:Number = -1; // Оставлшееся время игрока
    private var _timeLevelPlayer:Number = -1; // Время на очередном уровне

    public function Player(m:Main, name:String)
    {
        _main = m;
        username = name;
        initUserData();
    }

    // Неудачное завершение уровня
    private function failedLevel():void
    {
        // Останавливаем отсчет таймера
        _main.endGame();
    }

    // Удачное завершение уровня
    private function completedLevel():void
    {
        // Новый уровень
        levelPlayer++;
        recordScore += scorePlayer;
        // Отправляем данные на сервер
        Server.setUserData( this );
        _scorePlayer = -1;
        _currentTimePlayer = -1;
        //Начинаем новую игру
        Main.game.newGame();
    }

    // Проверка завершения уровня
    private function validCompleted():void
    {
        // Проверка времени
        if( _currentTimePlayer == 0 )
            failedLevel();
        // Проверка очков
        if( ( _scorePlayer >= scoreLevelPlayer ) && ( _scorePlayer != -1 && scoreLevelPlayer != -1 ) )
            completedLevel();
    }

    public function set scorePlayer(value:uint):void
    {
        _scorePlayer = value;
        validCompleted();
    }

    public function get scorePlayer():uint
    {
        return _scorePlayer;
    }

    public function set levelPlayer(value:uint):void
    {
        _levelPlayer = value;
        // Отправляем данные на сервер
        initLevelData();
    }

    public function get levelPlayer():uint
    {
        return _levelPlayer;
    }

    public function set currentTimePlayer(value:uint):void
    {
        _currentTimePlayer = value;
        validCompleted();
    }

    public function get currentTimePlayer():uint
    {
        return _currentTimePlayer;
    }

    public function reloadData():void
    {
        _currentTimePlayer = _timeLevelPlayer;
        _scorePlayer = 0;
    }

    // Подсчитывает количество очков за удаление строк
    public function setScore(count:uint):void
    {
        var res:uint = 0;
        switch(count)
        {
            case 1:
                    res = 100;
                    break;
            case 2:
                    res = 300;
                    break;
            default:
                    res = count * 200;
                    break;
        }
        scorePlayer += res;
    }

    // Получение данных по игроку
    private function initUserData():void
    {
        // Запрашиваем данные с сервера
        Server.getUserData( userDataComplete, username );
    }

    //Получение данных по текущему уровню
    public function initLevelData():void
    {
        // Запрашиваем данные с сервера
        Server.getLevelData( levelDataComplete, levelPlayer )
    }

    // Загрузка данных игрока
    public function userDataComplete(e:Event):void
    {
        var variables:Object =  com.adobe.serialization.json.JSON.decode( e.target.data );
        username = variables.username;
        recordScore = variables.point;
        levelPlayer = variables.level;
        _main.reloadData();
    }

    // Загрузка данных уровня
    public function levelDataComplete(e:Event):void
    {
        var variables:Object =  com.adobe.serialization.json.JSON.decode( e.target.data );
        scoreLevelPlayer =  variables.point;
        _scorePlayer = 0;
        _timeLevelPlayer = variables.time;
        _currentTimePlayer = _timeLevelPlayer;
        _main.reloadData();
    }
}
}
