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



	public class Heap extends AlgorithmAnimation
	{

		
		var enterFieldInsert:TextInput;
		var insertButton:Button;
		var removeSmallestButton:Button;
		var clearButton:Button;
		var builtHeapButton:Button;
		
		static const ARRAY_SIZE:int  = 32;
		static const ARRAY_ELEM_WIDTH:int = 30;
		static const ARRAY_ELEM_HEIGHT:int = 25;
		static const ARRAY_INITIAL_X = 30;

		static const ARRAY_Y_POS = 80;
		static const ARRAY_LABEL_Y_POS = 100;

		


		var HeapXPositions = [0, 450, 250, 650, 150, 350, 550, 750, 100, 200, 300, 400, 500, 600,
							  700, 800, 075, 125, 175, 225, 275, 325, 375, 425, 475, 525, 575, 
							  625, 675, 725, 775, 825];
		var HeapYPositions = [0, 200, 270, 270, 340, 340, 340, 340, 410, 410, 410, 410, 410, 410,
							  410, 410, 480, 480, 480, 480, 480, 480, 480, 480, 480, 480, 480, 
							  480, 480, 480, 480, 480];
	
		var ArrayXPositions:Array;
		
		var nextIndex:int;
		
		var arrayData:Array;
		var arrayLabels:Array;
		var arrayRects:Array;
		var circleObjs:Array;
		var currentHeapSize:int;

		
		// Object IDs for labels, so we don't keep creating new ones ...
	    var swapLabel1:int;
	 	var swapLabel2:int;
		var swapLabel3:int;
		var swapLabel4:int;
		
		var descriptLabel1:int;
		var descriptLabel2:int;
		
		public function Heap(am)
		{
			super(am);

			commands = new Array();

			enterFieldInsert = addTextInput(2,2,100,20,true);
			insertButton = new Button();
			insertButton.label = "Insert";
			insertButton.x = 105;			
			addChild(insertButton);
			
			removeSmallestButton = new Button();
			removeSmallestButton.label = "Remove Smallest";
			removeSmallestButton.x = 210;
			addChild(removeSmallestButton);
			
			clearButton = new Button();
			clearButton.label = "Clear Heap";
			clearButton.x = 310;
			addChild(clearButton);

			builtHeapButton = new Button();
			builtHeapButton.label = "Build Heap";
			builtHeapButton.x = 410;
			addChild(builtHeapButton);

			
			insertButton.addEventListener(MouseEvent.MOUSE_DOWN, insertCallback);
			enterFieldInsert.addEventListener(ComponentEvent.ENTER, insertCallback);

			clearButton.addEventListener(MouseEvent.MOUSE_DOWN, clearCallback);
			removeSmallestButton.addEventListener(MouseEvent.MOUSE_DOWN, removeSmallestCallback);
			builtHeapButton.addEventListener(MouseEvent.MOUSE_DOWN, buildHeapCallback);

			nextIndex = 0;
			createArray();

		}
		
		private function createArray()
		{
			arrayData = new Array(ARRAY_SIZE);
			arrayLabels = new Array(ARRAY_SIZE);
			arrayRects = new Array(ARRAY_SIZE);
			circleObjs = new Array(ARRAY_SIZE);
			ArrayXPositions = new Array(ARRAY_SIZE);
			currentHeapSize = 0;
			
			for (var i:int = 0; i < ARRAY_SIZE; i++)
			{
				ArrayXPositions[i] = ARRAY_INITIAL_X + i *ARRAY_ELEM_WIDTH;
				arrayLabels[i] = nextIndex++;
				arrayRects[i] = nextIndex++;
				circleObjs[i] = nextIndex++;
				cmd("CreateRectangle", arrayRects[i], "", ARRAY_ELEM_WIDTH, ARRAY_ELEM_HEIGHT, ArrayXPositions[i] , ARRAY_Y_POS)
				cmd("CreateLabel", arrayLabels[i], i,  ArrayXPositions[i], ARRAY_LABEL_Y_POS);
				cmd("SetForegroundColor", arrayLabels[i], 0x0000FF);
			}
			cmd("SetText", arrayRects[0], "-INF");
			swapLabel1 = nextIndex++;
			swapLabel2 = nextIndex++;
			swapLabel3 = nextIndex++;
			swapLabel4 = nextIndex++;
			descriptLabel1 = nextIndex++;
			descriptLabel2 = nextIndex++;
			cmd("CreateLabel", descriptLabel1, "", 20, 40,  0);
			//cmd("CreateLabel", descriptLabel2, "", nextIndex, 40, 120, 0);
			animationManager.StartNewAnimation(commands);
			animationManager.skipForward();
			animationManager.clearHistory();
		}
		

		function insertCallback(event)
		{
			var insertedValue:String;

			insertedValue = normalizeNumber(enterFieldInsert.text, 4);
			if (insertedValue != "")
			{
				enterFieldInsert.text = "";
				implementAction(insertElement,insertedValue);
			}
		}
		
		function clearCallback(event)
		{
			clear();
		}
		
		function clear()
		{
			commands = new Array();
			
			while (currentHeapSize > 0)
			{
				cmd("Delete", circleObjs[currentHeapSize]);
				cmd("SetText", arrayRects[currentHeapSize], "");
				currentHeapSize--;				
			}			
			animationManager.StartNewAnimation(commands);
			animationManager.skipForward();
			animationManager.clearHistory();
			actionHistory = new Array();
		}
		
		
		override function reset()
		{
			currentHeapSize = 0;
		}
		
		function removeSmallestCallback(event)
		{
			implementAction(removeSmallest,"");
		}
		
		
		function swap(index1, index2)
		{
			cmd("SetText", arrayRects[index1], "");
			cmd("SetText", arrayRects[index2], "");
			cmd("SetText", circleObjs[index1], "");
			cmd("SetText", circleObjs[index2], "");
			cmd("CreateLabel", swapLabel1, arrayData[index1], ArrayXPositions[index1],ARRAY_Y_POS);
			cmd("CreateLabel", swapLabel2, arrayData[index2], ArrayXPositions[index2],ARRAY_Y_POS);
			cmd("CreateLabel", swapLabel3, arrayData[index1], HeapXPositions[index1],HeapYPositions[index1]);
			cmd("CreateLabel", swapLabel4, arrayData[index2], HeapXPositions[index2],HeapYPositions[index2]);
			cmd("Move", swapLabel1, ArrayXPositions[index2],ARRAY_Y_POS)
			cmd("Move", swapLabel2, ArrayXPositions[index1],ARRAY_Y_POS)
			cmd("Move", swapLabel3, HeapXPositions[index2],HeapYPositions[index2])
			cmd("Move", swapLabel4, HeapXPositions[index1],HeapYPositions[index1])
			var tmp = arrayData[index1];
			arrayData[index1] = arrayData[index2];
			arrayData[index2] = tmp;
			cmd("Step")
			cmd("SetText", arrayRects[index1], arrayData[index1]);
			cmd("SetText", arrayRects[index2], arrayData[index2]);
			cmd("SetText", circleObjs[index1], arrayData[index1]);
			cmd("SetText", circleObjs[index2], arrayData[index2]);
			cmd("Delete", swapLabel1);
			cmd("Delete", swapLabel2);
			cmd("Delete", swapLabel3);
			cmd("Delete", swapLabel4);			
			
			
		}
		
		
		function setIndexHighlight(index, highlightVal)
		{
			cmd("SetHighlight", circleObjs[index], highlightVal);
			cmd("SetHighlight", arrayRects[index], highlightVal);
		}
		
		function pushDown(index)
		{
			var smallestIndex:int;
			
			while(true)
			{
				if (index*2 > currentHeapSize)
				{
					return;
				}
				
				smallestIndex = 2*index;
	
				if (index*2 + 1 <= currentHeapSize)
				{
					setIndexHighlight(2*index, 1);
					setIndexHighlight(2*index + 1, 1);
					cmd("Step");
					setIndexHighlight(2*index, 0);
					setIndexHighlight(2*index + 1, 0);
					if (arrayData[2*index + 1] < arrayData[2*index])
					{
						smallestIndex = 2*index + 1;
					}
				}
				setIndexHighlight(index, 1);
				setIndexHighlight(smallestIndex, 1);
				cmd("Step");
				setIndexHighlight(index, 0);
				setIndexHighlight(smallestIndex, 0);
				
				if (arrayData[smallestIndex] < arrayData[index])
				{
					swap(smallestIndex, index);
					index = smallestIndex;
				}
				else
				{
					return;
				}
															  
															  
													
			}
		}
		
		function removeSmallest(dummy)
		{
			commands = new Array();
			cmd("SetText", descriptLabel1, "");
			
			if (currentHeapSize == 0)
			{
				cmd("SetText", descriptLabel1, "Heap is empty, cannot remove smallest element");
				return commands;
			}
			
			cmd("SetText", descriptLabel1, "Removing element:");			
			cmd("CreateLabel", descriptLabel2, arrayData[1],  HeapXPositions[1], HeapYPositions[1], 0);
			cmd("SetText", circleObjs[1], "");
			cmd("Move", descriptLabel2,  120, 40)
			cmd("Step");
			cmd("Delete", descriptLabel2);
			cmd("SetText", descriptLabel1, "Removing element: " + arrayData[1]);
			arrayData[1] = "";
			if (currentHeapSize > 1)
			{
				cmd("SetText", arrayRects[1], "");
				cmd("SetText", arrayRects[currentHeapSize], "");
				swap(1,currentHeapSize);
				cmd("Delete", circleObjs[currentHeapSize]);
				currentHeapSize--;
				pushDown(1);				
			}
			return commands;
			
		}
		
		function buildHeapCallback(event)
		{
			clear();
			implementAction(buildHeap,"");			
		}
		
		function buildHeap(ignored)
		{
			commands = new Array();
			for (var i:int = 1; i <ARRAY_SIZE; i++)
			{
				arrayData[i] = normalizeNumber(String(ARRAY_SIZE - i), 4);
				cmd("CreateCircle", circleObjs[i], arrayData[i], HeapXPositions[i], HeapYPositions[i]);
				cmd("SetText", arrayRects[i], arrayData[i]);
				if (i > 1)
				{
					cmd("Connect", circleObjs[Math.floor(i/2)], circleObjs[i]);
				}
																					 
			}
			cmd("Step");
			currentHeapSize = ARRAY_SIZE - 1;
			var nextElem:int = currentHeapSize;
			while(nextElem > 0)
			{
				pushDown(nextElem);
				nextElem = nextElem - 1;
			}
			return commands;
		}
		
		function insertElement(insertedValue)
		{
			commands = new Array();
			
			if (currentHeapSize >= ARRAY_SIZE - 1)
			{
				cmd("SetText", descriptLabel1, "Heap Full!");
				return commands;
			}
			
			cmd("SetText", descriptLabel1, "Inserting Element: " + insertedValue);	
			cmd("Step");
			cmd("SetText", descriptLabel1, "Inserting Element: ");
			currentHeapSize++;
			arrayData[currentHeapSize] = insertedValue;
			cmd("CreateCircle",circleObjs[currentHeapSize], "", HeapXPositions[currentHeapSize], HeapYPositions[currentHeapSize]);
			cmd("CreateLabel", descriptLabel2, insertedValue, 120, 45,  1);
			if (currentHeapSize > 1)
			{
				cmd("Connect", circleObjs[Math.floor(currentHeapSize / 2)], circleObjs[currentHeapSize]);				
			}

			cmd("Move", descriptLabel2, HeapXPositions[currentHeapSize], HeapYPositions[currentHeapSize]);
			cmd("Step");
			cmd("SetText", circleObjs[currentHeapSize], insertedValue);
			cmd("delete", descriptLabel2);
			cmd("SetText", arrayRects[currentHeapSize], insertedValue);
			
			var currentIndex:int = currentHeapSize;
			var parentIndex:int = currentIndex / 2;
			
			if (currentIndex > 1)
			{
				setIndexHighlight(currentIndex, 1);
				setIndexHighlight(parentIndex, 1);
				cmd("Step");
				setIndexHighlight(currentIndex, 0);
				setIndexHighlight(parentIndex, 0);
			}

			while (currentIndex > 1 && arrayData[currentIndex] < arrayData[parentIndex])
			{
				swap(currentIndex, parentIndex);
				currentIndex = parentIndex;
				parentIndex = parentIndex / 2;
				if (currentIndex > 1)
				{
					setIndexHighlight(currentIndex, 1);
					setIndexHighlight(parentIndex, 1);
					cmd("Step");
					setIndexHighlight(currentIndex, 0);
					setIndexHighlight(parentIndex, 0);
				}
			}
			cmd("SetText", descriptLabel1, "");	

			return commands;
		}
		
		override function enableUI(event:AnimationStateEvent):void
		{
			clearButton.enabled = true;
			insertButton.enabled = true;
			removeSmallestButton.enabled = true;
			builtHeapButton.enabled = true;
			enterFieldInsert.enabled = true;
			enterFieldInsert.addEventListener(ComponentEvent.ENTER, insertCallback);

		}
		override function disableUI(event:AnimationStateEvent):void
		{
			clearButton.enabled = false;
			insertButton.enabled = false;
			removeSmallestButton.enabled = false;
			builtHeapButton.enabled = false;
			enterFieldInsert.enabled = false;
			enterFieldInsert.removeEventListener(ComponentEvent.ENTER, insertCallback);
		}
	}
}