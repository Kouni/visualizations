package Objects
{
	public class UndoDeleteCircle extends UndoBlock
	{

		public var objectID:int;
		public var posX:int;
		public var posY:int
		public var nodeLabel:String;
		public var type:int;
		public var labCentered:Boolean;
		public var fgColor:uint;
		public var bgColor:uint;
		public var layer:int;
		
		function UndoDeleteCircle(id, lab, x, y, foregroundColor:uint, backgroundColor:uint, l:int):void
		{
			objectID = id;
			posX = x;
			posY = y;
			nodeLabel = lab;
			fgColor = foregroundColor;
			bgColor = backgroundColor;
			layer = l;
		}
		
		override public function undoInitialStep(world):void
		{
			world.addCircleObject(objectID,nodeLabel);
			world.setNodePosition(objectID, posX, posY);
			world.setForegroundColor(objectID, fgColor);
			world.setBackgroundColor(objectID, bgColor);
			world.setLayer(objectID, layer);
		}
	}
}