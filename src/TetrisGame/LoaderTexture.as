package TetrisGame {
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;

public class LoaderTexture {

    [Embed(source="cell.png")]
    private static var CellClass:Class;
    [Embed(source="background.jpg")]
    private static var BackgroundClass:Class;

    public static var cellData:BitmapData;
    public static var backgroundData:BitmapData;

    public static function getCell():DisplayObject
    {
        if (cellData == null) {
            var bitmap:Bitmap = new CellClass();
            cellData = bitmap.bitmapData;
        }
        return new Bitmap(cellData);
    }

    public static function getBackground():DisplayObject
    {
        if (backgroundData == null) {
            var bitmap:Bitmap = new BackgroundClass();
            backgroundData = bitmap.bitmapData;
        }
        return new Bitmap(backgroundData);
    }

    public function LoaderTexture() {
    }
}
}
