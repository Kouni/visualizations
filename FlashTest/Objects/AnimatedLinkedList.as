package Objects
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.display.BlendMode;

	public class AnimatedLinkedList extends AnimatedObject
	{

		var w:Number;
		var h:Number;
		var linkPercent:Number;
		var linkPositionEnd:Boolean;
		var vertical:Boolean;

		// TODO:  Add different # of labels
		
		
		static const maxHeightDiff:Number = 5;
		static const minHeightDiff:Number = 3;
		
		var rectangle:Sprite;
		var currentHeightDif = 6;
		
		var labels:Array;
		var labelPosX:Array;
		var labelPosY:Array;
		var numLabels:int;
		var labelColors:Array;
		var nullPointer:Boolean;
		
		
		function AnimatedLinkedList(id, val, wth, hgt, linkPer = 0.25, verticalOrientation = true, linkPosEnd = false, numLab=1, fillColor = 0xFFFFFF, edgeColor = 0x000000):void
		{
			w = wth;
			h = hgt;
			backgroundColor = fillColor;
			foregroundColor = edgeColor;

			vertical = verticalOrientation;
			linkPositionEnd = linkPosEnd;
			linkPercent = linkPer;
			
			rectangle = new Sprite();
			addChild(rectangle);

			numLabels = numLab;
			
			labels = new Array(numLabels);
			labelPosX = new Array(numLabels);
			labelPosY = new Array(numLabels);
			labelColors = new Array(numLabels);
			
			for (var i:int =0; i < numLabels; i++)
			{
				labels[i] = new TextField();
				labels[i].blendMode = BlendMode.LAYER;
				labels[i].textColor = foregroundColor;

				labels[i] .mouseEnabled = false;

				labelPosX[i] = 0;
				labelPosY[i] = 0;
				labelColors[i] = foregroundColor;
				addChild(labels[i]);
			}
			
			
			
			labels[0].text = val;

			resetTextPosition();
			
			highlighted = false;
			dirty = true;
			nodeID = id;
		}
	   
	   
	   override function left():Number
	   {
		   if (vertical)
		   {
			   return x - w / 2.0; 
		   }
		   else if (linkPositionEnd)
		   {
				return x - ((w * (1 - linkPercent)) / 2);
		   }
		   else
		   {
				return x  - (w * (linkPercent + 1)) / 2;
		   }
	   }
	   
	   public override function setNull(np:Boolean)
	   {
		   if (nullPointer != np)
		   {		   
			   nullPointer = np;
			   dirty = true;
		   }

	   }
	   
	  public  override function getNull():Boolean
	   {
			return nullPointer;   
	   }
	   
	   override function right():Number
	   {
		   if (vertical)
		   {
			   return x + w / 2.0; 
		   }
		   else if (linkPositionEnd)
		   {
				return x + ((w * (linkPercent + 1)) / 2);
		   }
		   else
		   {
				return x + (w * (1 - linkPercent)) / 2;
		   }
	   } 
	   
   	   override function top():Number
	   {
		   if (!vertical)
		   {
			   return y - h / 2.0; 			   
		   }
		   else if (linkPositionEnd)
		   {
			   return y - (h * (1 -linkPercent)) / 2;   
		   }
		   else
		   {
			    return y - (h * (1 + linkPercent)) / 2;   
		   }
	   }
	   
	   override function bottom():Number
	   {
		   if (!vertical)
		   {
			   return y + h / 2.0; 			   
		   }
		   else if (linkPositionEnd)
		   {
			   return y + (h * (1 +linkPercent)) / 2;   
		   }
		   else
		   {
			    return y + (h * (1 - linkPercent)) / 2;   
		   }
	   }
	   
	   	   
	   private function resetTextPosition() : void
	   {
		   	if (vertical)
			{
				
				labelPosY[0] = h * (1-linkPercent)/2 *(1/numLabels - 1);				
//				labelPosY[0] = -height * (1-linkPercent) / 2 + height*(1-linkPercent)/2*numLabels;
				for (var i:int = 1; i < numLabels; i++)
				{
					labelPosY[i] = labelPosY[i-1] +  h*(1-linkPercent)/numLabels;
				}
			}
			else
			{
				labelPosX[0] = w * (1-linkPercent)/2*(1/numLabels - 1);
				for (i = 1; i < numLabels; i++)
				{
					labelPosX[i] = labelPosX[i-1] +  w*(1-linkPercent)/numLabels;
				}				
			}

		   for (i = 0; i < numLabels; i++)
		   {
			   labels[i].x = labelPosX[i]  -(labels[i].textWidth) / 2 - 1
			   labels[i].y = labelPosY[i]  -(labels[i].textHeight) / 2 - 1;
		   }
	   }
	   
	   
	   	override public function getTailPointerAttachPos(fromX, fromY, anchor) : Array
		{
			if (vertical && linkPositionEnd)
			{
				return [x, y + h / 2.0];				
			}
			else if (vertical && !linkPositionEnd)
			{
				return [x, y - h / 2.0];							
			}
			else if  (!vertical && linkPositionEnd)
			{
				return [x + w / 2.0, y];								
			}
			else // (!vertical && !linkPositionEnd)
			{
				return [x - w / 2.0, y];								
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
		   
		 	startX = left() - x;
		   	startY = top() - y;
			   
		 	rectangle.graphics.clear();
			if (highlighted)
			{
				rectangle.graphics.lineStyle(1,HIGHLIGHT_COLOR,1.0);
				rectangle.graphics.beginFill(HIGHLIGHT_COLOR);
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
			rectangle.graphics.endFill();
			
			if (vertical)
			{
				startX = left() - x;
				for (var i:int = 1; i < numLabels; i++)
				{
					startY = h*(1-linkPercent)*(i / numLabels - 1/2);
					rectangle.graphics.moveTo(startX, startY)
					rectangle.graphics.lineTo(startX + w, startY)
				}
			}
			else
			{
				startY = top() - y;
				for (i = 1; i < numLabels; i++)
				{
					startX = w*(1-linkPercent)*(i / numLabels - 1/2);
					rectangle.graphics.moveTo(startX, startY)
					rectangle.graphics.lineTo(startX, startY + h)
				}			
			}
					   
		   	if (vertical && linkPositionEnd)
			{
				startX = left() - x;
				startY = bottom() - y - h * linkPercent;
				rectangle.graphics.moveTo(startX + w, startY);
				rectangle.graphics.lineTo(startX, startY);
				if (nullPointer)
				{	
					rectangle.graphics.lineTo(startX + w, bottom() - y);
				}
			}
			else if (vertical && !linkPositionEnd)
			{
				startX = left() - x;
				startY = top() - y + h * linkPercent;
				rectangle.graphics.moveTo(startX + w, startY);
				rectangle.graphics.lineTo(startX, startY);
				if (nullPointer)
				{	
					rectangle.graphics.lineTo(startX + w, top() - y);
				}
			}
			else if  (!vertical && linkPositionEnd)
			{
				startX = right() - x - w * linkPercent;
				startY = top() - y;
				rectangle.graphics.moveTo(startX, startY+h);
				rectangle.graphics.lineTo(startX, startY);
				
				if (nullPointer)
				{	
					rectangle.graphics.lineTo(right() - x, startY+h);
				}
			}
			else // (!vertical && !linkPositionEnd)
			{
				startX = left() - x + w * linkPercent;
				startY = top() - y;
				rectangle.graphics.moveTo(startX, startY+h);
				rectangle.graphics.lineTo(startX, startY);
				if (nullPointer)
				{	
					rectangle.graphics.lineTo(left() - x, startY);
				}
			}			
		}
	   
	   
	   
	   	override public function setTextColor(color, textIndex:int = 0)
		{
			
			labelColors[textIndex] = color;
			if (labels[textIndex] != null)
			{
				labels[textIndex].textColor = color;
			}
		}
		
		
				
		override public function getTextColor(textIndex:int = 0)
		{
			return labelColors[textIndex];
		}
		
	   
	   
	   override public function getText(index:int = 0):String
	   {
			return labels[index].text;  
	   }
	   
	   	override public function setText(newText:String, textIndex:int = 0)
		{
			if (labels[textIndex] != null)
			{
				labels[textIndex].text = newText;
				labels[textIndex].height = labels[textIndex].textHeight * 1.3;
				labels[textIndex].width = labels[textIndex].textWidth  * 2;
				resetTextPosition();
			}
		}
	   
	   
	   
	   
	   

	   
	   	override public function createUndoDelete() : UndoBlock
		{
			var labelText:Array = new Array(numLabels);
			for (var i:int = 0; i < numLabels; i++)
			{
				labelText[i] = labels[i].text;
			}
			
			
			return new UndoDeleteLinkedList(nodeID, numLabels, labelText, x, y, w, h, linkPercent, linkPositionEnd, vertical, labelColors, backgroundColor, foregroundColor, layer, nullPointer);
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