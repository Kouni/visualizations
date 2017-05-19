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



	public class HeapSort extends AlgorithmAnimation
	{

		
		var heapsortButton:Button;
		var randomizeButton:Button;
		
		static const ARRAY_SIZE:int  = 32;
		static const ARRAY_ELEM_WIDTH:int = 30;
		static const ARRAY_ELEM_HEIGHT:int = 25;
		static const ARRAY_INITIAL_X = 0;

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

		var oldData:Array;
		
		// Object IDs for labels, so we don't keep creating new ones ...
	    var swapLabel1:int;
	 	var swapLabel2:int;
		var swapLabel3:int;
		var swapLabel4:int;
		
		var descriptLabel1:int;
		var descriptLabel2:int;
		
		public function HeapSort(am)
		{
			super(am);

			commands = new Array();

			heapsortButton = new Button();
			heapsortButton.label = "Heap Sort";
			heapsortButton.x = 5;			
			addChild(heapsortButton);
			
			randomizeButton = new Button();
			randomizeButton.label = "Randomize List";
			randomizeButton.x = 110;
			addChild(randomizeButton);

			
			heapsortButton.addEventListener(MouseEvent.MOUSE_DOWN, heapsortCallback);

			randomizeButton.addEventListener(MouseEvent.MOUSE_DOWN, randomizeCallback);

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
			oldData = new Array(ARRAY_SIZE);
			currentHeapSize = 0;
			
			for (var i:int = 1; i < ARRAY_SIZE; i++)
			{
				arrayData[i] = Math.floor(1 + Math.random()*999);
				oldData[i] = arrayData[i];

				ArrayXPositions[i] = ARRAY_INITIAL_X + i *ARRAY_ELEM_WIDTH;
				arrayLabels[i] = nextIndex++;
				arrayRects[i] = nextIndex++;
				circleObjs[i] = nextIndex++;
				cmd("CreateRectangle", arrayRects[i], arrayData[i], ARRAY_ELEM_WIDTH, ARRAY_ELEM_HEIGHT, ArrayXPositions[i] , ARRAY_Y_POS)
				cmd("CreateLabel", arrayLabels[i], i - 1,  ArrayXPositions[i], ARRAY_LABEL_Y_POS);
				cmd("SetForegroundColor", arrayLabels[i], 0x0000FF);
			}
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
		

		
		function heapsortCallback(event)
		{
			commands = buildHeap("");
			for (var i:int = ARRAY_SIZE - 1; i > 1; i--)
			{
				swap(i, 1);
				cmd("SetAlpha", arrayRects[i], 0.2);
				cmd("Delete", circleObjs[i]);
				currentHeapSize = i-1;
				pushDown(1);
			}
			for (i = 1; i < ARRAY_SIZE; i++)
			{
				cmd("SetAlpha", arrayRects[i], 1);
			}
			cmd("Delete", circleObjs[1]);
			animationManager.StartNewAnimation(commands);			
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
		
		
		function randomizeCallback(ignored)
		{
			randomizeArray();
		}
				
		private function randomizeArray()
		{
			commands = new Array();
			for (var i:int = 1; i < ARRAY_SIZE; i++)
			{
				arrayData[i] = Math.floor(1 + Math.random()*999);
				cmd("SetText", arrayRects[i], arrayData[i]);
				oldData[i] = arrayData[i];
			}
			animationManager.StartNewAnimation(commands);
			animationManager.skipForward();
			animationManager.clearHistory();			
		}
		
		
		
		override function reset()
		{
			for (var i:int = 1; i < ARRAY_SIZE; i++)
			{

				arrayData[i]= oldData[i];
				cmd("SetText", arrayRects[i],arrayData[i]);
			}
			commands = new Array();
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
					if (arrayData[2*index + 1] > arrayData[2*index])
					{
						smallestIndex = 2*index + 1;
					}
				}
				setIndexHighlight(index, 1);
				setIndexHighlight(smallestIndex, 1);
				cmd("Step");
				setIndexHighlight(index, 0);
				setIndexHighlight(smallestIndex, 0);
				
				if (arrayData[smallestIndex] > arrayData[index])
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
				
		function buildHeap(ignored)
		{
			commands = new Array();
			for (var i:int = 1; i <ARRAY_SIZE; i++)
			{
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
		

		override function enableUI(event:AnimationStateEvent):void
		{
			heapsortButton.enabled = true;
			randomizeButton.enabled = true;
		}
		override function disableUI(event:AnimationStateEvent):void
		{
			heapsortButton.enabled = false;
			randomizeButton.enabled = false;
		}
	}
}