package 
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.display.DisplayObjectContainer;
	import fl.controls.Button;
	import fl.controls.TextInput;
	import flash.text.TextFormat;
	import flash.events.MouseEvent;
	import fl.events.ComponentEvent;



	public class BucketSort extends AlgorithmAnimation
	{

		// Input Controls
		var resetButton:Button;
		var bucketSortButton:Button;
		
		
		static const ARRAY_ELEM_WIDTH_SMALL = 30;
		static const ARRAY_ELEM_HEIGHT_SMALL = 30;
		static const ARRAY_ELEM_START_X_SMALL = 20;
		
		static const ARRAY_ELEMENT_Y_SMALL = 150;
		
		static const POINTER_ARRAY_ELEM_WIDTH_SMALL = 30;
		static const POINTER_ARRAY_ELEM_HEIGHT_SMALL = 30;
		static const POINTER_ARRAY_ELEM_START_X_SMALL = 20;
		static const POINTER_ARRAY_ELEM_Y_SMALL = 550;
		
		static const LINKED_ITEM_HEIGHT_SMALL = 30;
		static const LINKED_ITEM_WIDTH_SMALL = 24;
		
		static const LINKED_ITEM_Y_DELTA_SMALL = 50;
		static const LINKED_ITEM_POINTER_PERCENT_SMALL = 0.25;

		static const MAX_DATA_VALUE = 999;
		
		static const ARRAY_SIZE_SMALL:int  = 30;

		static const ARRAY_Y_POS = 350;

		var nextIndex = 0;
			
		
		
		var arrayData:Array;
		var arrayRects:Array;
		
		var upperIndices:Array;
		var lowerIndices:Array;
		
		
		var linkedListRects:Array;
		
		var linkedListData:Array;
		
		var oldData:Array;
		
		public function BucketSort(am)
		{
			super(am);

			commands = new Array();

			resetButton = new Button();
			resetButton.label = "Randomize List";
			resetButton.x = 10;
			addChild(resetButton);

			bucketSortButton = new Button();
			bucketSortButton.label = "Bucket Sort";
			bucketSortButton.x = 110;
			addChild(bucketSortButton);



			resetButton.addEventListener(MouseEvent.MOUSE_DOWN, resetCallback);
			bucketSortButton.addEventListener(MouseEvent.MOUSE_DOWN, bucketSortCallback);
			
			setup();

		}
		
		private function setup()
		{
			arrayData = new Array(ARRAY_SIZE_SMALL);
			arrayRects= new Array(ARRAY_SIZE_SMALL);
			linkedListRects = new Array(ARRAY_SIZE_SMALL);
			linkedListData = new Array(ARRAY_SIZE_SMALL);
			upperIndices = new Array(ARRAY_SIZE_SMALL);
			lowerIndices = new Array(ARRAY_SIZE_SMALL);
			commands = new Array();
			oldData = new Array(ARRAY_SIZE_SMALL);
			
			for (var i:int = 0; i < ARRAY_SIZE_SMALL; i++)
			{
				var nextID = nextIndex++;
				arrayData[i] = Math.floor(Math.random()*MAX_DATA_VALUE);
				oldData[i] = arrayData[i];
				cmd("CreateRectangle", nextID, arrayData[i], ARRAY_ELEM_WIDTH_SMALL, ARRAY_ELEM_HEIGHT_SMALL, ARRAY_ELEM_START_X_SMALL + i *ARRAY_ELEM_WIDTH_SMALL, ARRAY_ELEMENT_Y_SMALL)
				arrayRects[i] = nextID;
				nextID = nextIndex++;
				cmd("CreateRectangle", nextID, "", POINTER_ARRAY_ELEM_WIDTH_SMALL, POINTER_ARRAY_ELEM_HEIGHT_SMALL, POINTER_ARRAY_ELEM_START_X_SMALL + i *POINTER_ARRAY_ELEM_WIDTH_SMALL, POINTER_ARRAY_ELEM_Y_SMALL)
				linkedListRects[i] = nextID;
				cmd("SetNull", linkedListRects[i], 1);
				nextID = nextIndex++;
				upperIndices[i] = nextID;
				cmd("CreateLabel",nextID,  i,  ARRAY_ELEM_START_X_SMALL + i *ARRAY_ELEM_WIDTH_SMALL, ARRAY_ELEMENT_Y_SMALL + ARRAY_ELEM_HEIGHT_SMALL);
				cmd("SetForegroundColor", nextID, 0x0000FF);

				nextID = nextIndex++;
				lowerIndices[i] = nextID;
				cmd("CreateLabel", nextID, i, POINTER_ARRAY_ELEM_START_X_SMALL + i *POINTER_ARRAY_ELEM_WIDTH_SMALL, POINTER_ARRAY_ELEM_Y_SMALL + POINTER_ARRAY_ELEM_HEIGHT_SMALL);
				cmd("SetForegroundColor", nextID, 0x0000FF);
			}
			animationManager.StartNewAnimation(commands);
			animationManager.skipForward();
			animationManager.clearHistory();

		}
		
		
		
		private function resetAll(small)
		{
			animationManager.resetAll();
			nextIndex = 0;
		}
		
		function bucketSortCallback(event)
		{
			var savedIndex = nextIndex;
			commands = new Array();
			linkedListData = new Array(ARRAY_SIZE_SMALL);
			for (var i:int = 0; i < ARRAY_SIZE_SMALL; i++)
			{
				var labelID = nextIndex++;
				var label2ID = nextIndex++;
				var label3ID = nextIndex++;
				var label4ID = nextIndex++;
				var node:LinkedListNode  = new LinkedListNode(arrayData[i],nextIndex++, 100, 75);
				cmd("CreateLinkedList", node.graphicID, "", LINKED_ITEM_WIDTH_SMALL, LINKED_ITEM_HEIGHT_SMALL, 100, 75);
				cmd("SetNull", node.graphicID, 1);

				cmd("CreateLabel", labelID, arrayData[i], ARRAY_ELEM_START_X_SMALL + i *ARRAY_ELEM_WIDTH_SMALL, ARRAY_ELEMENT_Y_SMALL);
				cmd("SetText", node.graphicID, "")
				cmd("SetText", arrayRects[i], "")
				cmd("Move", labelID, 100,75);
				cmd("Step");
				cmd("SetText", node.graphicID, arrayData[i]);
				cmd("Delete", labelID);
				var index : int = (arrayData[i]  * ARRAY_SIZE_SMALL) / (MAX_DATA_VALUE + 1);
				
				cmd("CreateLabel", labelID, "Linked List Array index = " ,  300, 20, 0);
				cmd("CreateLabel", label2ID, "Value * NUMBER_OF_ELEMENTS / (MAXIMUM_ARRAY_VALUE + 1)) = ",  300, 40, 0);
				cmd("CreateLabel", label3ID, "("+ String(arrayData[i]) + " * " + String(ARRAY_SIZE_SMALL) + ") / " + String(MAX_DATA_VALUE+1) + " = " , 300, 60, 0);
				cmd("CreateLabel", label4ID, index, 305, 85);
				cmd("SetForegroundColor", labelID, 0x000000);
				cmd("SetForegroundColor", label2ID, 0x000000);
				cmd("SetForegroundColor", label3ID, 0x000000);
				cmd("SetForegroundColor", label4ID, 0x0000FF);

				
				var highlightCircle = nextIndex++;
				cmd("CreateHighlightCircle", highlightCircle, 0x0000FF,  305, 100);
				cmd("Move", highlightCircle, POINTER_ARRAY_ELEM_START_X_SMALL + index *POINTER_ARRAY_ELEM_WIDTH_SMALL, POINTER_ARRAY_ELEM_Y_SMALL + POINTER_ARRAY_ELEM_HEIGHT_SMALL);
				cmd("Step");
				cmd("Delete", labelID);
				cmd("Delete", label2ID);
				cmd("Delete", label3ID);
				cmd("Delete", label4ID);
				cmd("Delete", highlightCircle);
				
				
				
				if (linkedListData[index] == null)
				{
					linkedListData[index] = node;
					cmd("Connect", linkedListRects[index], node.graphicID);
					cmd("SetNull",linkedListRects[index], 0);

					node.x = POINTER_ARRAY_ELEM_START_X_SMALL + index *POINTER_ARRAY_ELEM_WIDTH_SMALL;
					node.y = POINTER_ARRAY_ELEM_Y_SMALL - LINKED_ITEM_Y_DELTA_SMALL;
					cmd("Move", node.graphicID, node.x, node.y);
				}
				else
				{
					var tmp:LinkedListNode = linkedListData[index];
					cmd("SetHighlight", tmp.graphicID, 1);
					cmd("SetHighlight", node.graphicID, 1);
					cmd("Step");
					cmd("SetHighlight", tmp.graphicID, 0);
					cmd("SetHighlight", node.graphicID, 0);
					
					if (Number(tmp.data) >= Number(node.data))
					{
						cmd("Disconnect", linkedListRects[index], linkedListData[index].graphicID);
						node.next = tmp;
						cmd("Connect", linkedListRects[index], node.graphicID);
						cmd("Connect", node.graphicID, tmp.graphicID);
						cmd("SetNull",node.graphicID, 0);
						linkedListData[index] = node;
						cmd("Connect", linkedListRects[index], node.graphicID);

					}					
					else
					{
						if (tmp.next != null)
						{
							cmd("SetHighlight", tmp.next.graphicID, 1);
							cmd("SetHighlight", node.graphicID, 1);
							cmd("Step");
							cmd("SetHighlight", tmp.next.graphicID, 0);
							cmd("SetHighlight", node.graphicID, 0);
						}

						while (tmp.next != null && tmp.next.data < node.data)
						{
							tmp = tmp.next;
							if (tmp.next != null)
							{
								cmd("SetHighlight", tmp.next.graphicID, 1);
								cmd("SetHighlight", node.graphicID, 1);
								cmd("Step");
								cmd("SetHighlight", tmp.next.graphicID, 0);
								cmd("SetHighlight", node.graphicID, 0);
							}
						}
						if (tmp.next != null)
						{
							cmd("Disconnect", tmp.graphicID, tmp.next.graphicID);
							cmd("Connect", node.graphicID, tmp.next.graphicID);
							cmd("SetNull",node.graphicID, 0);
						}
						else
						{
							cmd("SetNull",tmp.graphicID, 0);
						}
						node.next = tmp.next;
						tmp.next = node;
						cmd("Connect", tmp.graphicID, node.graphicID);						
					}
					tmp = linkedListData[index];
					var startX = POINTER_ARRAY_ELEM_START_X_SMALL + index *POINTER_ARRAY_ELEM_WIDTH_SMALL;
					var startY =  POINTER_ARRAY_ELEM_Y_SMALL - LINKED_ITEM_Y_DELTA_SMALL;
					while (tmp != null)
					{
						tmp.x = startX;
						tmp.y = startY;
						cmd("Move", tmp.graphicID, tmp.x, tmp.y);
						startY = startY - LINKED_ITEM_Y_DELTA_SMALL;
						tmp = tmp.next;
					}
					

					
				}
				cmd("Step");
			}
			var insertIndex = 0;
			for (i = 0; i < ARRAY_SIZE_SMALL; i++)
			{
				for (tmp = linkedListData[i]; tmp != null; tmp = tmp.next)
				{
					var moveLabelID = nextIndex++;
					cmd("SetText", tmp.graphicID, "");
					cmd("SetText", arrayRects[insertIndex], "");
					cmd("CreateLabel", moveLabelID, tmp.data, tmp.x, tmp.y);
					cmd("Move", moveLabelID,  ARRAY_ELEM_START_X_SMALL + insertIndex *ARRAY_ELEM_WIDTH_SMALL, ARRAY_ELEMENT_Y_SMALL);
					cmd("Step");
					cmd("Delete", moveLabelID);
					cmd("SetText", arrayRects[insertIndex], tmp.data);
					cmd("Delete", tmp.graphicID);
					if (tmp.next != null)
					{
						cmd("Connect", linkedListRects[i], tmp.next.graphicID);
					}
					arrayData[insertIndex] = tmp.data;
					insertIndex++;
				}
				
				
			}
			animationManager.StartNewAnimation(commands);
			insertIndex = savedIndex;
		}
		
		private function randomizeArray()
		{
			commands = new Array();
			for (var i:int = 0; i < ARRAY_SIZE_SMALL; i++)
			{
				arrayData[i] =  Math.floor(1 + Math.random()*MAX_DATA_VALUE);
				oldData[i] = arrayData[i];
				cmd("SetText", arrayRects[i], arrayData[i]);
			}
			
			
			
			animationManager.StartNewAnimation(commands);
			animationManager.skipForward();
			animationManager.clearHistory();
			
		}
		
		
		
		// We want to (mostly) ignore resets, since we are disallowing undoing 
		override function reset()
		{
			commands = new Array();
			for (var i:int = 0; i < ARRAY_SIZE_SMALL; i++)
			{
				arrayData[i] = oldData[i];
			}
		}
		
		
		function resetCallback(event):void
		{
			randomizeArray();
		}
		
		
		
		override function enableUI(event:AnimationStateEvent):void
		{
			resetButton.enabled = true;
			bucketSortButton.enabled = true;
		}
		override function disableUI(event:AnimationStateEvent):void
		{
			resetButton.enabled = false;
			bucketSortButton.enabled = false;
		}
	}
}