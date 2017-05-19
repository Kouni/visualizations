package Objects
{
	import flash.text.TextField;
	import flash.display.BlendMode;
	import flash.display.Sprite;
	
   public class Line
   {
	   	static const maxHeightDiff:Number = 5;
		static const minHeightDiff:Number = 3;
		static const range:Number = maxHeightDiff - minHeightDiff + 1;
		
		static var highlightDiff:Number = 3;

	   public var arrowHeight:Number = 8;
	   public var arrowWidth:Number = 4;
	   public var Node1:AnimatedObject;
	   public var Node2:AnimatedObject;
	   public var Dirty:Boolean;
	   public var graphic:Sprite;
	   public var directed:Boolean = true;
	   public var edgeColor:uint;
	   public var alpha:Number;
	   public var curve:Number;
	   public var edgeLabel:TextField;
	   public var highlighted:Boolean;
	   public var addedToScene:Boolean;
	   public var anchorPoint:int;
	   
	   
	   public function Line(n1, n2, c = 0x000000, cv:Number = 0,directedEdge:Boolean = true, weight = "", anchorIndex = 0)
	   {
			Node1 = n1;
			Node2 = n2;
			graphic = new Sprite();
			Redraw();			
			Dirty = true;
			edgeColor = c;
			directed = directedEdge;
			alpha = 1.0;
			curve = cv;
			edgeLabel = new TextField();
			edgeLabel.blendMode = BlendMode.LAYER;
			edgeLabel.text = weight;
			edgeLabel.width = edgeLabel.textWidth * 2;
			edgeLabel.height = edgeLabel.textHeight * 2;
			edgeLabel.mouseEnabled = false;
			edgeLabel.textColor = edgeColor;

			graphic.addChild(edgeLabel);
			highlighted = false;
			anchorPoint = anchorIndex;

	   }
	   
	   
	   public function color()
	   {
			return edgeColor;   
	   }
	   
	   public function setColor(newColor:uint)
	   {
			edgeColor = newColor;
			edgeLabel.textColor = edgeColor;
			Dirty = true;
	   }
	   
	   public function setHighlight(highlightVal:Boolean)
	   {
			highlighted = highlightVal;   
	   }
		   
	   public function pulseHighlight(frameNum:int):void
	   {
		   if (highlighted)
		   {
			   var frameMod:Number = frameNum / 14.0;
			   var delta:Number  = Math.abs((frameMod) % (2 * range  - 2) - range + 1)
			   highlightDiff =  delta + minHeightDiff;
			   Dirty = true;			   
		   }
	   }
	   
	   
	   public function hasNode(n):Boolean
	   {
			return ((Node1 == n) || (Node2 == n));   
	   }
	   
	   
	   public function createUndoDisconnect()
	   {
			return new UndoConnect(Node1.nodeID, Node2.nodeID, true, edgeColor, directed, curve, edgeLabel.text, anchorPoint);
	   }
	   
	   
	   function sign(n)
	   {
		   if (n > 0)
		   {
			   return 1;
		   }
		   else
		   {
			   return -1;
		   }
	   }
	   
	   
	   private function drawArrow(pensize, color)
	   {
		   
			if (graphic.alpha == 0)
			{
				Dirty =  false;
				return;
			}
			var fromPos:Array = Node1.getTailPointerAttachPos(Node2.x, Node2.y, anchorPoint);
			var toPos:Array = Node2.getHeadPointerAttachPos(Node1.x, Node1.y);

			var deltaX = toPos[0] - fromPos[0];
			var deltaY = toPos[1] - fromPos[1];
			var midX:Number = (deltaX) / 2 + fromPos[0];
			var midY:Number = (deltaY) / 2 + fromPos[1];
			var controlX:Number = midX - deltaY * curve;
			var controlY:Number = midY + deltaX *curve;
			graphic.graphics.lineStyle(pensize,color,alpha);
			graphic.graphics.moveTo(fromPos[0], fromPos[1]);
			graphic.graphics.curveTo( controlX, controlY, toPos[0], toPos[1]);

			
			// Position of the edge label:  First, we will place it right along the
			// middle of the curve (or the middle of the line, for curve == 0)
			var labelPosX:Number = 0.25* fromPos[0] + 0.5*controlX + 0.25*toPos[0]; 
			var labelPosY:Number =  0.25* fromPos[1] + 0.5*controlY + 0.25*toPos[1]; 
			
			// Next, we push the edge position label out just a little in the direction of
			// the curve, so that the label doesn't intersect the cuve (as long as the label
			// is only a few characters, that is)
			var midLen:Number = Math.sqrt(deltaY*deltaY + deltaX*deltaX);
			if (midLen != 0)
			{
				labelPosX +=  (- deltaY * sign(curve))  / midLen * 10 
				labelPosY += ( deltaX * sign(curve))  / midLen * 10  
			}
			

			// Finally, center the label around this calculated position.
			edgeLabel.x = labelPosX - edgeLabel.textWidth / 2 -2 ;
			edgeLabel.y =labelPosY  - edgeLabel.textHeight / 2 - 2;
			
			
			if (edgeLabel.x < 50)
			{
				var y = 3;
				y = y + 1;
				
			}
			if (directed)
			{
				var xVec:Number = controlX - toPos[0];
				var yVec:Number = controlY - toPos[1];
				var len:Number = Math.sqrt(xVec * xVec + yVec*yVec);
				
				if (len > 0)
				{
					xVec = xVec / len
					yVec = yVec / len;
					
					graphic.graphics.moveTo(toPos[0], toPos[1]);
					graphic.graphics.beginFill(color, alpha);
					graphic.graphics.lineTo(toPos[0] + xVec*arrowHeight - yVec*arrowWidth, toPos[1] + yVec*arrowHeight + xVec*arrowWidth);
					graphic.graphics.lineTo(toPos[0] + xVec*arrowHeight + yVec*arrowWidth, toPos[1] + yVec*arrowHeight - xVec*arrowWidth);
					graphic.graphics.lineTo(toPos[0], toPos[1]);
					graphic.graphics.endFill();
				}

			}
		   
		   
	   }
	   
	   
	   public function Redraw()
	   {
		   if (Dirty)
		   {
				graphic.graphics.clear();
			   	if (highlighted)
					drawArrow(highlightDiff, 0xFF0000);
				drawArrow(1, edgeColor);

		   }
		   Dirty = false;
	   }
	   
	   
   }
}