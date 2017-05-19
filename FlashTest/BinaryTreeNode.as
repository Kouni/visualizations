package 
{
	import flash.display.Sprite;
	import flash.text.TextField;

	public class BinaryTreeNode extends AnimatedObject
	{

		var radius:int = 20;
		static var maxHeightDiff:int = 5;
		static var minHeightDiff:int = 3;
		static var range:int = maxHeightDiff - minHeightDiff + 1;
		static var increasing:Boolean = false;
		static var highlightDiff:int = 3;
		var circle:Sprite;
		var currentHeightDif = 6;

		function BinaryTreeNode(id, val):void
		{

			circle = new Sprite();
			circle.graphics.lineStyle(1,0x000000,1.0);
			circle.graphics.beginFill(0xFFFFFF);
			circle.graphics.drawCircle(0, 0, radius);
			circle.graphics.endFill();
			addChild(circle);

			contents = new TextField();
			contents.text = val;
			contents.x = -contents.textWidth / 2 - 2;
			contents.y = -contents.textHeight / 2 - 2;
			highlighted = false;
			addChild(contents);
			nodeID = id;
		}
	   
	   override public function forceRedraw():void
	   {
			circle.graphics.clear();
			if (highlighted)
			{
				circle.graphics.lineStyle(1,0xFF0000,1.0);
				circle.graphics.beginFill(0xFF0000);
				circle.graphics.drawCircle(0, 0, radius + highlightDiff);
				circle.graphics.endFill();
			}
			circle.graphics.lineStyle(1,0x000000,1.0);
			circle.graphics.beginFill(0xFFFFFF);
			circle.graphics.drawCircle(0, 0, radius);
			circle.graphics.endFill();	   
	   }
	   
	   
	   	override public function setText(newText:String)
		{
			if (contents != null)
			{
				contents.text = newText;
				contents.x = -contents.textWidth / 2 - 2;
				contents.y = -contents.textHeight / 2 - 2;
			}
		}
	   
	   override public function pulseHighlight(frameNum:int):void
	   {
		   if (highlighted)
		   {
			   var frameMod:int = frameNum / 7;
			   var delta:int  = Math.abs((frameMod) % (2 * range  - 2) - range + 1)
			   highlightDiff =  delta + minHeightDiff;
			   forceRedraw();			   
		   }
	   }
		override public function setHighlight(value):void
		{
			if (value != highlighted)
			{
				highlighted = value;
				forceRedraw();
			}
		}
	}
}