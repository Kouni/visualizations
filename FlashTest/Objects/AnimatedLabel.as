package Objects
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.display.BlendMode;
	
	
	public class AnimatedLabel extends Objects.AnimatedObject
	{
		var format:TextFormat;
		var centering:Boolean;

		function AnimatedLabel(id, val, center = true):void
		{
			centering = center;
			contents = new TextField();
			contents.blendMode = BlendMode.LAYER;
			contents.text = val;
			contents.width = contents.textWidth * 2;

			if (centering)
			{
				contents.x = -contents.textWidth / 2 - 2;
				contents.y = -contents.textHeight / 2 ;
			}
 			contents.height = contents.textHeight * 2;

			highlighted = false;
			addChild(contents);
			nodeID = id;
			format = new TextFormat();
			contents.setTextFormat(format);
			contents.mouseEnabled = false;
			contents.height = contents.textHeight * 2;
			if (centering)
			{
				contents.width = contents.textWidth * 2;
			}
			else
			{
				contents.width = contents.textWidth + 5;
			}

		}
		
		public override function centered():Boolean
		{
			return centering;
		}
		
		override public function setHighlight(value):void
		{
			if (value != highlighted)
			{
				highlighted = value;
				if (highlighted)
				{
					format.color = 0xFF0000;
					format.bold = true;
				}
				else
				{
					format.color = 0x000000;
					format.bold = false;
				}
				contents.setTextFormat(format);
			}
		}
		
		override public function createUndoDelete() : UndoBlock
		{
			return new UndoDeleteLabel(nodeID, contents.text, x, y, centering, labelColor, layer);
		}
		
		
		
		override function centerX():Number
	   {
			if (centering)
			{
				return x;
			}
			else 
			{
				return x  + contents.textWidth / 2		
			}
	   }
	   
	   override function centerY():Number
	   {
		   	if (centering)
			{
				return y;
			}
			else 
			{
				return y + contents.textHeight / 2;
			}
		   
	   }
	   
   	   override function top():Number
	   {
		   if (centering)
		   {
				return  y - contents.textHeight / 2;
		   }
		   else 
		   {
				return y;   
		   }
	   }
	   
	    override function bottom():Number
	   {
		   if (centering)
		   {
				return  y + contents.textHeight / 2;
		   }
		   else 
		   {
				return  y + contents.textHeight;
		   }
	   }
	   
	   
	   override function right():Number
	   {
		   if (centering)
		   {
				return  x + contents.textWidth / 2 + 4;
		   }
		   else
		   {
				return  x + contents.textWidth + 4;
		   }
	   }
	   
	   
	   override function left():Number
	   {
		   if (centering)
		   {
				return  x - contents.textWidth / 2 - 4;
		   }
		   else
		   {
				return  x - 4;
		   }
	   }
		
		 override public function getTailPointerAttachPos(fromX, fromY, anchorPoint): Array
		 {			 
			return getClosestCardinalPoint(fromX, fromY); 
		 }
		
		override public function getHeadPointerAttachPos(fromX, fromY) : Array
		{
			return getClosestCardinalPoint(fromX, fromY);			
		}
	   		
		
	   override public function setText(newText:String, textIndex:int = 0)
	   {
		   if (contents != null)
		   {
			   contents.text = newText; 
			   contents.height = contents.textHeight * 2;
			   if (centering)
			   {
				   	contents.width = contents.textWidth * 2;
					contents.x = -contents.textWidth / 2 - 2;
					contents.y = -contents.textHeight / 2 - 2;
			   }
			   else
			   {
				  	contents.width = contents.textWidth  + 5;
			   }
		   }
		 
	   }
	}
}