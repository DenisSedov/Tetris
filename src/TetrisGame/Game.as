
package TetrisGame {

import TetrisGame.Player;

import flash.display.Sprite;
import flash.utils.Timer;
import flash.events.TimerEvent;
import flash.events.KeyboardEvent;

// Класс поле для игры и управление фигурами
public class Game extends Sprite {

    private const cellSize:uint = 15; // Размер ячейки
    private const rowCount:uint = 15; // Количество строк поля
    private const colCount:uint = 10; // Количество столбцов поля
    private const indentRightX:int = 175; // Отступ справа для фигуры

    private var cellsArray:Array; // Массив всех ячеек поля
    private var figuresArray:Array = new Array(); // Массив вариантов фигур
    private var colorsArray:Array = new Array(); // Массив цветов фигур

    private var currentFigure:Sprite; // Текущая активная фигура
    private var currentFigureNum:uint; // Номер активной фигуры
    private var currentRotationNum:uint; // Номер поворота активной фигуры
    private var currentRow:int; // Текущая строка
    private var currentCol:int; // Текущая колонка

    private var timeCount:Timer = new Timer(1000); // Таймер падения
    private var gameOver:Boolean=false; // Флаг завершения игры
    private var nextFigureNum:uint; // Номер следующей фигуры

    private var player:Player; // Обьект игрока
    private var main:Main; // Обьект родителя

    public function Game(p:Player, m:Main) {
        player = p;
        main = m;
        initFigure();
    }

    private function getMain():Main
    {
        return Main(stage);
    }

    // Создание новой игры
    public function newGame():void {
        generateMap();
        nextFigureNum=Math.floor(Math.random()*7);
        generateFigure();
        stage.addEventListener(KeyboardEvent.KEY_DOWN, onKDown);
    }

    // Пауза
    public function pause():void {
        // убираем обработчики
        stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKDown);
        timeCount.stop();
    }

    // Возобновление игры
    public function start():void {
        // Востанавливаем обработчики
        stage.addEventListener(KeyboardEvent.KEY_DOWN, onKDown);
        timeCount.start();
    }

    // Окончание игры
    public function endGame():void {

    }

    // Инициализация всех фигур
    private function initFigure():void {
        // ++++    палка
        figuresArray[0]=[[[0,0,0,0],[1,1,1,1],[0,0,0,0],[0,0,0,0]],[[0,1,0,0],[0,1,0,0],[0,1,0,0],[0,1,0,0]]];
        colorsArray[0]=0x00FFFF;
        //  +++     T
        //   +
        figuresArray[1]=[[[0,0,0,0],[1,1,1,0],[0,1,0,0],[0,0,0,0]],[[0,1,0,0],[1,1,0,0],[0,1,0,0],[0,0,0,0]],[[0,1,0,0],[1,1,1,0],[0,0,0,0],[0,0,0,0]],[[0,1,0,0],[0,1,1,0],[0,1,0,0],[0,0,0,0]]];
        colorsArray[1]=0x767676;
        //    +   обратная L
        //  +++
        figuresArray[2]=[[[0,0,0,0],[1,1,1,0],[1,0,0,0],[0,0,0,0]],[[1,1,0,0],[0,1,0,0],[0,1,0,0],[0,0,0,0]],[[0,0,1,0],[1,1,1,0],[0,0,0,0],[0,0,0,0]],[[0,1,0,0],[0,1,0,0],[0,1,1,0],[0,0,0,0]]];
        colorsArray[2]=0xFFA500;
        // +       L
        // +++
        figuresArray[3]=[[[1,0,0,0],[1,1,1,0],[0,0,0,0],[0,0,0,0]],[[0,1,1,0],[0,1,0,0],[0,1,0,0],[0,0,0,0]],[[0,0,0,0],[1,1,1,0],[0,0,1,0],[0,0,0,0]],[[0,1,0,0],[0,1,0,0],[1,1,0,0],[0,0,0,0]]];
        colorsArray[3]=0x0000FF;
        // ++      z
        //  ++
        figuresArray[4]=[[[0,0,0,0],[1,1,0,0],[0,1,1,0],[0,0,0,0]],[[0,0,1,0],[0,1,1,0],[0,1,0,0],[0,0,0,0]]];
        colorsArray[4]=0xFF0000;
        //  ++     обратная z
        // ++
        figuresArray[5]=[[[0,0,0,0],[0,1,1,0],[1,1,0,0],[0,0,0,0]],[[0,1,0,0],[0,1,1,0],[0,0,1,0],[0,0,0,0]]];
        colorsArray[5]=0x00FF00;
        // ++      квадрат
        // ++
        figuresArray[6]=[[[0,1,1,0],[0,1,1,0],[0,0,0,0],[0,0,0,0]]];
        colorsArray[6]=0xFFFF00;
    }

    // Генерация поля
    private function generateMap():void {
        cellsArray= new Array();
        var fieldSprite:Sprite = new Sprite();
        addChild(fieldSprite);
        fieldSprite.graphics.lineStyle(0,0x000000);
        for (var i:uint = 0; i<rowCount; i++) {
            cellsArray[i] = new Array();
            for (var j:uint = 0; j<colCount; j++) {
                cellsArray[i][j]=0;
                fieldSprite.graphics.beginFill(0x444444);
                fieldSprite.graphics.drawRect(cellSize*j, cellSize*i, cellSize, cellSize);
                fieldSprite.graphics.endFill();
            }
        }
    }

    // Генерация новой фигуры
    private function generateFigure():void {
        if (gameOver) return;

        currentFigureNum = nextFigureNum;
        nextFigureNum = Math.floor(Math.random()*7);
        drawNextFigure();
        currentRotationNum = 0;
        currentRow = 0;
        // Проверяем размеры фигуры и сдвигаем ее вверх
        if (figuresArray[currentFigureNum][0][0].indexOf(1) == -1) {
            currentRow = -1;
        }
        currentCol = 3;

        // Проверяем может ли фигура поместится
        if (canFit(currentRow, currentCol, currentRotationNum)) {
            timeCount.addEventListener(TimerEvent.TIMER, onTime);
            timeCount.start();
            drawCurrentFigure();
        }
        else gameOver = true; // Фигура не помещается, конец игры
    }

    // Отрисовка фигур
    // figureSptite спрайт в котором отрисовка
    // cf номер фигуры
    // cr номер поворота фигуры
    private function drawFigure(figureSptite: Sprite, cf:uint, cr:uint = 0):Sprite {
        figureSptite.graphics.lineStyle(0,0x000000);
        for (var i:int=0; i<figuresArray[cf][cr].length; i++) {
            for (var j:int=0; j<figuresArray[cf][cr][i].length; j++) {
                if (figuresArray[cf][cr][i][j] == 1) {
                    figureSptite.graphics.beginFill(colorsArray[cf]);
                    figureSptite.graphics.drawRect(cellSize*j, cellSize*i, cellSize, cellSize);
                    figureSptite.graphics.endFill();
                }
            }
        }
        return figureSptite;
    }

    // Отрисовка фигуры
    private function drawCurrentFigure():void {
        var cf:uint = currentFigureNum;
        currentFigure = new Sprite();
        drawFigure(currentFigure, currentFigureNum, currentRotationNum);
        addChild(currentFigure);
        placeFigure();
    }

    private function onTime(e:TimerEvent):void {
        if (canFit(currentRow+1, currentCol, currentRotationNum)) {
            currentRow++;
            placeFigure();
        }
        else {
            settingFigure();
            generateFigure();
        }
    }

    // Определение координат фигуры
    private function placeFigure():void {
        currentFigure.x = currentCol*cellSize;
        currentFigure.y = currentRow*cellSize;
    }


    private function onKDown(e:KeyboardEvent):void {
        if (gameOver) return;

        switch (e.keyCode) {
            case 37:
                if (canFit(currentRow,currentCol-1,currentRotationNum)) {
                    currentCol--;
                    placeFigure();
                }
                break;
            case 38:
                var ct:uint=currentRotationNum;
                var rot:uint=(ct+1)%figuresArray[currentFigureNum].length;
                if (canFit(currentRow, currentCol, rot)) {
                    currentRotationNum = rot;
                    removeChild(currentFigure);
                    drawCurrentFigure();
                    placeFigure();
                }
                break;
            case 39:
                if (canFit(currentRow, currentCol+1, currentRotationNum)) {
                    currentCol++;
                    placeFigure();
                }
                break;
            case 40:
                if (canFit(currentRow+1, currentCol, currentRotationNum)) {
                    currentRow++;
                    placeFigure();
                }
                else {
                    settingFigure();
                    generateFigure();
                }
                break;
        }
    }

    // Проверка на то что фигура помещается
    private function canFit(row:int, col:int, side:uint):Boolean {
        var cf:uint=currentFigureNum;
        for (var i:uint = 0; i < figuresArray[cf][side].length; i++) {
            for (var j:uint = 0; j < figuresArray[cf][side][i].length; j++) {
                if (figuresArray[cf][side][i][j]==1) {
                    // Выход за левые границы
                    if (col + j < 0) {
                        return false;
                    }
                    // Выход за правые границы
                    if (col + j > colCount - 1) {
                        return false;
                    }
                    // Выход за границы снизу
                    if (row + i > rowCount - 1) {
                        return false;
                    }
                    // Выход за границы сверху
                    if (row + i < 0) {
                        return false;
                    }
                    // Проверка что фигуры забили все поле
                    if (cellsArray[row+i][col+j] == 1) {
                        return false;
                    }
                }
            }
        }
        return true;
    }

    // Создание участков фигуры (отдельных ячеек), после того как фигура легла
    private function settingFigure():void {
        var cf:uint = currentFigureNum;
        var cell:Sprite;
        for (var i:int = 0; i < figuresArray[cf][currentRotationNum].length; i++) {
            for (var j:int = 0; j < figuresArray[cf][currentRotationNum][i].length; j++) {
                if (figuresArray[cf][currentRotationNum][i][j] == 1) {
                    cell = new Sprite();
                    cell.graphics.lineStyle(0,0x000000);
                    cell.graphics.beginFill(colorsArray[currentFigureNum]);
                    cell.graphics.drawRect(cellSize*(currentCol+j),cellSize*(currentRow+i),cellSize,cellSize);
                    cell.graphics.endFill();
                    cell.name="r"+(currentRow+i)+"c"+(currentCol+j);
                    addChild(cell);
                    cellsArray[currentRow+i][currentCol+j] = 1;
                }
            }
        }
        removeChild(currentFigure);
        timeCount.removeEventListener(TimerEvent.TIMER, onTime);
        timeCount.stop();
        delForLines();
    }

    // Удаление строки и сдвиг ячеек
    private function delForLines():void {
        var delCountLine:uint = 0;
        for (var i:int = 0; i < rowCount; i++) {
            if (cellsArray[i].indexOf(0) == -1) {
                for (var j:int = 0; j < colCount; j++) {
                    cellsArray[i][j] = 0;
                    removeChild(getChildByName("r"+i+"c"+j));
                }
                for (j = i; j >= 0; j--) {
                    for (var k:uint = 0; k < colCount; k++) {
                        if (cellsArray[j][k] == 1) {
                            cellsArray[j][k] = 0;
                            cellsArray[j+1][k] = 1;
                            getChildByName("r"+j+"c"+k).y += cellSize;
                            getChildByName("r"+j+"c"+k).name = "r"+(j+1)+"c"+k;
                        }
                    }
                }
                delCountLine++;
            }
        }

        // Если удалялись строки
        if (delCountLine > 0) {
            player.scorePlayer += player.getAddScore(delCountLine);
            main.reloadData();
        }
    }

    // Отрисовка следующей фигуры
    private function drawNextFigure():void {
        // Убираем предыдущую фигуру
        if (getChildByName("next")!=null) {
            removeChild(getChildByName("next"));
        }
        var nf:Sprite = new Sprite();
        drawFigure(nf, nextFigureNum);
        nf.x = indentRightX;
        nf.name = "next";
        addChild(nf);
    }

}
}
