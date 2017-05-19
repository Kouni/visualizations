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



	public class ClosedHash2 extends Hash
	{

		// Input Controls			
		
		
		static const ARRAY_ELEM_WIDTH = 90;
		static const ARRAY_ELEM_HEIGHT = 30;
		static const ARRAY_ELEM_START_X = 50;
		static const ARRAY_ELEM_START_Y = 240;
		static const ARRAY_VERTICAL_SEPARATION = 100;
		static const ELEMENTS_PER_ROW = 10;
		
		static const BUCKET_SIZE = 3;
		static const NUM_BUCKETS = 11;
		static const CLOSED_HASH_TABLE_SIZE:int  = 40;

		static const ARRAY_Y_POS = 350;
			
		
		static const INDEX_COLOR = 0x0000FF;
		

		
		var empty:Array;
		var deleted:Array;		
		var skipDist:Array;
		
		var ExplainLabel:int;
		var resetIndex;
		
		var indexXPos2:Array;
		var indexYPos2:Array;
				
		public function ClosedHash2(am)
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

			var foundIndex = -1;
			for (var candidateIndex = index * BUCKET_SIZE; candidateIndex < index * BUCKET_SIZE + BUCKET_SIZE; candidateIndex++)
			{
				cmd("SetHighlight", hashTableVisual[candidateIndex], 1);
				cmd("Step");
				cmd("SetHighlight", hashTableVisual[candidateIndex], 0);
				if (empty[candidateIndex])
				{
					foundIndex = candidateIndex;
					break;
				}	
			}
			if (foundIndex == -1)
			{
				for (candidateIndex = BUCKET_SIZE * NUM_BUCKETS; candidateIndex < CLOSED_HASH_TABLE_SIZE; candidateIndex++)
				{
					cmd("SetHighlight", hashTableVisual[candidateIndex], 1);
					cmd("Step");
					cmd("SetHighlight", hashTableVisual[candidateIndex], 0);

					if (empty[candidateIndex])
					{
						foundIndex = candidateIndex;
						break;
					}					
					
				}
			}
			
			if (foundIndex != -1)
			{
				var labID = nextIndex++;
				cmd("CreateLabel", labID, elem, 20, 25);
				cmd("Move", labID, indexXPos2[foundIndex], indexYPos2[foundIndex] - ARRAY_ELEM_HEIGHT);
				cmd("Step");
				cmd("Delete", labID);
				cmd("SetText", hashTableVisual[foundIndex], elem);
				hashTableValues[foundIndex] = elem;
				empty[foundIndex] = false;
				deleted[foundIndex] = false;
			}
			
			
			cmd("SetText", ExplainLabel, "");

			return commands;

		}
	
	
		
		
		function getElemIndex(elem:String) : int
		{
			var foundIndex = -1;
			var initialIndex = doHash(elem);
			
			for (var candidateIndex = initialIndex * BUCKET_SIZE; candidateIndex < initialIndex* BUCKET_SIZE + BUCKET_SIZE; candidateIndex++)
			{
				cmd("SetHighlight", hashTableVisual[candidateIndex], 1);
				cmd("Step");
				cmd("SetHighlight", hashTableVisual[candidateIndex], 0);
				if (!empty[candidateIndex] && hashTableValues[candidateIndex] == elem)
				{
					return candidateIndex;		
				}
				else if (empty[candidateIndex] && !deleted[candidateIndex])
				{
					return -1;
				}
			}
			// Can only get this far if we didn't find the element we are looking for,
			//  *and* the bucekt was full -- look at overflow bucket.
			for (candidateIndex = BUCKET_SIZE * NUM_BUCKETS; candidateIndex < CLOSED_HASH_TABLE_SIZE; candidateIndex++)
			{
				cmd("SetHighlight", hashTableVisual[candidateIndex], 1);
				cmd("Step");
				cmd("SetHighlight", hashTableVisual[candidateIndex], 0);

				if (!empty[candidateIndex] && hashTableValues[candidateIndex] == elem)
				{
					return candidateIndex;		
				}
				else if (empty[candidateIndex] && !deleted[candidateIndex])
				{
					return -1;
				}
			}
			return -1;			
		}
		
		
		override function deleteElement(elem)
		{
			commands = new Array();
			cmd("SetText", ExplainLabel, "Deleting element: " + elem);
			var index = getElemIndex(elem);
			
			if (index == -1)
			{
				cmd("SetText", ExplainLabel, "Deleting element: " + elem + "  Element not in table");				
			}
			else
			{
				cmd("SetText", ExplainLabel, "Deleting element: " + elem + "  Element deleted");
				empty[index] = true;
				deleted[index] = true;
				cmd("SetText", hashTableVisual[index], "<deleted>");
			}
			
			return commands;
			
		}
		override function findElement(elem)
		{
			commands = new Array();
			cmd("SetText", ExplainLabel, "Finding Element: " + elem);
			var index = getElemIndex(elem);
			if (index == -1)
			{
				cmd("SetText", ExplainLabel, "Element " + elem + " not found");
			}
			else
			{
				cmd("SetText", ExplainLabel, "Element " + elem + " found");
			}
			return commands;
		}
		
		
		
		
		private function setup()
		{
			table_size = NUM_BUCKETS;
			hashTableVisual = new Array(CLOSED_HASH_TABLE_SIZE);
			hashTableIndices = new Array(CLOSED_HASH_TABLE_SIZE);
			hashTableValues = new Array(CLOSED_HASH_TABLE_SIZE);
			
			indexXPos = new Array(NUM_BUCKETS);
			indexYPos = new Array(NUM_BUCKETS);
			
			indexXPos2 = new Array(CLOSED_HASH_TABLE_SIZE);
			indexYPos2 = new Array(CLOSED_HASH_TABLE_SIZE);
			
			
			empty = new Array(CLOSED_HASH_TABLE_SIZE);
			deleted = new Array(CLOSED_HASH_TABLE_SIZE);
			
			ExplainLabel = nextIndex++;
			
			
			for (var i:int = 0; i < CLOSED_HASH_TABLE_SIZE; i++)
			{
				var nextID:int  = nextIndex++;
				empty[i] = true;
				deleted[i] = false;

				var nextXPos =  ARRAY_ELEM_START_X + (i % ELEMENTS_PER_ROW) * ARRAY_ELEM_WIDTH;
				var nextYPos =  ARRAY_ELEM_START_Y + Math.floor(i / ELEMENTS_PER_ROW) * ARRAY_VERTICAL_SEPARATION;
				cmd("CreateRectangle", nextID, "", ARRAY_ELEM_WIDTH, ARRAY_ELEM_HEIGHT,nextXPos, nextYPos)
				hashTableVisual[i] = nextID;
				nextID = nextIndex++;
				hashTableIndices[i] = nextID;
				indexXPos2[i] = nextXPos;
				indexYPos2[i] = nextYPos + ARRAY_ELEM_HEIGHT

				cmd("CreateLabel", nextID, i,indexXPos2[i],indexYPos2[i]);
				cmd("SetForegroundColor", nextID, INDEX_COLOR);
			}
			
			for (i = 0; i <= NUM_BUCKETS; i++)
			{
				nextID = nextIndex++;
				nextXPos =  ARRAY_ELEM_START_X + (i * 3 % ELEMENTS_PER_ROW) * ARRAY_ELEM_WIDTH - ARRAY_ELEM_WIDTH / 2;
				nextYPos =  ARRAY_ELEM_START_Y + Math.floor((i * 3) / ELEMENTS_PER_ROW) * ARRAY_VERTICAL_SEPARATION + ARRAY_ELEM_HEIGHT;
				cmd("CreateRectangle", nextID, "", 0, ARRAY_ELEM_HEIGHT * 2,nextXPos, nextYPos)
				nextID = nextIndex++;
				if (i == NUM_BUCKETS)
				{
					cmd("CreateLabel", nextID, "Overflow", nextXPos + 3, nextYPos + ARRAY_ELEM_HEIGHT / 2 , 0);
				}
				else
				{
					indexXPos[i] =  nextXPos + 5;
					indexYPos[i] = nextYPos + ARRAY_ELEM_HEIGHT / 2;
					cmd("CreateLabel", nextID, i, indexXPos[i],indexYPos[i], 0);					
				}
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
			// TODO:  NEED TO CHANGE HERE
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