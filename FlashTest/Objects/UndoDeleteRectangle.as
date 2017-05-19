package Objects
{
	public class UndoDeleteRectangle extends UndoBlock
	{

		public var objectID:int;
		public var posX:int;
		public var posY:int;
		public var width:int;
		public var height:int;
		public var nodeLabel:String;
		public var xJustify:String;
		public var yJustify:String;
		public var layer:int;
		
		
		public var backgroundColor:uint;
		public var foregroundColor:uint;
		
		
		function UndoDeleteRectangle(id, lab, x, y, w, h, xJust, yJust, bgColor, fgColor, lay):void
		{
			objectID = id;
			posX = x;
			posY = y;
			width = w;
			height = h;
			xJustify = xJust;
			yJustify = yJust;
			backgroundColor= bgColor;
			foregroundColor = fgColor;
			nodeLabel = lab;
			layer = lay;
		}
		
		
		override public function undoInitialStep(world):void
		{
			world.addRectangleObject(objectID,nodeLabel, width, height, xJustify, yJustify, backgroundColor, foregroundColor);
			world.setNodePosition(objectID, posX, posY);
			world.setLayer(objectID, layer);
		}
	}
}