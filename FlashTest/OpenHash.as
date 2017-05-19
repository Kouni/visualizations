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



	public class OpenHash extends Hash
	{

		// Input Controls			
		
		
		
		static const POINTER_ARRAY_ELEM_WIDTH = 70;
		static const POINTER_ARRAY_ELEM_HEIGHT = 30;
		static const POINTER_ARRAY_ELEM_START_X = 50;
		static const POINTER_ARRAY_ELEM_Y = 550;
		
		static const LINKED_ITEM_HEIGHT = 30;
		static const LINKED_ITEM_WIDTH = 65;
		
		static const LINKED_ITEM_Y_DELTA = 50;
		static const LINKED_ITEM_POINTER_PERCENT = 0.25;

		static const MAX_DATA_VALUE = 999;
		
		static const HASH_TABLE_SIZE:int  = 13;

		static const ARRAY_Y_POS = 350;
			
		
		static const INDEX_COLOR = 0x0000FF;
		
		
		var ExplainLabel:int;
		var resetIndex;
		
				
		public function OpenHash(am)
		{
			super(am);
			
			setup();

			restrictToInegers();
		}
		


		


		
		override function insertElement(elem)
		{
			commands = new Array();
			cmd("SetText", ExplainLabel, "Inserting element: " + String(elem));
			var index = doHash(elem);
			var node:LinkedListNode  = new LinkedListNode(elem,nextIndex++, 100, 75);
			cmd("CreateLinkedList", node.graphicID, elem, LINKED_ITEM_WIDTH, LINKED_ITEM_HEIGHT, 100, 75);
			if (hashTableValues[index] != null)
			{
				cmd("connect", node.graphicID, hashTableValues[index].graphicID);
				cmd("disconnect", hashTableVisual[index], hashTableValues[index].graphicID);				
			}
			else
			{
				cmd("SetNull", node.graphicID, 1);
				cmd("SetNull", hashTableVisual[index], 0);
			}
			cmd("connect", hashTableVisual[index], node.graphicID);
			node.next = hashTableValues[index];
			hashTableValues[index] = node;
			
			repositionList(index);

			cmd("SetText", ExplainLabel, "");

			return commands;

		}
	
	
		function repositionList(index)
		{
			var startX = POINTER_ARRAY_ELEM_START_X + index *POINTER_ARRAY_ELEM_WIDTH;
			var startY =  POINTER_ARRAY_ELEM_Y - LINKED_ITEM_Y_DELTA;
			var tmp = hashTableValues[index];
			while (tmp != null)
			{
				tmp.x = startX;
				tmp.y = startY;
				cmd("Move", tmp.graphicID, tmp.x, tmp.y);
				startY = startY - LINKED_ITEM_Y_DELTA;
				tmp = tmp.next;
			}
		}
		
		
		override function deleteElement(elem)
		{
			commands = new Array();
			cmd("SetText", ExplainLabel, "Deleting element: " + elem);
			var index = doHash(elem);
			if (hashTableValues[index] == null)
			{
				cmd("SetText", ExplainLabel, "Deleting element: " + elem + "  Element not in table");
				return commands;
			}
			cmd("SetHighlight", hashTableValues[index].graphicID, 1);
			cmd("Step");
			cmd("SetHighlight", hashTableValues[index].graphicID, 0);
			if (hashTableValues[index].data == elem)
			{
				if (hashTableValues[index].next != null)
				{
					cmd("Connect", hashTableVisual[index], hashTableValues[index].next.graphicID);
				}
				else
				{
					cmd("SetNull", hashTableVisual[index], 1);
				}
				cmd("Delete", hashTableValues[index].graphicID);
				hashTableValues[index] = hashTableValues[index].next;
				repositionList(index);
				return commands;
			}
			var tmpPrev = hashTableValues[index];
			var tmp = hashTableValues[index].next;
			var found = false;
			while (tmp != null && !found)
			{
				cmd("SetHighlight", tmp.graphicID, 1);
				cmd("Step");
				cmd("SetHighlight", tmp.graphicID, 0);
				if (tmp.data == elem)
				{
					found = true;
					cmd("SetText", ExplainLabel, "Deleting element: " + elem + "  Element deleted");
					if (tmp.next != null)
					{
						cmd("Connect", tmpPrev.graphicID, tmp.next.graphicID);
					}
					else
					{
						cmd("SetNull", tmpPrev.graphicID, 1);
					}
					tmpPrev.next = tmpPrev.next.next;
					cmd("Delete", tmp.graphicID);
					repositionList(index);
				}
				else
				{
					tmpPrev = tmp;
					tmp = tmp.next;
				}		
			}
			if (!found)
			{
				cmd("SetText", ExplainLabel, "Deleting element: " + elem + "  Element not in table");
			}
			return commands;
			
		}
		override function findElement(elem)
		{
			commands = new Array();
			cmd("SetText", ExplainLabel, "Finding Element: " + elem);
			var index = doHash(elem);
			var compareIndex = nextIndex++;
			var found = false;
			var tmp = hashTableValues[index];
			cmd("CreateLabel", compareIndex, "", 10, 40, 0);
			while (tmp != null && !found)
			{
				cmd("SetHighlight", tmp.graphicID, 1);
				if (tmp.data == elem)
				{
					cmd("SetText", compareIndex,  tmp.data  + "==" + elem)
					found = true;
				}
				else
				{
					cmd("SetText", compareIndex,  tmp.data  + "!=" + elem)
				}
				cmd("Step");
				cmd("SetHighlight", tmp.graphicID, 0);
				tmp = tmp.next;
			}
			if (found)
			{
				cmd("SetText", ExplainLabel, "Finding Element: " + elem+ "  Found!")				
			}
			else
			{
				cmd("SetText", ExplainLabel, "Finding Element: " + elem+ "  Not Found!")

			}
			cmd("Delete", compareIndex);
			nextIndex--;
			return commands;
		}
		
		
		
		
		private function setup()
		{
			hashTableVisual = new Array(HASH_TABLE_SIZE);
			hashTableIndices = new Array(HASH_TABLE_SIZE);
			hashTableValues = new Array(HASH_TABLE_SIZE);
			
			indexXPos = new Array(HASH_TABLE_SIZE);
			indexYPos = new Array(HASH_TABLE_SIZE);
			
			ExplainLabel = nextIndex++;
			
			table_size = HASH_TABLE_SIZE;
			
			for (var i:int = 0; i < HASH_TABLE_SIZE; i++)
			{
				var nextID:int  = nextIndex++;

				cmd("CreateRectangle", nextID, "", POINTER_ARRAY_ELEM_WIDTH, POINTER_ARRAY_ELEM_HEIGHT, POINTER_ARRAY_ELEM_START_X + i *POINTER_ARRAY_ELEM_WIDTH, POINTER_ARRAY_ELEM_Y)
				hashTableVisual[i] = nextID;
				cmd("SetNull", hashTableVisual[i], 1);

				nextID = nextIndex++;
				hashTableIndices[i] = nextID;
				indexXPos[i] =  POINTER_ARRAY_ELEM_START_X + i *POINTER_ARRAY_ELEM_WIDTH;
				indexYPos[i] = POINTER_ARRAY_ELEM_Y + POINTER_ARRAY_ELEM_HEIGHT

				cmd("CreateLabel", nextID, i,indexXPos[i],indexYPos[i] );
				cmd("SetForegroundColor", nextID, INDEX_COLOR);
			}
			cmd("CreateLabel", ExplainLabel, "", 10, 25, 0);
			animationManager.StartNewAnimation(commands);
			animationManager.skipForward();
			animationManager.clearHistory();
			resetIndex  = nextIndex;
		}
		
		
		
		override function resetAll()
		{
			animationManager.resetAll();
			commands = new Array();
			nextIndex = 0;
			setup();
		}
				
		
		
		// NEED TO OVERRIDE IN PARENT
		override function reset()
		{
			for (var i:int = 0; i < table_size; i++)
			{
				hashTableValues[i] = null;
			}
			nextIndex = resetIndex ;
		}
		
		
		function resetCallback(event):void
		{

		}
		
		
		
		override function enableUI(event:AnimationStateEvent):void
		{
			super.enableUI(event);
		}
		override function disableUI(event:AnimationStateEvent):void
		{
			super.disableUI(event);
		}
	}
}