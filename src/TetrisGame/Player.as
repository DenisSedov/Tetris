package TetrisGame {

// Класс игрока, содержит все данные относящиеся к игроку
public class Player {

    public var scorePlayer:uint = 0; // Текущее количество очков
    public var levelPlayer:uint = 1; // Уровень игрока
    private var currentTimePlayer:uint = 0; // Оставлшееся время игрока

    // Для достижения очередного уровня
    private var timeLevelPlayer:uint = 0; // Время на очередном уровне
    private var scoreLevelPlayer:uint = 0; // Количество очков для достижения уровня


    public function Player() {

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

    // Получение параметров задачи, относительно уровня игрока
    private function getQuest(level:uint):void {
        scoreLevelPlayer = 500; //4900 + (level*100);
        timeLevelPlayer = 300;  //300 - (level*5); // 5 минут
    }

    private function nextLevel():void {
        // Отсылает на сервер данные

    }

}
}
