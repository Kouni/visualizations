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
	import fl.controls.RadioButton;
	import fl.controls.RadioButtonGroup;
	import flash.events.Event;



	public class ClosedHash extends Hash
	{

		// Input Controls			
		
		
		
		static const ARRAY_ELEM_WIDTH = 90;
		static const ARRAY_ELEM_HEIGHT = 30;
		static const ARRAY_ELEM_START_X = 50;
		static const ARRAY_ELEM_START_Y = 250;
		static const ARRAY_VERTICAL_SEPARATION = 100;
		static const ELEMENTS_PER_ROW = 10;
				
		static const CLOSED_HASH_TABLE_SIZE:int  = 29;

		static const ARRAY_Y_POS = 350;
			
		
		static const INDEX_COLOR = 0x0000FF;
		
		
		var ExplainLabel:int;
		var resetIndex;
		var empty:Array;
		var deleted:Array;
		
		var skipDist:Array;
		
		var linearProbingButton:RadioButton;
		var quadradicProbingButton:RadioButton;
		var doubleHashingButton:RadioButton;
		var probingTypeGroup:RadioButtonGroup;
		


var rbg1:RadioButtonGroup = new RadioButtonGroup("group1");
		
		var currentHashingTypeButtonState:RadioButton;
		public function ClosedHash(am)
		{
			super(am);
			
			
			probingTypeGroup = new RadioButtonGroup("ProbingType");


			linearProbingButton = new RadioButton();
			linearProbingButton.x = 725;
			linearProbingButton.label = "Linear Probing: f(i) = i"
			linearProbingButton.width = 250;
			linearProbingButton.selected = true;
			currentHashingTypeButtonState = linearProbingButton;
			linearProbingButton.addEventListener(Event.CHANGE, probingTypeChangedHandler);
			linearProbingButton.group = probingTypeGroup;
			
			quadradicProbingButton = new RadioButton();
			quadradicProbingButton.x = 725;
			quadradicProbingButton.y = 20;
			quadradicProbingButton.label = "Quadratic Probing: f(i) = i * i";
			quadradicProbingButton.width = 250;
			quadradicProbingButton.addEventListener(Event.CHANGE, probingTypeChangedHandler);
			quadradicProbingButton.group = probingTypeGroup;
			
			doubleHashingButton = new RadioButton();	
			doubleHashingButton.x = 725;
			doubleHashingButton.y = 40;
			doubleHashingButton.label = "Double Hashing: f(i) = i * hash2(elem)"
			doubleHashingButton.width = 250;
			doubleHashingButton.addEventListener(Event.CHANGE, probingTypeChangedHandler);
			doubleHashingButton.group = probingTypeGroup;			
			
			
	
			addChild(linearProbingButton);
			addChild(quadradicProbingButton);
			addChild(doubleHashingButton);
	
				
			setup();
	
			restrictToInegers();
		}
		
				
		private function probingTypeChangedHandler(event:Event):void 
		{
			if ( event.currentTarget.selected )
			{
				
				if (event.currentTarget == linearProbingButton && currentHashingTypeButtonState != linearProbingButton)
				{
					currentHashingTypeButtonState = linearProbingButton;
					resetAll();
					for (var i:int = 0; i < table_size; i++)
					{
						skipDist[i] = i;
					}
				}
				else if (event.currentTarget == quadradicProbingButton && currentHashingTypeButtonState != quadradicProbingButton)
				{
					currentHashingTypeButtonState = quadradicProbingButton;
					resetAll();
					for (i = 0; i < table_size; i++)
					{
						skipDist[i] = i * i;
					}
				}
				else if (event.currentTarget == doubleHashingButton && currentHashingTypeButtonState != doubleHashingButton)
				{
					currentHashingTypeButtonState = doubleHashingButton;
					resetAll();
					
				}
				else
				{
					// ERROR!
				}
			}
		}


		
		override function insertElement(elem)
		{
			commands = new Array();
			cmd("SetText", ExplainLabel, "Inserting element: " + String(elem));
			var index = doHash(elem);

			index = getEmptyIndex(index, elem);
			cmd("SetText", ExplainLabel, "");
			if (index != -1)
			{
				var labID = nextIndex++;
				cmd("CreateLabel", labID, elem, 20, 25);
				cmd("Move", labID, indexXPos[index], indexYPos[index] - ARRAY_ELEM_HEIGHT);
				cmd("Step");
				cmd("Delete", labID);
				cmd("SetText", hashTableVisual[index], elem);
				hashTableValues[index] = elem;
				empty[index] = false;
				deleted[index] = false;
			}
			return commands;

		}
		
		
		function resetSkipDist(elem, labelID)
		{
			var skipVal:int = 7 - (currHash % 7);
			cmd("CreateLabel", labelID, "hash2("+String(elem) +") = 1 - " + String(currHash)  +" % 7 = " + String(skipVal),  20, 45, 0);
			skipDist[0] = 0;
			for (var i = 1; i < table_size; i++)
			{
				skipDist[i] = skipDist[i-1] + skipVal;				
			}
			
			
		}
		
		function getEmptyIndex(index, elem) :int
		{
			if (currentHashingTypeButtonState == doubleHashingButton)
			{
				resetSkipDist(elem, nextIndex++);				
			}
			var foundIndex:int = -1;
			for (var i:int  = 0; i < table_size; i++)
			{
				var candidateIndex :int  = (index + skipDist[i]) % table_size;
				cmd("SetHighlight", hashTableVisual[candidateIndex], 1);
				cmd("Step");
				cmd("SetHighlight", hashTableVisual[candidateIndex], 0);
				if (empty[candidateIndex])
				{
					foundIndex = candidateIndex;
					break;
				}				
			}
			if (currentHashingTypeButtonState == doubleHashingButton)
			{
				cmd("Delete", --nextIndex);
			}
			return foundIndex;
		}
		
		function getElemIndex(index, elem) : int
		{
			if (currentHashingTypeButtonState == doubleHashingButton)
			{
				resetSkipDist(elem, nextIndex++);				
			}
			var foundIndex:int = -1;
			for (var i:int  = 0; i < table_size; i++)
			{
				var candidateIndex :int  = (index + skipDist[i]) % table_size;
				cmd("SetHighlight", hashTableVisual[candidateIndex], 1);
				cmd("Step");
				cmd("SetHighlight", hashTableVisual[candidateIndex], 0);
				if (!empty[candidateIndex] && hashTableValues[candidateIndex] == elem)
				{
					foundIndex= candidateIndex;
					break;
				}
				else if (empty[candidateIndex] && !deleted[candidateIndex])
				{
					break;				}
			}
			if (currentHashingTypeButtonState == doubleHashingButton)
			{
				cmd("Delete", --nextIndex);
			}
			return foundIndex;
		}
		
		override function deleteElement(elem)
		{
			commands = new Array();
			cmd("SetText", ExplainLabel, "Deleting element: " + elem);
			var index = doHash(elem);
			
			index = getElemIndex(index, elem);
				
			if (index > 0)
			{
				cmd("SetText", ExplainLabel, "Deleting element: " + elem + "  Element deleted");
				empty[index] = true;
				deleted[index] = true;
				cmd("SetText", hashTableVisual[index], "<deleted>");
			}
			else 
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

			var found:Boolean = getElemIndex(index, elem) != -1;
			if (found)
			{
				cmd("SetText", ExplainLabel, "Finding Element: " + elem+ "  Found!")				
			}
			else
			{
				cmd("SetText", ExplainLabel, "Finding Element: " + elem+ "  Not Found!")

			}
			return commands;
		}
		
		
		
		
		private function setup()
		{
			skipDist = new Array(table_size);
			table_size = CLOSED_HASH_TABLE_SIZE;
			hashTableVisual = new Array(table_size);
			hashTableIndices = new Array(table_size);
			hashTableValues = new Array(table_size);
			
			indexXPos = new Array(table_size);
			indexYPos = new Array(table_size);
			
			empty = new Array(table_size);
			deleted = new Array(table_size);
			
			ExplainLabel = nextIndex++;
			
			
			for (var i:int = 0; i < table_size; i++)
			{
				skipDist[i] = i; // Start with linear probing
				var nextID:int  = nextIndex++;
				empty[i] = true;
				deleted[i] = false;

				var nextXPos =  ARRAY_ELEM_START_X + (i % ELEMENTS_PER_ROW) * ARRAY_ELEM_WIDTH;
				var nextYPos =  ARRAY_ELEM_START_Y + Math.floor(i / ELEMENTS_PER_ROW) * ARRAY_VERTICAL_SEPARATION;
				cmd("CreateRectangle", nextID, "", ARRAY_ELEM_WIDTH, ARRAY_ELEM_HEIGHT,nextXPos, nextYPos)
				hashTableVisual[i] = nextID;
				nextID = nextIndex++;
				hashTableIndices[i] = nextID;
				indexXPos[i] = nextXPos;
				indexYPos[i] = nextYPos + ARRAY_ELEM_HEIGHT

				cmd("CreateLabel", nextID, i,indexXPos[i],indexYPos[i]);
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
				empty[i]= true;
				deleted[i] = false;				
			}
			nextIndex = resetIndex ;
		}
		
		
		function resetCallback(event):void
		{

		}
		
		
		
		override function enableUI(event:AnimationStateEvent):void
		{
			super.enableUI(event);
			linearProbingButton.enabled = true;
			quadradicProbingButton.enabled = true;
			doubleHashingButton.enabled = true;
		}
		override function disableUI(event:AnimationStateEvent):void
		{
			super.disableUI(event);
			linearProbingButton.enabled = false;
			quadradicProbingButton.enabled = false;
			doubleHashingButton.enabled = false;
		}
	}
}