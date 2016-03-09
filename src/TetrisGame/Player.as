package TetrisGame {
import flash.utils.Dictionary;

// Класс игрока, содержит все данные относящиеся к игроку
public class Player {

    private var main:Main;

    private var _scorePlayer:uint = 0; // Текущее количество очков
    public var _levelPlayer:uint = 1; // Уровень игрока
    private var _currentTimePlayer:uint = 0; // Оставлшееся время игрока

    // Для достижения очередного уровня
    private var timeLevelPlayer:uint = 0; // Время на очередном уровне
    private var scoreLevelPlayer:uint = 0; // Количество очков для достижения уровня



    public function Player(m:Main) {
        main = m;
    }

    // Неудачное завершение уровня
    private function failedLevel():void {
        // Выводим сообщение об окончании игры

        // Останавливаем отсчет таймера
        main.endGame();
    }

    // Удачное завершение уровня
    private function completedLevel():void {
        // Выводим сообщение

        // Запрошиваем новый уровень


    }

    // Проверка завершения уровня
    private function validCompleted():void {
        // Проверка времени
        if (_currentTimePlayer == 0)
            failedLevel();
        // Проверка очков
        if (_scorePlayer >= scoreLevelPlayer)
            completedLevel();
    }

    public function set scorePlayer(value:uint):void {
        _scorePlayer = value;
        validCompleted();
    }

    public function get scorePlayer():uint {
        return _scorePlayer;
    }

    public function set levelPlayer(value:uint):void {
        // Отправляем данные на сервер
        Server.nextLevel();
        initLevelData();
        _levelPlayer = value;
    }

    public function get levelPlayer():uint {
        return _levelPlayer;
    }

    public function set currentTimePlayer(value:uint):void {
        _currentTimePlayer = value;
        validCompleted();
    }

    public function get currentTimePlayer():uint {
        return _currentTimePlayer;
    }

    // Подсчитывает количество очков за удаление строк
    public function setScore(count:uint):void {
        var res:uint = 0;
        switch (count) {
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

    //Получение данных по текущему уровню
    public function initLevelData():void {
        // Запрашиваем данные с сервера
        var ld:Dictionary = Server.getLevel(levelPlayer);
        scoreLevelPlayer = 500;
        _scorePlayer = 0;
        timeLevelPlayer = 10;
        _currentTimePlayer = timeLevelPlayer;
    }

    // Получение параметров задачи, относительно уровня игрока
    private function getQuest(level:uint):void {
        scoreLevelPlayer = 500; //4900 + (level*100);
        timeLevelPlayer = 300;  //300 - (level*5); // 5 минут
    }

}
}
