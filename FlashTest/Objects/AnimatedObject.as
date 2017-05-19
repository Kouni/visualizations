package Objects
{
	import flash.display.Sprite;
	import flash.text.TextField;

	public class AnimatedObject extends Sprite
	{

	
		public var backgroundColor:uint;
		public var foregroundColor:uint;
		
		var contents:TextField;
		var highlighted:Boolean;
		var nodeID:int;
		public var actualX:Number;
		public var actualY:Number;
		public var labelColor:uint;
		const HIGHLIGHT_COLOR = 0xFF0000;
		
		
		static const maxHeightDiff:Number = 5;
		static const minHeightDiff:Number = 3;
		static const range:Number = maxHeightDiff - minHeightDiff + 1;

		var highlightDiff:Number = 3;


		public var layer:int;
		public var addedToScene:Boolean;
		var dirty:Boolean = true;
		
		public function draw()
		{
			if (dirty)
			{
				forceRedraw();
				dirty = false;
			}
		}
		
		function AnimatedObject():void
		{
			addedToScene = true;
		}
		
		public function forceRedraw():void
		{
			
		}
		
		public function setBackgroundColor(newColor:uint)
		{
			backgroundColor = newColor;
			dirty = true;
		}
		
	    public function setNull(np:Boolean)
	    {
	    }
	   
	   public function getNull():Boolean
	   {
			return false;
	   }
		
		public function setWidth(w):void
		{
			
			
		}
		
		public function setHeight(h):void
		{
			
		}
		
		public function getWidth():Number
		{
			return -1;
		}
		
		public function getHeight():Number
		{
			return -1;
		}

		public function setAlpha(newAlpha)
		{
			alpha = newAlpha;
		}
		
		public function getAlpha():Number
		{
			return alpha;
		}
		
		
		public function setForegroundColor(newColor:uint)
		{
			foregroundColor = newColor;
			labelColor = newColor;
			if (contents != null)
			{
				contents.textColor = newColor;
			}
			dirty = true;
		}
		
		
		public function highlightValue():Boolean
		{
			return highlighted;
		}
		
		public function setHighlight(value):void
		{
			if (value != highlighted)
			{
				highlighted = value;
				dirty = true;
			}
		}
				
		function left(): Number
		{
			return x - getWidth() / 2;
		}
		
		function right():Number
		{
			return x + getWidth() / 2;
		}
		
		function top():Number
		{
			return y - getHeight() / 2;
		}
		
		function bottom():Number
		{
			return y + getHeight() / 2;
		}
		
		function centerX():Number
		{
			return x;
		}
		
		function centerY():Number
		{
			return y;
		}

		
		
		function getClosestCardinalPoint(fromX, fromY) : Array
		{
			var xDelta:Number;
			var yDelta:Number;
			var xPos:Number;
			var yPos:Number;
			
			if (fromX < left())
			{
				xDelta = left() - fromX;
				xPos = left();
			}
			else if (fromX > right())
			{
				xDelta = fromX - right();
				xPos = right();
		    }
			else
			{
				xDelta = 0;
				xPos = centerX();
			}
			
			if (fromY < top())
			{
				yDelta = top() - fromY;
				yPos = top();
			}
			else if (fromY > bottom())
			{
				yDelta = fromY - bottom();
				yPos = bottom();
		    }
			else
			{
				yDelta = 0;
				yPos = centerY();
			}
			
			if (yDelta > xDelta)
			{
				xPos = centerX();
			}
			else 
			{
				yPos  = centerY();
			}
				
			return [xPos, yPos];
		}
		
		
		public function centered():Boolean
		{
			return false;
		}
		public function pulseHighlight(frameNum:int):void
		{
	
		   if (highlighted)
		   {
			   var frameMod:Number = frameNum / 14.0;
			   var delta:Number  = Math.abs((frameMod) % (2 * range  - 2) - range + 1)
			   highlightDiff =  delta + minHeightDiff;
			   dirty = true;
			   dirty = true;			   
		   }
	
		}
		
		public function getTailPointerAttachPos(fromX, fromY, anchorPoint) : Array
		{
			return [x, y];
		}

		
		public function getHeadPointerAttachPos(fromX, fromY) : Array
		{
			return [x, y];
		}

		
		
		public function createUndoDelete() : UndoBlock
		{
			// Must be overriden!
			return null;
		}
		
		public function identifier():int
		{
			return nodeID;
		}
		public function getText(index:int = 0):String
		{
			if (contents != null)
			{
				return contents.text;
			}
			else
			{
				return "";
			}
		}
		
		public function getTextColor(textIndex:int = 0)
		{
			
			return labelColor
		}
		
		public function setTextColor(color, textIndex:int = 0)
		{
			labelColor = color;
			if (contents != null)
			{
				contents.textColor = labelColor;
			}
		}
		
		public function setText(newText:String, textIndex:int = 0)
		{
			if (contents != null)
			{
				contents.text = newText;
				dirty = true;
			}
		}
	}
}