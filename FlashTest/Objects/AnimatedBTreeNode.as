package Objects
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.display.BlendMode;

	public class AnimatedBTreeNode extends AnimatedObject
	{

	
	// From parent:
    //		public var backgroundColor:uint;
	//	public var foregroundColor:uint;
		
	//	var highlighted:Boolean;
	//	var nodeID:int;

	//	const HIGHLIGHT_COLOR = 0xFF0000;

	//	public var layer:int;
	//	public var addedToScene:Boolean;
		
		static const MIN_WIDTH = 10;
		
		var widthPerElement:Number;
		var nodeHeight:Number;
		var numLabels:int;
		
		var labels:Array;
		var labelColors:Array;
		var rectangle:Sprite;
		
		function AnimatedBTreeNode(id, widthPerElem, h, numElems,  fillColor = 0xFFFFFF, edgeColor = 0x000000):void
		{
			nodeID = id;
			rectangle = new Sprite();
			addChild(rectangle);
			
			backgroundColor = fillColor;
			foregroundColor = edgeColor;

			widthPerElement = widthPerElem;
			nodeHeight = h;
			numLabels = numElems;
			labels = new Array(numLabels);
			labelColors = new Array(numLabels);
			for (var i:int = 0; i < numLabels; i++)
			{
				labels[i] = new TextField();
				labels[i].blendMode = BlendMode.LAYER;
				labels[i].textColor = foregroundColor;
				labels[i] .mouseEnabled = false;
				labelColors[i] = foregroundColor;
				addChild(labels[i]);
			}
			dirty = true;
		}
		
		public function getNumElements():int
		{
			return numLabels;
		}
		
		override public function getWidth():Number
		{
			if (numLabels > 0)
			{
				return  (widthPerElement * numLabels);
			}
			else
			{
				return MIN_WIDTH;
			}
		}
		
		
		public function setNumElements(newNumElements:int)
		{
			if (numLabels < newNumElements)
			{
				for (var i:int = numLabels; i < newNumElements; i++)
				{
					labels[i] = new TextField();
					labels[i].blendMode = BlendMode.LAYER;
					labels[i].textColor = foregroundColor;
					labels[i] .mouseEnabled = false;
					labelColors[i] = foregroundColor;
					addChild(labels[i]);
				}
				numLabels = newNumElements;
				resetTextPosition();
				dirty = true;
			}
			else if (numLabels > newNumElements)
			{
				for (i = newNumElements; i < numLabels; i++)
				{
					removeChild(labels[i]);
					labels[i] = null;
				}
				numLabels = newNumElements;
				resetTextPosition();
				dirty = true;
			}
		}
		
				
	   override function left():Number
	   {
			return x  - getWidth() / 2;
	   }
	   
	   override function right():Number
	   {
			return x  + getWidth() / 2;
	   } 
	   
   	   override function top():Number
	   {
		   return y - nodeHeight / 2;
	   }
	   
	   override function bottom():Number
	   {
		   return y + nodeHeight / 2;
	   }
	   
	   	private function resetTextPosition() : void
	   {
		   for (var i:int = 0; i < numLabels; i++)
		   {
			   labels[i].x = - widthPerElement * numLabels / 2 + widthPerElement / 2 + i * widthPerElement - labels[i].textWidth / 2; // -1 ?
			   labels[i].y = -labels[i].textHeight / 2; // -1?			   
		   }
	   }
				
		
		override public function forceRedraw():void
		{
			var startX:Number;
		   	var startY:Number;
		   
		 	startX = left() - x;
		   	startY = top() - y;
			   
		 	rectangle.graphics.clear();
			if (highlighted)
			{
				rectangle.graphics.lineStyle(1,HIGHLIGHT_COLOR,1.0);
				rectangle.graphics.beginFill(HIGHLIGHT_COLOR);
				rectangle.graphics.moveTo(startX - highlightDiff,startY- highlightDiff);
				rectangle.graphics.lineTo(startX+ getWidth() + highlightDiff,startY- highlightDiff);
				rectangle.graphics.lineTo(startX+getWidth()+ highlightDiff,startY+nodeHeight + highlightDiff);
				rectangle.graphics.lineTo(startX - highlightDiff,startY+nodeHeight + highlightDiff);
				rectangle.graphics.lineTo(startX - highlightDiff,startY - highlightDiff);				
				rectangle.graphics.endFill();
		    }
			rectangle.graphics.lineStyle(1,foregroundColor,1.0);
			rectangle.graphics.beginFill(backgroundColor);
			rectangle.graphics.moveTo(startX ,startY);
			rectangle.graphics.lineTo(startX + getWidth(), startY);
			rectangle.graphics.lineTo(startX + getWidth(), startY + nodeHeight);
			rectangle.graphics.lineTo(startX, startY + nodeHeight);
			rectangle.graphics.lineTo(startX, startY);				
			rectangle.graphics.endFill();
			
		}
		
		
		
		override public function getHeight():Number
		{
			return nodeHeight;
		}

		
		
		override public function setForegroundColor(newColor:uint)
		{
			foregroundColor = newColor;
			for (var i = 0; i < numLabels; i++)
			{
				labelColor[i] = foregroundColor;
				labels[i].textColor = foregroundColor;
			}
			dirty = true;
		}
		

		
		override public function getTailPointerAttachPos(fromX, fromY, anchor) : Array
		{
			if (anchor == 0)
			{
				return [left() + 5, y];
			}
			else if (anchor == numLabels)
			{
				return [right() - 5, y];	
			}
			else
			{
				return [left() + anchor * widthPerElement, y]
			}
		}

		
		override public function getHeadPointerAttachPos(fromX, fromY) : Array
		{
			if (fromY < y - nodeHeight / 2)
			{
				return [x, y - nodeHeight / 2];
			}
			else if (fromY > y + nodeHeight /  2)
			{
				return [x, y + nodeHeight / 2];			
			}
			else if (fromX  < x  - getWidth() / 2)
			{
				return [x - getWidth() / 2, y];
			}
			else
			{
				return [x + getWidth() / 2, y];
			}
		}

		
		
	   	override public function createUndoDelete() : UndoBlock
		{
			var labelText:Array = new Array(numLabels);
			for (var i:int = 0; i < numLabels; i++)
			{
				labelText[i] = labels[i].text;
			}
			
			
			return new UndoDeleteBTreeNode(nodeID, numLabels, labelText, x, y, widthPerElement, nodeHeight, labelColors, backgroundColor, foregroundColor, layer);
		}
				

		override public function getTextColor(textIndex:int = 0)
		{
			return labelColors[textIndex];
		}
		
		override public function getText(index:int = 0):String
		{
			return labels[index].text;
		}
		
		override public function setTextColor(color, textIndex:int = 0)
		{
			labelColors[textIndex] = color;
			if (labels[textIndex] != null)
			{
				labels[textIndex].textColor = color;
			}
		}
		
		override public function setText(newText:String, textIndex:int = 0)
		{
			labels[textIndex].text = newText;
			resetTextPosition();
		}
	}
}