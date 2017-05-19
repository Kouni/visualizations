package Objects
{
	public class UndoDeleteLinkedList extends UndoBlock
	{

		public var objectID:int;
		public var posX:Number;
		public var posY:Number;
		public var width:Number;
		public var height:Number;
		public var labels:Array;
		public var labelColors:Array;
		public var linkPercent:Number;
		public var verticalOrentation:Boolean;
		public var linkAtEnd:Boolean;
		
		public var numLabels:int;
		public var backgroundColor:uint;
		public var foregroundColor:uint;
		
		public var nullPointer:Boolean;
		
		public var layer:int;
						
		function UndoDeleteLinkedList(id:int, numlab:int, lab:Array, x:Number, y:Number, w:Number, h:Number, linkper:Number, posEnd:Boolean, vert:Boolean, labColors:Array, bgColor, fgColor, l:int, np:Boolean):void
		{
			objectID = id;
			posX = x;
			posY = y;
			width = w;
			height = h;
			backgroundColor= bgColor;
			foregroundColor = fgColor;
			labels = lab;
			linkPercent = linkper;
			verticalOrentation = vert;
			linkAtEnd = posEnd;
			labelColors = labColors
			layer = l;
			numLabels = numlab;
			nullPointer = np;
		}
		
		
		override public function undoInitialStep(world):void
		{
			world.addLinkedListObject(objectID,labels[0], width, height, linkPercent, verticalOrentation, linkAtEnd, numLabels, backgroundColor, foregroundColor);
			world.setNodePosition(objectID, posX, posY);
			world.setLayer(objectID, layer);
			world.setNull(objectID, nullPointer);
			for (var i = 0; i < numLabels; i++)
			{
				world.setText(objectID, labels[i], i);
				world.setTextColor(objectID, labelColors[i], i);
			}
		}
	}
}