package Objects
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.display.BlendMode;

	public class AnimatedRectangle extends AnimatedObject
	{

		var w:Number;
		var h:Number;
		var xJustify:String;
		var yJustify:String;
		

		var nullPointer:Boolean;
		var rectangle:Sprite;
		var currentHeightDif = 6;
		
		public static const CENTER = "center";
		public static const LEFT = "left";
		public static const RIGHT = "right";
		public static const TOP = "top";
		public static const BOTTOM = "bottom";

		
		
		function AnimatedRectangle(id, val, wth, hgt,  xJust = CENTER, yJust = CENTER, fillColor = 0xFFFFFF, edgeColor = 0x000000):void
		{
			w = wth;
			h = hgt;
			xJustify = xJust;
			yJustify = yJust;
			
			rectangle = new Sprite();
			addChild(rectangle);

			contents = new TextField();
			contents.blendMode = BlendMode.LAYER;
			contents.text = val;
			contents.width = contents.textWidth * 2;
			contents.height = contents.textHeight * 1.3;
			contents.mouseEnabled = false;

			contents.textColor = foregroundColor;

			resetTextPosition();
			
			backgroundColor = fillColor;
			foregroundColor = edgeColor;
			highlighted = false;
			dirty = true;
			addChild(contents);
			nodeID = id;
			nullPointer = false;
		}
	   
	   
	   public override function setNull(np:Boolean)
	   {
		   if (nullPointer != np)
		   {		   
			   nullPointer = np;
			   dirty = true;
		   }

	   }
	   
	   public override function getNull():Boolean
	   {
			return nullPointer;   
	   }	   
	   
	   override function left():Number
	   {
		   if (xJustify == LEFT)
		   {
				return  x;
		   }
		   else if (xJustify == CENTER)
		   {
				return x - w / 2.0;   
		   }
		   else // (xJustify == RIGHT)
		   {
				return x - w;   
		   }
		   
	   }
	   
	   override function centerX():Number
	   {
			if (xJustify == CENTER)
			{
				return x;
			}
			else if (xJustify == LEFT)
			{
				return x + w / 2.0;
			}
			else // (xJustify == RIGHT)
			{
				return x - w / 2.0;
			}
	   }
	   
	   override function centerY():Number
	   {
		   	if (yJustify == CENTER)
			{
				return y;
			}
			else if (yJustify == TOP)
			{
				return y + h / 2.0;
			}
			else // (xJustify == BOTTOM)
			{
				return y - w / 2.0;
			}
		   
	   }
	   
   	   override function top():Number
	   {
		   if (yJustify == TOP)
		   {
				return  y;
		   }
		   else if (yJustify == CENTER)
		   {
				return y - h / 2.0;   
		   }
		   else //(xJustify == BOTTOM)
		   {
				return y - h;   
		   }
	   }
	   
	    override function bottom():Number
	   {
		   if (yJustify == TOP)
		   {
				return  y + h;
		   }
		   else if (yJustify == CENTER)
		   {
				return y + h / 2.0;   
		   }
		   else //(xJustify == BOTTOM)
		   {
				return y;   
		   }
	   }
	   
	   
	   override function right():Number
	   {
		   if (xJustify == LEFT)
		   {
				return  x + w;
		   }
		   else if (xJustify == CENTER)
		   {
				return x + w / 2.0;   
		   }
		   else // (xJustify == RIGHT)
		   {
				return x;   
		   }
	   }
	   
	   private function resetTextPosition() : void
	   {
		   	if (xJustify == LEFT)
			{
				contents.x = (w - contents.textWidth) / 2; 
			}
			else if (xJustify == CENTER)
			{
				contents.x = -(contents.textWidth) / 2  - 1; 
			}
			else if (xJustify == RIGHT)
			{
			 	contents.x = -(w - contents.textWidth) / 2 - contents.textWidth;
			}
			
			if (yJustify == TOP)
			{
				contents.y = (h - contents.textHeight) / 2; 			
			}
			else if (yJustify == CENTER)
			{
				contents.y = -(contents.textHeight) / 2 ; 		
			}
			else if (yJustify == BOTTOM)
			{
			 	contents.y = -(h - contents.textHeight) / 2 - contents.textHeight - 1; 	
			}
	   }
	   
	   
	   	override public function getHeadPointerAttachPos(fromX, fromY) : Array
		{
			return getClosestCardinalPoint(fromX, fromY);			
		}
	   
	   
	   override public function setWidth(wdth):void
	   {
			w = wdth;
			resetTextPosition();
			dirty = true;
	   }
	   
	   	   
	   override public function setHeight(hght):void
	   {
			h = hght;
			resetTextPosition();
			dirty = true;
	   }
	   
	   	override public function getWidth():Number
		{
			return w;
		}
		
		override public function getHeight():Number
		{
			return h;
		}
	   
	   override public function forceRedraw():void
	   {
		   var startX:Number;
		   var startY:Number;
		   
		   if (xJustify == LEFT)
		   {
				startX = 0;   
		   }
		   else if (xJustify == CENTER)
		   {
			    startX = -w / 2.0;
			   
		   }
		   else if (xJustify == RIGHT)
		   {
			 	startX = -w;
		   }
		   if (yJustify == TOP)
		   {
				startY = 0;   
		   }
		   else if (yJustify == CENTER)
		   {
			    startY = -h / 2;
			   
		   }
		   else if (yJustify == BOTTOM)
		   {
			 	startY = -h;
		   }
		   
		 	rectangle.graphics.clear();
			if (highlighted)
			{
				rectangle.graphics.lineStyle(1,0xFF0000,1.0);
				rectangle.graphics.beginFill(0xFF0000);
				rectangle.graphics.moveTo(startX - highlightDiff,startY- highlightDiff);
				rectangle.graphics.lineTo(startX+w + highlightDiff,startY- highlightDiff);
				rectangle.graphics.lineTo(startX+w+ highlightDiff,startY+h + highlightDiff);
				rectangle.graphics.lineTo(startX - highlightDiff,startY+h + highlightDiff);
				rectangle.graphics.lineTo(startX - highlightDiff,startY - highlightDiff);				
				rectangle.graphics.endFill();
		    }
			rectangle.graphics.lineStyle(1,foregroundColor,1.0);
			rectangle.graphics.beginFill(backgroundColor);
			rectangle.graphics.moveTo(startX ,startY);
			rectangle.graphics.lineTo(startX + w, startY);
			rectangle.graphics.lineTo(startX + w, startY + h);
			rectangle.graphics.lineTo(startX, startY + h);
			rectangle.graphics.lineTo(startX, startY);
			if (nullPointer)
			{
				rectangle.graphics.lineTo(startX + w, startY + h);
			}
			rectangle.graphics.endFill();

			
		}
	   
	   
	   	override public function setText(newText:String, textIndex:int = 0)
		{
			if (contents != null)
			{
				contents.text = newText;
				contents.width = contents.textWidth * 2;
				contents.height = contents.textHeight * 1.3;
				resetTextPosition();
			}
		}
	   
	   
	   	override public function createUndoDelete() : UndoBlock
		{
			// TODO: Add color?
			return new UndoDeleteRectangle(nodeID, contents.text, x, y, w, h, xJustify, yJustify, backgroundColor, foregroundColor, layer);
		}
		
		override public function setHighlight(value):void
		{
			if (value != highlighted)
			{
				highlighted = value;
				dirty = true;
			}
		}
	}
}