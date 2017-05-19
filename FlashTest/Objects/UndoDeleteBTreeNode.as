package Objects
{
	public class UndoDeleteBTreeNode extends UndoBlock
	{

		public var objectID:int;
		public var posX:Number;
		public var posY:Number;
		
		public var labels:Array;
		public var labelColors:Array;
		
		public var widthPerElem:Number;
		public var nodeHeight:Number;
		public var numElems:int;
		
		public var backgroundColor:uint;
		public var foregroundColor:uint;
		
		public var layer:int;
		
		
		function UndoDeleteBTreeNode(id:int, numLab:int, labelText:Array, x:Number, y:Number, wPerElement:Number, nHeight:Number, lColors:Array, bgColor, fgColor, l):void
		{
			objectID = id;
			posX = x;
			posY = y;
			widthPerElem = wPerElement;
			nodeHeight = nHeight;
			backgroundColor= bgColor;
			foregroundColor = fgColor;
			numElems = numLab;
			labels = labelText;
			
			labelColors = lColors;
			layer = l;
		}
		
		
		override public function undoInitialStep(world):void
		{

			world.addBTreeNode(objectID, widthPerElem, nodeHeight, numElems, backgroundColor, foregroundColor);
			world.setNodePosition(objectID, posX, posY);
			for (var i:int = 0; i < numElems; i++)
			{
				world.setText(objectID, labels[i], i);
				world.setTextColor(objectID, labelColors[i],i);
			}
			world.setLayer(objectID, layer);
		}
	}
}