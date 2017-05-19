package Objects
{
	import flash.display.Sprite;
	import flash.text.TextField;

	public class HighlightCircle extends AnimatedObject
	{

		var thickness:int = 4;
		var r:int = 20;
		var circle:Sprite;
		var circleColor:uint = 0x0000FF;

		function HighlightCircle(id, color = 0x0000FF, radius = 20):void
		{

			circle = new Sprite();
			circleColor = color;
			r = radius
			circle.graphics.lineStyle(4, color);
			circle.graphics.drawCircle(0, 0, r);
			addChild(circle);
			nodeID = id;
		}
		
		override public function createUndoDelete() : UndoBlock
		{
			return new UndoDeleteHighlightCircle(nodeID, x, y, circleColor, r, layer);
		}
		
		override public function setHighlight(value):void
		{

			// None for now ...

		}
	}
}