package Objects
{

	public class UndoSetNumElements extends UndoBlock
	{
		var objectID:int;
		var sizeBeforeChange:int;
		var sizeAfterChange:int;
		var labels:Array;
		var colors:Array;
		
		function UndoSetNumElements(obj:AnimatedBTreeNode, newNumElems:int):void
		{
			objectID = obj.nodeID;
			sizeBeforeChange = obj.getNumElements();
			sizeAfterChange = newNumElems;
			if (sizeBeforeChange > sizeAfterChange)
			{
				labels = new Array(sizeBeforeChange - sizeAfterChange);
				colors = new Array(sizeBeforeChange - sizeAfterChange);
				for (var i:int = 0; i < sizeBeforeChange - sizeAfterChange; i++)
				{
					labels[i] = obj.getText(i+sizeAfterChange);
					colors[i] = obj.getTextColor(i+sizeAfterChange);
				}
				
			}
			
		}
		override public function undoInitialStep(world) :void
		{
			world.setNumElements(objectID, sizeBeforeChange);
			if (sizeBeforeChange > sizeAfterChange)
			{
				for (var i:int = 0; i < sizeBeforeChange - sizeAfterChange; i++)
				{
					world.setText(objectID, labels[i], i+sizeAfterChange);
					world.setTextColor(objectID, colors[i], i+sizeAfterChange);
				}
			}
		}
	}
}