package TetrisGame
{

import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.utils.Timer;
import flash.events.TimerEvent;
import flash.events.KeyboardEvent;

// Класс поле для игры и управление фигурами
public class Game extends Sprite 
{
    private const CELL_SIZE:uint = 15; // Размер ячейки    
    private const ROW_COUNT:uint = 20; // Количество строк поля
    private const COL_COUNT:uint = 10; // Количество столбцов поля
    private const COUNT_FIGURE:uint = 7; // Количество фигур

    private var _cellsArray:Array; // Массив всех ячеек поля
    private var _figuresArray:Array = new Array(); // Массив вариантов фигур
    private var _timeDown:Timer = new Timer( 700 ); // Таймер падения
    private var _gameOver:Boolean=false; // Флаг завершения игры
    private var _nextFigureNum:uint; // Номер следующей фигуры
    private var _visibleNext:Boolean = true; // Флаг видимости следующей фигуры

    private var _currentFigure:Sprite; // Текущая активная фигура
    private var _currentFigureNum:uint; // Номер активной фигуры
    private var _currentRotationNum:uint; // Номер поворота активной фигуры
    private var _currentRow:int; // Текущая строка
    private var _currentCol:int; // Текущая колонка

    private static var _assetManager:AssetManager = AssetManager.instance;

    private var _player:Player; // Обьект игрока
    private var _main:Main; // Обьект родителя

    public function Game(player:Player, main:Main)
    {
        _player = player;
        _main = main;
        initFigure();
    }

    // Очистка экрана от мусора
    private function removeCells():void
    {
        for( var i:int = 0; i < ROW_COUNT; i++ )
        {
            for( var j:int = 0; j < COL_COUNT; j++ )
            {
                var cell:DisplayObject = getChildByName( "r" + i + "c" + j );
                if( cell )
                {
                    removeChild( cell );
                }
            }
        }
    }

    // Создание новой игры
    public function newGame():void
    {
        removeCells();
        generateMap();
        _nextFigureNum = Math.floor( Math.random() * COUNT_FIGURE );
        generateFigure();
        stage.addEventListener( KeyboardEvent.KEY_DOWN, onKDown );
        _player.reloadData();
        _main.reloadData();
        _main.drawTime();
    }

    // Пауза игры
    public function pause():void
    {
        // убираем обработчики
        stage.removeEventListener( KeyboardEvent.KEY_DOWN, onKDown );
        _timeDown.stop();
        _main.currentTimer.stop();
    }

    // Возобновление игры
    public function start():void
    {
        // Востанавливаем обработчики
        stage.addEventListener( KeyboardEvent.KEY_DOWN, onKDown );
        _timeDown.start();
        _main.currentTimer.start();
    }

    // Устанавливает видимость следующей фигуры
    public function visibleNextFigure(visible: Boolean):void
    {
        _visibleNext = visible;
        drawNextFigure();
    }

    // Окончание игры
    public function endGame():void
    {
        pause();
    }

    // Инициализация всех фигур
    private function initFigure():void
    {
        // ++++    палка
        _figuresArray[ 0 ] = [[[0, 0, 0 ,0], [1, 1, 1, 1], [0, 0, 0, 0], [0, 0, 0, 0]],
                              [[0, 1, 0, 0], [0, 1, 0, 0], [0, 1, 0, 0], [0, 1, 0, 0]]];
        //  +++     T
        //   +
        _figuresArray[ 1 ] = [[[0, 0, 0, 0], [1, 1, 1, 0], [0, 1, 0, 0], [0, 0, 0, 0]],
                              [[0, 1, 0, 0], [1, 1, 0, 0], [0, 1, 0, 0], [0, 0, 0, 0]],
                              [[0, 1, 0, 0], [1, 1, 1, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
                              [[0, 1, 0, 0], [0, 1, 1, 0], [0, 1, 0, 0], [0, 0, 0, 0]]];
        //    +   обратная L
        //  +++
        _figuresArray[ 2 ] = [[[0, 0, 0, 0], [1, 1, 1, 0], [1, 0, 0, 0], [0, 0, 0, 0]],
                              [[1, 1, 0, 0], [0, 1, 0, 0], [0, 1, 0, 0], [0, 0, 0, 0]],
                              [[0, 0, 1, 0], [1, 1, 1, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
                              [[0, 1, 0, 0], [0, 1, 0, 0], [0, 1, 1, 0], [0, 0, 0, 0]]];
        // +       L
        // +++
        _figuresArray[ 3 ] = [[[1, 0, 0, 0], [1, 1, 1, 0], [0, 0, 0, 0], [0, 0, 0, 0]],
                              [[0, 1, 1, 0], [0, 1, 0, 0], [0, 1, 0, 0], [0, 0, 0, 0]],
                              [[0, 0, 0, 0], [1, 1, 1, 0], [0, 0, 1, 0], [0, 0, 0, 0]],
                              [[0, 1, 0, 0], [0, 1, 0, 0], [1, 1, 0, 0], [0, 0, 0, 0]]];
        // ++      z
        //  ++
        _figuresArray[ 4 ] = [[[0, 0, 0, 0], [1, 1, 0, 0], [0, 1, 1, 0], [0, 0, 0, 0]],
                              [[0, 0, 1, 0], [0, 1, 1, 0], [0, 1, 0, 0], [0, 0, 0, 0]]];
        //  ++     обратная z
        // ++
        _figuresArray[ 5 ] = [[[0, 0, 0, 0], [0, 1, 1, 0], [1, 1, 0, 0], [0, 0, 0, 0]],
                              [[0, 1, 0, 0], [0, 1, 1, 0], [0, 0, 1, 0], [0, 0, 0, 0]]];
        // ++      квадрат
        // ++
        _figuresArray[ 6 ] = [[[0, 1, 1, 0], [0, 1, 1, 0], [0, 0, 0, 0], [0, 0, 0, 0]]];
    }

    // Генерация поля
    private function generateMap():void
    {
        _cellsArray = new Array();
        for( var i:uint = 0; i < ROW_COUNT; i++ )
        {
            _cellsArray[ i ] = new Array();
            for( var j:uint = 0; j < COL_COUNT; j++ )
            {
                _cellsArray[ i ][ j ] = 0;
            }
        }
        var assetMap:MovieClip = _assetManager.getAsset( "swf/Map.swf", onCompleteAsset, "Map" ) as MovieClip
        if( assetMap != null )
        {
            addChildAt( assetMap, 0 );
        }
    }

    // object.fileName
    // object.target
    private function onCompleteAsset(object:Object):void
    {
        switch( object.fileName )
        {
            case "swf/Map.swf":
                    addChildAt( object.target, 0 );
                    break;
        }
    }

    // Генерация новой фигуры
    private function generateFigure():void
    {
        if( _gameOver )
        {
            return;
        }
        _currentFigureNum = _nextFigureNum;
        _nextFigureNum = Math.floor( Math.random() * COUNT_FIGURE );
        drawNextFigure();
        _currentRotationNum = 0;
        _currentRow = 0;
        // Проверяем размеры фигуры и сдвигаем ее вверх
        if ( _figuresArray[ _currentFigureNum ][ 0 ][ 0 ].indexOf( 1 ) == -1 )
        {
            _currentRow = -1;
        }
        _currentCol = 3;
        // Проверяем может ли фигура поместится
        if( canFit( _currentRow, _currentCol, _currentRotationNum ) )
        {
            _timeDown.addEventListener( TimerEvent.TIMER, onTimeDown );
            _timeDown.start();
            drawCurrentFigure();
        }
        else
        {
            _gameOver = true; // Фигура не помещается, конец игры
        }
    }

    private function drawCell(cell:Sprite, x:Number, y:Number, color:int):Sprite
    {
        var square:Sprite = new Square( color );
        cell.addChild( square );
        square.x = x;
        square.y = y;
        return cell;
    }

    // Отрисовка фигур
    private function drawFigure(figureSprite: Sprite, numberFigure:uint, numberRotation:uint = 0):Sprite
    {
        for( var i:int = 0; i < _figuresArray[ numberFigure ][ numberRotation ].length; i++ )
        {
            for( var j:int = 0; j < _figuresArray[ numberFigure ][ numberRotation ][i].length; j++ )
            {
                if( _figuresArray[ numberFigure ][ numberRotation ][ i ][ j ] == 1 )
                {
                    drawCell( figureSprite, CELL_SIZE * j, CELL_SIZE * i, numberFigure );
                }
            }
        }
        return figureSprite;
    }

    // Отрисовка фигуры
    private function drawCurrentFigure():void
    {
        _currentFigure = new Sprite();
        _currentFigure.name = "currentFigure";
        // Убираем предыдущую фигуру
        var currentFigure:Sprite = getChildByName( "currentFigure" ) as Sprite;
        if( currentFigure )
        {
            removeChild( currentFigure );
        }
        drawFigure( _currentFigure, _currentFigureNum, _currentRotationNum );
        addChild( _currentFigure );
        placeFigure();
    }

    private function onTimeDown(e:TimerEvent):void
    {
        if( canFit( _currentRow + 1, _currentCol, _currentRotationNum ) )
        {
            _currentRow++;
            placeFigure();
        }
        else
        {
            settingFigure();
            generateFigure();
        }
    }

    // Определение координат фигуры
    private function placeFigure():void
    {
        _currentFigure.x = _currentCol * CELL_SIZE;
        _currentFigure.y = _currentRow * CELL_SIZE;
    }


    private function onKDown(e:KeyboardEvent):void
    {
        if( _gameOver )
        {
            return;
        }
        switch( e.keyCode )
        {
            case 37:
                    if( canFit( _currentRow, _currentCol - 1, _currentRotationNum ) )
                    {
                        _currentCol--;
                        placeFigure();
                    }
                    break;
            case 38:
                    var rotation:uint = ( _currentRotationNum + 1 ) % _figuresArray[ _currentFigureNum ].length;
                    if( canFit( _currentRow, _currentCol, rotation ) )
                    {
                        _currentRotationNum = rotation;
                        removeChild( _currentFigure );
                        drawCurrentFigure();
                        placeFigure();
                    }
                    break;
            case 39:
                    if( canFit( _currentRow, _currentCol + 1, _currentRotationNum ) )
                    {
                        _currentCol++;
                        placeFigure();
                    }
                    break;
            case 40:
                    if( canFit( _currentRow + 1, _currentCol, _currentRotationNum ) )
                    {
                        _currentRow++;
                        placeFigure();
                    }
                    else
                    {
                        settingFigure();
                        generateFigure();
                    }
                    break;
        }
    }

    // Проверка на то что фигура помещается
    private function canFit(row:int, column:int, rotation:uint):Boolean
    {
        for( var i:uint = 0; i < _figuresArray[ _currentFigureNum ][ rotation ].length; i++ )
        {
            for( var j:uint = 0; j < _figuresArray[ _currentFigureNum ][ rotation ][ i ].length; j++ )
            {
                if( _figuresArray[ _currentFigureNum ][ rotation ][ i ][ j ] == 1 )
                {
                    // Выход за левые границы
                    if( column + j < 0 )
                    {
                        return false;
                    }
                    // Выход за правые границы
                    if( column + j > COL_COUNT - 1 )
                    {
                        return false;
                    }
                    // Выход за границы снизу
                    if( row + i > ROW_COUNT - 1 )
                    {
                        return false;
                    }
                    // Выход за границы сверху
                    if( row + i < 0)
                    {
                        return false;
                    }
                    // Проверка что фигуры забили все поле
                    if( _cellsArray[ row + i ][ column + j ] == 1)
                    {
                        return false;
                    }
                }
            }
        }
        return true;
    }

    // Создание участков фигуры (отдельных ячеек), после того как фигура легла
    private function settingFigure():void
    {
        var cell:Sprite;
        for( var i:int = 0; i < _figuresArray[ _currentFigureNum ][ _currentRotationNum ].length; i++ )
        {
            for( var j:int = 0; j < _figuresArray[ _currentFigureNum ][ _currentRotationNum ][ i ].length; j++ )
            {
                if( _figuresArray[ _currentFigureNum ][ _currentRotationNum ][ i ][ j ] != 1 )
                {
                    continue;
                }
                cell = new Sprite();
                drawCell( cell, CELL_SIZE *( _currentCol + j ), CELL_SIZE * ( _currentRow + i), _currentFigureNum );
                cell.name = "r" + ( _currentRow + i ) + "c" + ( _currentCol + j );
                addChild( cell );
                _cellsArray[ _currentRow + i ][ _currentCol + j ] = 1;
            }
        }
        removeChild( _currentFigure );
        _timeDown.removeEventListener( TimerEvent.TIMER, onTimeDown );
        _timeDown.stop();
        delForLines();
    }

    // Удаление строки и сдвиг ячеек
    private function delForLines():void
    {
        var delCountLine:uint = 0;
        for( var i:int = 0; i < ROW_COUNT; i++ )
        {
            if( _cellsArray[ i ].indexOf( 0 ) != -1 )
            {
                continue;
            }
            for( var j:int = 0; j < COL_COUNT; j++ )
            {
                _cellsArray[ i ][ j ] = 0;
                removeChild( getChildByName( "r" + i + "c" + j ) );
            }
            for( j = i; j >= 0; j-- )
            {
                for( var k:uint = 0; k < COL_COUNT; k++ )
                {
                    if( _cellsArray[ j ][ k ] != 1 )
                    {
                        continue;
                    }
                    _cellsArray[ j ][ k ] = 0;
                    _cellsArray[ j + 1 ][ k ] = 1;
                    getChildByName( "r" + j + "c" + k  ).y += CELL_SIZE;
                    getChildByName( "r" + j + "c" + k).name = "r" + ( j + 1 ) + "c" + k;
                }
            }
            delCountLine++;
        }
        // Если удалялись строки
        if(delCountLine > 0)
        {
            _player.setScore( delCountLine );
            _main.reloadData();
        }
    }

    // Отрисовка следующей фигуры
    private function drawNextFigure():void
    {
        // Убираем предыдущую фигуру
        if( getChildByName( "next" )  )
        {
            removeChild( getChildByName( "next" ) );
        }
        if( _visibleNext )
        {
            var nextFigure:Sprite = new Sprite();
            addChild( nextFigure );
            drawFigure( nextFigure, _nextFigureNum );
            nextFigure.x = 190;
            nextFigure.y = 10;
            nextFigure.name = "next";
        }
    }
}
}
