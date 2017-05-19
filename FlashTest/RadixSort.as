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



	public class RadixSort extends AlgorithmAnimation
	{

		// Input Controls
		var resetButton:Button;
		var radixSortButton:Button;
		
		static const COUNTER_ARRAY_SIZE = 10;
		static const ARRAY_SIZE  = 30;

		
		static const ARRAY_ELEM_WIDTH = 30;
		static const ARRAY_ELEM_HEIGHT = 30;
		static const ARRAY_ELEM_START_X = 20;
		static const ARRAY_ELEM_Y = 100;
		
		
		
		static const COUNTER_ARRAY_ELEM_WIDTH = 30;
		static const COUNTER_ARRAY_ELEM_HEIGHT = 30;
		static const COUNTER_ARRAY_ELEM_START_X = (ARRAY_ELEM_WIDTH * ARRAY_SIZE- COUNTER_ARRAY_ELEM_WIDTH * COUNTER_ARRAY_SIZE) / 2 + ARRAY_ELEM_START_X;
		static const COUNTER_ARRAY_ELEM_Y = 250;
		
		static const SWAP_ARRAY_ELEM_Y = 500
		
		static const NUM_DIGITS:int = 3;
		
		
		static const MAX_DATA_VALUE = Math.pow(10,NUM_DIGITS) - 1;

		var nextIndex = 0;
			
		
		
		var arrayData:Array;
		var arrayRects:Array;
		var arrayIndices:Array;
		
		var counterData:Array;
		var counterRects:Array;
		var counterIndices:Array;
		
		var swapData:Array;
		var swapRects:Array;
		var swapIndices:Array;
		
		
		public function RadixSort(am)
		{
			super(am);

			commands = new Array();

			resetButton = new Button();
			resetButton.label = "Randomize List";
			resetButton.x = 10;
			addChild(resetButton);

			radixSortButton = new Button();
			radixSortButton.label = "Radix Sort";
			radixSortButton.x = 110;
			addChild(radixSortButton);



			resetButton.addEventListener(MouseEvent.MOUSE_DOWN, resetCallback);
			radixSortButton.addEventListener(MouseEvent.MOUSE_DOWN, radixSortCallback);
			
			setup();

		}
		
		private function setup()
		{
			arrayData = new Array(ARRAY_SIZE);
			arrayRects= new Array(ARRAY_SIZE);
			arrayIndices = new Array(ARRAY_SIZE);
			
			
			counterData = new Array(COUNTER_ARRAY_SIZE);
			counterRects= new Array(COUNTER_ARRAY_SIZE);
			counterIndices = new Array(COUNTER_ARRAY_SIZE);

			swapData = new Array(ARRAY_SIZE);
			swapRects= new Array(ARRAY_SIZE);
			swapIndices = new Array(ARRAY_SIZE);					
			
			commands = new Array();
			
			for (var i:int = 0; i < ARRAY_SIZE; i++)
			{
				var nextID = nextIndex++;
				arrayData[i] = Math.floor(Math.random()*MAX_DATA_VALUE);
				cmd("CreateRectangle", nextID, arrayData[i], ARRAY_ELEM_WIDTH, ARRAY_ELEM_HEIGHT, ARRAY_ELEM_START_X + i *ARRAY_ELEM_WIDTH, ARRAY_ELEM_Y)
				arrayRects[i] = nextID;
				nextID = nextIndex++;
				arrayIndices[i] = nextID;
				cmd("CreateLabel",nextID,  i,  ARRAY_ELEM_START_X + i *ARRAY_ELEM_WIDTH, ARRAY_ELEM_Y + ARRAY_ELEM_HEIGHT);
				cmd("SetForegroundColor", nextID, 0x0000FF);
				
				nextID = nextIndex++;
				cmd("CreateRectangle", nextID, "", ARRAY_ELEM_WIDTH, ARRAY_ELEM_HEIGHT, ARRAY_ELEM_START_X + i *ARRAY_ELEM_WIDTH, SWAP_ARRAY_ELEM_Y)
				swapRects[i] = nextID;
				nextID = nextIndex++;
				swapIndices[i] = nextID;
				cmd("CreateLabel",nextID,  i,  ARRAY_ELEM_START_X + i *ARRAY_ELEM_WIDTH, SWAP_ARRAY_ELEM_Y + ARRAY_ELEM_HEIGHT);
				cmd("SetForegroundColor", nextID, 0x0000FF);
				
			}
			for (i = COUNTER_ARRAY_SIZE - 1; i >= 0; i--)
			{
				nextID = nextIndex++;
				cmd("CreateRectangle", nextID,"", COUNTER_ARRAY_ELEM_WIDTH, COUNTER_ARRAY_ELEM_HEIGHT, COUNTER_ARRAY_ELEM_START_X + i *COUNTER_ARRAY_ELEM_WIDTH, COUNTER_ARRAY_ELEM_Y)
				counterRects[i] = nextID;
				nextID = nextIndex++;
				counterIndices[i] = nextID;
				cmd("CreateLabel",nextID,  i,  COUNTER_ARRAY_ELEM_START_X + i *COUNTER_ARRAY_ELEM_WIDTH, COUNTER_ARRAY_ELEM_Y + COUNTER_ARRAY_ELEM_HEIGHT);
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
		
		function radixSortCallback(event)
		{
			commands = new Array();
			var animatedCircleID:int = nextIndex++;
			var animatedCircleID2:int = nextIndex++;
			var animatedCircleID3:int = nextIndex++;
			var animatedCircleID4:int = nextIndex++;
			
			var digits:Array = new Array(NUM_DIGITS);
			for (var k:int = 0; k < NUM_DIGITS; k++)
			{
				digits[k] = nextIndex++;
			}

			
			for (var radix:int = 0;  radix < NUM_DIGITS; radix++)
			{
				for (var i:int = 0; i < COUNTER_ARRAY_SIZE; i++)
				{
					counterData[i] = 0;
					cmd("SetText", counterRects[i], 0);
				}
				for (i = 0; i < ARRAY_SIZE; i++)
				{
					cmd("CreateHighlightCircle", animatedCircleID, 0x0000FF,  ARRAY_ELEM_START_X + i *ARRAY_ELEM_WIDTH, ARRAY_ELEM_Y);
					cmd("CreateHighlightCircle", animatedCircleID2, 0x0000FF,  ARRAY_ELEM_START_X + i *ARRAY_ELEM_WIDTH, ARRAY_ELEM_Y);
					
					
					cmd("SetText", arrayRects[i], "");
					
					for (k = 0; k < NUM_DIGITS; k++)
					{
						var digitXPos = ARRAY_ELEM_START_X + i *ARRAY_ELEM_WIDTH - ARRAY_ELEM_WIDTH/2 + (NUM_DIGITS - k ) * (ARRAY_ELEM_WIDTH / NUM_DIGITS - 3);
						var digitYPos = ARRAY_ELEM_Y;
						cmd("CreateLabel", digits[k], Math.floor(arrayData[i] / Math.pow(10,k)) % 10, digitXPos, digitYPos);
						if (k != radix)
						{
							cmd("SetAlpha", digits[k], 0.2);
						}
//						else
//						{
//							cmd("SetAlpha", digits[k], 0.2);							
//						}
					}
					
					
					var index = Math.floor(arrayData[i] / Math.pow(10,radix)) % 10;
					cmd("Move", animatedCircleID,  COUNTER_ARRAY_ELEM_START_X + index *COUNTER_ARRAY_ELEM_WIDTH, COUNTER_ARRAY_ELEM_Y + COUNTER_ARRAY_ELEM_HEIGHT)
					cmd("Step");
					counterData[index]++;
					cmd("SetText", counterRects[index], counterData[index]);
					cmd("Step");
					// cmd("SetAlpha", arrayRects[i], 0.2);
					cmd("Delete", animatedCircleID);
					cmd("Delete", animatedCircleID2);
					cmd("SetText", arrayRects[i], arrayData[i]);
					for (k = 0; k < NUM_DIGITS; k++)
					{
						cmd("Delete", digits[k]);
					}
				}
				for (i=1; i < COUNTER_ARRAY_SIZE; i++)
				{
					cmd("SetHighlight", counterRects[i-1], 1);
					cmd("SetHighlight", counterRects[i], 1);
					cmd("Step")
					counterData[i] = counterData[i] + counterData[i-1];
					cmd("SetText", counterRects[i], counterData[i]);
					cmd("Step")
					cmd("SetHighlight", counterRects[i-1], 0);
					cmd("SetHighlight", counterRects[i], 0);
				}
//				for (i=ARRAY_SIZE - 1; i >= 0; i--)
//				{
//					cmd("SetAlpha", arrayRects[i], 1.0);
//				}
				for (i=ARRAY_SIZE - 1; i >= 0; i--)
				{
					cmd("CreateHighlightCircle", animatedCircleID, 0x0000FF,  ARRAY_ELEM_START_X + i *ARRAY_ELEM_WIDTH, ARRAY_ELEM_Y);
					cmd("CreateHighlightCircle", animatedCircleID2, 0x0000FF,  ARRAY_ELEM_START_X + i *ARRAY_ELEM_WIDTH, ARRAY_ELEM_Y);
					
					
					cmd("SetText", arrayRects[i], "");
					
					for (k = 0; k < NUM_DIGITS; k++)
					{
						digits[k] = nextIndex++;
						digitXPos = ARRAY_ELEM_START_X + i *ARRAY_ELEM_WIDTH - ARRAY_ELEM_WIDTH/2 + (NUM_DIGITS - k ) * (ARRAY_ELEM_WIDTH / NUM_DIGITS - 3);
						digitYPos = ARRAY_ELEM_Y;
						cmd("CreateLabel", digits[k], Math.floor(arrayData[i] / Math.pow(10,k)) % 10, digitXPos, digitYPos);
						if (k != radix)
						{
							cmd("SetAlpha", digits[k], 0.2);
						}
					}
					
					
					
					
					index = Math.floor(arrayData[i] / Math.pow(10,radix)) % 10;
					cmd("Move", animatedCircleID2,  COUNTER_ARRAY_ELEM_START_X + index *COUNTER_ARRAY_ELEM_WIDTH, COUNTER_ARRAY_ELEM_Y + COUNTER_ARRAY_ELEM_HEIGHT)
					cmd("Step");
	
					var insertIndex = --counterData[index];
					cmd("SetText", counterRects[index], counterData[index]);
					cmd("Step");
					
					
					cmd("CreateHighlightCircle", animatedCircleID3, 0xAAAAFF,  COUNTER_ARRAY_ELEM_START_X + index *COUNTER_ARRAY_ELEM_WIDTH, COUNTER_ARRAY_ELEM_Y);
					cmd("CreateHighlightCircle", animatedCircleID4, 0xAAAAFF,  COUNTER_ARRAY_ELEM_START_X + index *COUNTER_ARRAY_ELEM_WIDTH, COUNTER_ARRAY_ELEM_Y);
					
					cmd("Move", animatedCircleID4,  ARRAY_ELEM_START_X + insertIndex * ARRAY_ELEM_WIDTH, SWAP_ARRAY_ELEM_Y + COUNTER_ARRAY_ELEM_HEIGHT)
					cmd("Step");
	
					var moveLabel:int = nextIndex++;
					cmd("SetText", arrayRects[i], "");
					cmd("CreateLabel", moveLabel, arrayData[i], ARRAY_ELEM_START_X + i *ARRAY_ELEM_WIDTH, ARRAY_ELEM_Y);
					cmd("Move", moveLabel, ARRAY_ELEM_START_X + insertIndex *ARRAY_ELEM_WIDTH, SWAP_ARRAY_ELEM_Y);
					swapData[insertIndex] = arrayData[i];
															
					for (k = 0; k < NUM_DIGITS; k++)
					{
						cmd("Delete", digits[k]);
					}
					cmd("Step");
					cmd("Delete", moveLabel);
					nextIndex--;  // Reuse index from moveLabel, now that it has been removed.
					cmd("SetText", swapRects[insertIndex], swapData[insertIndex]);
					cmd("Delete", animatedCircleID);
					cmd("Delete", animatedCircleID2);
					cmd("Delete", animatedCircleID3);
					cmd("Delete", animatedCircleID4);
	
				}
				for (i= 0; i < ARRAY_SIZE; i++)
				{
					cmd("SetText", arrayRects[i], "");
				}
				
				for (i= 0; i < COUNTER_ARRAY_SIZE; i++)
				{
					cmd("SetAlpha", counterRects[i], 0.05);
					cmd("SetAlpha", counterIndices[i], 0.05);
				}
	
				cmd("Step");
				var startLab = nextIndex;
				for (i = 0; i < ARRAY_SIZE; i++)
				{
					cmd("CreateLabel", startLab+i, swapData[i], ARRAY_ELEM_START_X + i *ARRAY_ELEM_WIDTH, SWAP_ARRAY_ELEM_Y);
					cmd("Move", startLab+i,  ARRAY_ELEM_START_X + i *ARRAY_ELEM_WIDTH, ARRAY_ELEM_Y);
					cmd("SetText", swapRects[i], "");
	
				}
				cmd("Step");
				for (i = 0; i < ARRAY_SIZE; i++)
				{				
					arrayData[i] = swapData[i];
					cmd("SetText", arrayRects[i], arrayData[i]);
					cmd("Delete", startLab + i);
				}
				for (i= 0; i < COUNTER_ARRAY_SIZE; i++)
				{
					cmd("SetAlpha", counterRects[i], 1);
					cmd("SetAlpha", counterIndices[i], 1);
				}
			}
			animationManager.StartNewAnimation(commands);

		}
		
		private function randomizeArray()
		{
			commands = new Array();
			for (var i:int = 0; i < ARRAY_SIZE; i++)
			{
				arrayData[i] = Math.floor(1 + Math.random()*MAX_DATA_VALUE);
				cmd("SetText", arrayRects[i], arrayData[i]);
			}
			
			for (i = 0; i < COUNTER_ARRAY_SIZE; i++)
			{
				cmd("SetText", counterRects[i], "");
			}
			
			
			animationManager.StartNewAnimation(commands);
			animationManager.skipForward();
			animationManager.clearHistory();
			
		}
		
		
		
		// We want to (mostly) ignore resets, since we are disallowing undoing 
		override function reset()
		{
			commands = new Array();
		}
		
		
		function resetCallback(event):void
		{
			randomizeArray();
		}
		
		
		
		override function enableUI(event:AnimationStateEvent):void
		{
			resetButton.enabled = true;
			radixSortButton.enabled = true;
		}
		override function disableUI(event:AnimationStateEvent):void
		{
			resetButton.enabled = false;
			radixSortButton.enabled = false;
		}
	}
}