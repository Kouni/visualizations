package Objects
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.display.BlendMode;


	public class AnimatedCircle extends AnimatedObject
	{

		var radius:Number = 20;
		static var maxHeightDiff:Number = 5;
		static var minHeightDiff:Number = 3;
		static var range:Number = maxHeightDiff - minHeightDiff + 1;
		static var increasing:Boolean = false;
		static var highlightDiff:Number = 3;
		var circle:Sprite;
		var currentHeightDif = 6;

		function AnimatedCircle(id, val):void
		{

			foregroundColor = 0x000000;
			backgroundColor = 0xFFFFFF;
			labelColor = 0xFFFFFF;
			circle = new Sprite();
			circle.graphics.lineStyle(1,0x000000,1.0);
			circle.graphics.beginFill(0xFFFFFF);
			circle.graphics.drawCircle(0, 0, radius);
			circle.graphics.endFill();
			//circle.blendMode = BlendMode.LAYER;
			addChild(circle);

			contents = new TextField();
			//contents.blendMode = BlendMode.LAYER;
			contents.text = val;
			contents.x = -contents.textWidth / 2 - 2;
			contents.y = -contents.textHeight / 2 - 2;
			contents.height = contents.textHeight * 1.3;
			contents.width = contents.textWidth  * 2;
			contents.mouseEnabled = false;
			highlighted = false;
			addChild(contents);
			nodeID = id;
			blendMode = BlendMode.LAYER;

		}
	   
	   override public function forceRedraw():void
	   {
			circle.graphics.clear();
			if (highlighted)
			{
				circle.graphics.lineStyle(1,HIGHLIGHT_COLOR,1.0);
				circle.graphics.beginFill(HIGHLIGHT_COLOR);
				circle.graphics.drawCircle(0, 0, radius + highlightDiff);
				circle.graphics.endFill();
			}
			circle.graphics.lineStyle(1,foregroundColor,1.0);
			circle.graphics.beginFill(backgroundColor);
			circle.graphics.drawCircle(0, 0, radius);
			circle.graphics.endFill();	   
	   }
	   
	   
	   override public function setWidth(wdth):void
	   {
			radius = wdth;
			dirty = true;
	   }
	   
	   
	    override public function getTailPointerAttachPos(fromX, fromY, anchorPoint) : Array
		{
			var xVec:Number = fromX - x;
			var yVec:Number = fromY - y;
			var len:Number = Math.sqrt(xVec * xVec + yVec*yVec);
			if (len == 0)
			{
				return [x, y];
			}
			return [x+(xVec/len)*radius, y +(yVec/len)*radius];
			
		}

		
		override public function getHeadPointerAttachPos(fromX, fromY) : Array
		{
			var xVec:Number = fromX - x;
			var yVec:Number = fromY - y;
			var len:Number = Math.sqrt(xVec * xVec + yVec*yVec);
			if (len == 0)
			{
				return [x, y];
			}
			return [x+(xVec/len)*radius, y +(yVec/len)*radius];
			
		}
	   
	   	   
	   override public function setHeight(hght):void
	   {
			radius = hght;
			dirty = true;
	   }
	   
	   	override public function getWidth():Number
		{
			return radius;
		}
		
		override public function getHeight():Number
		{
			return radius;
		}
	   
	   
	   
	   	override public function setText(newText:String, textIndex:int = 0)
		{
			if (contents != null)
			{
				contents.text = newText;
				contents.x = -contents.textWidth / 2 - 2;
				contents.y = -contents.textHeight / 2 - 2;		
				contents.height = contents.textHeight * 1.3;
				contents.width = contents.textWidth  * 2;
			}
		}
	   

	   
	   	override public function createUndoDelete() : UndoBlock
		{
			// TODO: Add color?
			return new UndoDeleteCircle(nodeID, contents.text, x, y, foregroundColor, backgroundColor, layer);
		}
		

	}
}