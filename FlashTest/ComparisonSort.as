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



	public class ComparisonSort extends AlgorithmAnimation
	{

		// Input Controls
		var resetButton:Button;
		var insertSortButton:Button;
		var selectSortButton:Button;
		var bubbleSortButton:Button;
		var quickSortButton:Button;
		var mergeSortButton:Button;
		var shellSortButton:Button;
		var sizeButton:Button;
		
		static const ARRAY_SIZE_SMALL:int  = 50;
		static const ARRAY_WIDTH_SMALL:int = 17;
		static const ARRAY_BAR_WIDTH_SMALL:int = 10;
		static const ARRAY_INITIAL_X_SMALL = 15;

		static const ARRAY_Y_POS = 250;
		static const ARRAY_LABEL_Y_POS = 260;

		static const LOWER_ARRAY_Y_POS = 500;
		static const LOWER_ARRAY_LABEL_Y_POS = 510;

		
		
		static const ARRAY_SIZE_LARGE:int = 200;
		static const ARRAY_WIDTH_LARGE:int = 4;
		static const ARRAY_BAR_WIDTH_LARGE:int = 2;
		static const ARRAY_INITIAL_X_LARGE = 15;
		
		static const BAR_FOREGROUND_COLOR = 0x0000FF;
		static const BAR_BACKGROUND_COLOR = 0xAAAAFF;
		static const INDEX_COLOR = 0x0000FF;
		static const HIGHLIGHT_BAR_COLOR = 0xFF0000;
		static const QUICKSORT_LINE_COLOR = 0xFF0000;
		
		var array_size:int;
		var array_width:int;
		var array_bar_width:int;
		var array_initial_x:int;
		var array_y_pos:int;
		var array_label_y_pos:int;
		var showLabels:Boolean;
		
		var currentArraySize:int;
		
		
		var nextIndex:int;
		var oldData:Array;
		
		var arrayData:Array;
		var arraySwap:Array;
		var labelsSwap:Array;
		var objectsSwap:Array;
		var barObjects:Array;
		var barLabels:Array;
		
		var oldBarObjects:Array;
		var oldBarLabels:Array;
		
		var barPositionsX:Array;
		var obscureObject:Array;
		var iID:int;
		var jID:int;
		
		var lastCreatedIndex:int;

		public function ComparisonSort(am)
		{
			super(am);

			commands = new Array();

			resetButton = new Button();
			resetButton.label = "Randomize List";
			resetButton.x = 10;
			addChild(resetButton);

			insertSortButton = new Button();
			insertSortButton.label = "Insertion Sort";
			insertSortButton.x = 110;
			addChild(insertSortButton);

			selectSortButton = new Button();
			selectSortButton.label = "Selection Sort";
			selectSortButton.x = 210;
			addChild(selectSortButton);

			bubbleSortButton = new Button();
			bubbleSortButton.label = "Bubble Sort";
			bubbleSortButton.x = 310;
			addChild(bubbleSortButton);

			quickSortButton = new Button();
			quickSortButton.label = "Qucksort";
			quickSortButton.x = 410;
			addChild(quickSortButton);

			mergeSortButton = new Button();
			mergeSortButton.label = "Mergesort";
			mergeSortButton.x = 510;
			addChild(mergeSortButton);

			shellSortButton = new Button();
			shellSortButton.label = "Shell Sort";
			shellSortButton.x = 610;
			addChild(shellSortButton);
			
			sizeButton = new Button();
			sizeButton.label = "Change Size";
			sizeButton.x = 710;
			addChild(sizeButton);


			resetButton.addEventListener(MouseEvent.MOUSE_DOWN, resetCallback);
			insertSortButton.addEventListener(MouseEvent.MOUSE_DOWN, insertSortCallback);
			selectSortButton.addEventListener(MouseEvent.MOUSE_DOWN, selectSortCallback);
			bubbleSortButton.addEventListener(MouseEvent.MOUSE_DOWN, bubbleSortCallback);
			quickSortButton.addEventListener(MouseEvent.MOUSE_DOWN, quickSortCallback);
			mergeSortButton.addEventListener(MouseEvent.MOUSE_DOWN, mergeSortCallback);
			shellSortButton.addEventListener(MouseEvent.MOUSE_DOWN, shellSortCallback);
			sizeButton.addEventListener(MouseEvent.MOUSE_DOWN, changeSizeCallback);

			nextIndex = 0;
			setArraySize(true);
			arrayData = new Array(ARRAY_SIZE_LARGE);
			arraySwap = new Array(ARRAY_SIZE_LARGE);
			labelsSwap = new Array(ARRAY_SIZE_LARGE);
			objectsSwap = new Array(ARRAY_SIZE_LARGE);
			createVisualObjects();
			obscureObject = new Array(ARRAY_SIZE_LARGE);
		}
		
		
		private function setArraySize(small:Boolean)
		{
			if (small)
			{
				array_size = ARRAY_SIZE_SMALL;
				array_width = ARRAY_WIDTH_SMALL;
				array_bar_width = ARRAY_BAR_WIDTH_SMALL;
				array_initial_x = ARRAY_INITIAL_X_SMALL;
				array_y_pos = ARRAY_Y_POS;
				array_label_y_pos = ARRAY_LABEL_Y_POS;
				showLabels = true;
			}
			else
			{
				array_size = ARRAY_SIZE_LARGE;
				array_width = ARRAY_WIDTH_LARGE;
				array_bar_width = ARRAY_BAR_WIDTH_LARGE;
				array_initial_x = ARRAY_INITIAL_X_LARGE;
				array_y_pos = ARRAY_Y_POS;
				array_label_y_pos = ARRAY_LABEL_Y_POS;
				showLabels = false;
			}
			
		}
		
		
		private function resetAll(small)
		{
			animationManager.resetAll();
			setArraySize(!small);
			nextIndex = 0;
			createVisualObjects();
		}
		
		
		private function randomizeArray()
		{
			commands = new Array();
			for (var i:int = 0; i < array_size; i++)
			{
				arrayData[i] = Math.floor(1 + Math.random()*99);
				oldData[i] = arrayData[i];
				if (showLabels)
				{
					cmd("SetText", barLabels[i], arrayData[i]);
				}
				else
				{
					cmd("SetText", barLabels[i], "");					
				}
				cmd("SetHeight", barObjects[i], arrayData[i] * 2);				
			}
			animationManager.StartNewAnimation(commands);
			animationManager.skipForward();
			animationManager.clearHistory();
			
		}
		
		
		private function swap(index1, index2)
		{
			var tmp:int = arrayData[index1];
			arrayData[index1] = arrayData[index2];
			arrayData[index2] = tmp;
			
			tmp = barObjects[index1];
			barObjects[index1] = barObjects[index2];
			barObjects[index2] = tmp;

			tmp = barLabels[index1];
			barLabels[index1] = barLabels[index2];
			barLabels[index2] = tmp;
			
			
			cmd("Move", barObjects[index1], barPositionsX[index1], array_y_pos);
			cmd("Move", barObjects[index2], barPositionsX[index2], array_y_pos);
			cmd("Move", barLabels[index1], barPositionsX[index1], array_label_y_pos);
			cmd("Move", barLabels[index2], barPositionsX[index2], array_label_y_pos);
			cmd("Step");
		}
		
		
		private function createVisualObjects()
		{
			barObjects = new Array(array_size);
			oldBarObjects= new Array(array_size);
			oldBarLabels= new Array(array_size);

			barLabels = new Array(array_size);
			barPositionsX = new Array(array_size);			
			oldData = new Array(array_size);
			obscureObject  = new Array(array_size);

			
			var xPos:int = array_initial_x;
			var yPos:int = array_y_pos;
			var yLabelPos = array_label_y_pos;
			
		 	commands = new Array();
			for (var i:int = 0; i < array_size; i++)
			{
				xPos = xPos + array_width;
				barPositionsX[i] = xPos;
				cmd("CreateRectangle", nextIndex, "", array_bar_width, 200, xPos, yPos,"center","bottom");
				cmd("SetForegroundColor", nextIndex, BAR_FOREGROUND_COLOR);
				cmd("SetBackgroundColor", nextIndex, BAR_BACKGROUND_COLOR);
				barObjects[i] = nextIndex;
				oldBarObjects[i] = barObjects[i];
				nextIndex += 1;
				if (showLabels)
				{
					cmd("CreateLabel", nextIndex, "99", xPos, yLabelPos);
				}
				else
				{
				    cmd("CreateLabel", nextIndex, "", xPos, yLabelPos);
				}
				cmd("SetForegroundColor", nextIndex, INDEX_COLOR);
				
				barLabels[i] = nextIndex;
				oldBarLabels[i] = barLabels[i];
				++nextIndex;				
			}
			animationManager.StartNewAnimation(commands);
			animationManager.skipForward();
			randomizeArray();
			for (i = 0; i < array_size; i++)
			{
				obscureObject[i] = false;
			}
			lastCreatedIndex = nextIndex;
		}
	
		function highlightRange(lowIndex:int, highIndex:int):void
		{
			for (var i:int = 0; i < lowIndex; i++)
			{
				if (!obscureObject[i])
				{
					obscureObject[i] = true;
					cmd("SetAlpha", barObjects[i], 0.08);
					cmd("SetAlpha", barLabels[i], 0.08);
				}
			}
			for (i = lowIndex; i <= highIndex; i++)
			{
				if (obscureObject[i])
				{
					obscureObject[i] = false;
					cmd("SetAlpha", barObjects[i], 1.0);
					cmd("SetAlpha", barLabels[i], 1.0);
				}				
			}
			for (i = highIndex+1; i < array_size; i++)
			{
				if (!obscureObject[i])
				{
					obscureObject[i] = true;
					cmd("SetAlpha", barObjects[i], 0.08);
					cmd("SetAlpha", barLabels[i], 0.08);
				}				
			}
		}
		
		
		
		override function reset()
		{
			for (var i:int = 0; i < array_size; i++)
			{

				arrayData[i]= oldData[i];
				barObjects[i] = oldBarObjects[i];
				barLabels[i] = oldBarLabels[i];
				if (showLabels)
				{
					cmd("SetText", barLabels[i], arrayData[i]);
				}
				else
				{
					cmd("SetText", barLabels[i], "");					
				}
				cmd("SetHeight", barObjects[i], arrayData[i] * 2);
			}
			commands = new Array();
		}
		
		
		function resetCallback(event):void
		{
			randomizeArray();
		}
		
		function changeSizeCallback(event):void
		{
			resetAll(showLabels);
		}

		
		
		function insertSortCallback(event):void
		{
			animationManager.clearHistory();
			commands = new Array();
			insertionSortSkip(1,0);
			animationManager.StartNewAnimation(commands);
			commands = new Array();
		}
		
		function selectSortCallback(event):void
		{
			commands = new Array();
			animationManager.clearHistory();

			
			for (var i:int = 0; i < array_size - 1; i++)
			{
				var smallestIndex:int = i;
				cmd("SetForegroundColor", barObjects[smallestIndex], HIGHLIGHT_BAR_COLOR);
				for (var j:int = i+1; j < array_size; j++)
				{
					cmd("SetForegroundColor", barObjects[j], HIGHLIGHT_BAR_COLOR);
					cmd("Step");
					if (arrayData[j] < arrayData[smallestIndex])
					{
						cmd("SetForegroundColor", barObjects[smallestIndex], BAR_FOREGROUND_COLOR);
						smallestIndex = j;
					}
					else
					{
						cmd("SetForegroundColor", barObjects[j], BAR_FOREGROUND_COLOR);						
					}										
				}
				if (smallestIndex != i)
				{
					swap(smallestIndex, i);
				}
				cmd("SetForegroundColor", barObjects[i], BAR_FOREGROUND_COLOR);				
			}
			animationManager.StartNewAnimation(commands);
		}
		function bubbleSortCallback(event):void
		{
			animationManager.clearHistory();

			commands = new Array();
			for (var i:int = array_size-1; i > 0; i--)
			{
				for (var j:int = 0; j < i; j++)
				{
					cmd("SetForegroundColor", barObjects[j], HIGHLIGHT_BAR_COLOR);
					cmd("SetForegroundColor", barObjects[j+1], HIGHLIGHT_BAR_COLOR);
					cmd("Step");
					if (arrayData[j] > arrayData[j+1])
					{
						swap(j,j+1);
					}
					cmd("SetForegroundColor", barObjects[j], BAR_FOREGROUND_COLOR);
					cmd("SetForegroundColor", barObjects[j+1], BAR_FOREGROUND_COLOR);
				}
			}
			animationManager.StartNewAnimation(commands);
		}
		function quickSortCallback(event):void
		{
			animationManager.clearHistory();

			commands = new Array();
			iID = nextIndex++;
			jID= nextIndex++;
			cmd("CreateLabel", iID, "i", barObjects[0], ARRAY_LABEL_Y_POS + 20);
			cmd("CreateLabel", jID, "j", barObjects[array_size - 1], ARRAY_LABEL_Y_POS + 20);
			cmd("SetForegroundColor", iID, HIGHLIGHT_BAR_COLOR);
			cmd("SetForegroundColor", jID, HIGHLIGHT_BAR_COLOR);			
			doQuickSort(0, array_size - 1);			
			cmd("Delete", iID);
			cmd("Delete", jID);
			animationManager.StartNewAnimation(commands);
		}
		
		function doQuickSort(low:int, high:int):void
		{
			highlightRange(low,high);
			if (high <= low)
				return;
			cmd("Step");
			var lineID = nextIndex;
			var pivot:int = arrayData[low];
			cmd("CreateRectangle", lineID, "", (array_size + 1) * array_width, 0, array_initial_x, array_y_pos - pivot * 2,"left","bottom");
			cmd("SetForegroundColor", lineID, QUICKSORT_LINE_COLOR);
			var i:int = low+1;
			var j:int = high;
			
			cmd("Move", iID, barPositionsX[i], ARRAY_LABEL_Y_POS + 20);
			cmd("Move", jID, barPositionsX[j], ARRAY_LABEL_Y_POS + 20);
			cmd("Step");
			
			while (i <= j)
			{

				cmd("SetForegroundColor", barObjects[i], HIGHLIGHT_BAR_COLOR);
				cmd("SetForegroundColor", barObjects[low], HIGHLIGHT_BAR_COLOR);
				cmd("Step");	
				cmd("SetForegroundColor", barObjects[low], BAR_FOREGROUND_COLOR);
				cmd("SetForegroundColor", barObjects[i], BAR_FOREGROUND_COLOR);
				while (i <= j && arrayData[i] < pivot)
				{
					++i;
					cmd("Move", iID, barPositionsX[i], ARRAY_LABEL_Y_POS + 20);
					cmd("Step");	
					cmd("SetForegroundColor", barObjects[low], HIGHLIGHT_BAR_COLOR);
					cmd("SetForegroundColor", barObjects[i], HIGHLIGHT_BAR_COLOR);
					cmd("Step");	
					cmd("SetForegroundColor", barObjects[low], BAR_FOREGROUND_COLOR);
					cmd("SetForegroundColor", barObjects[i], BAR_FOREGROUND_COLOR);				
				}
				cmd("SetForegroundColor", barObjects[j], HIGHLIGHT_BAR_COLOR);
				cmd("SetForegroundColor", barObjects[low], HIGHLIGHT_BAR_COLOR);
				cmd("Step");	
				cmd("SetForegroundColor", barObjects[j], BAR_FOREGROUND_COLOR);
				cmd("SetForegroundColor", barObjects[low], BAR_FOREGROUND_COLOR);
				while (j >= i && arrayData[j] > pivot)
				{
					--j;			
					cmd("Move", jID, barPositionsX[j], ARRAY_LABEL_Y_POS + 20);
					cmd("Step");	
					cmd("SetForegroundColor", barObjects[j], HIGHLIGHT_BAR_COLOR);
					cmd("SetForegroundColor", barObjects[low], HIGHLIGHT_BAR_COLOR);
					cmd("Step");					
					cmd("SetForegroundColor", barObjects[j], BAR_FOREGROUND_COLOR);
					cmd("SetForegroundColor", barObjects[low], BAR_FOREGROUND_COLOR);
				}
				if (i <= j)
				{
					cmd("Move", jID, barPositionsX[j-1], ARRAY_LABEL_Y_POS + 20);
					cmd("Move", iID, barPositionsX[i+1], ARRAY_LABEL_Y_POS + 20);

					swap(i,j);
					++i;
					--j;
				}
			}
			if (i >= low)
			{
				cmd("SetForegroundColor", barObjects[i], BAR_FOREGROUND_COLOR);
			}
			if (j <= high)
			{
				cmd("SetForegroundColor", barObjects[j], BAR_FOREGROUND_COLOR);
			}
			swap(low, j);
			
			cmd("Step");
			cmd("Delete", lineID);	
			
			doQuickSort(low, j-1);
			doQuickSort(j+1,high);
			highlightRange(low,high);
		}		
		
		function mergeSortCallback(event):void
		{
    		animationManager.clearHistory();

			commands = new Array();
			doMergeSort(0, array_size-1);
			animationManager.StartNewAnimation(commands);
		}
		
		function doMergeSort(low,high)
		{
			highlightRange(low, high);
			if (low < high)
			{
				cmd("Step");
				var mid:int = (low + high) / 2;
				doMergeSort(low,mid);
				doMergeSort(mid+1, high);
				highlightRange(low,high);
				var insertIndex:int = low;
				var leftIndex:int = low;
				var rightIndex:int = mid+1;
				while (insertIndex <= high)
				{
					if (leftIndex <= mid && (rightIndex > high || arrayData[leftIndex] <= arrayData[rightIndex]))
					{
						arraySwap[insertIndex] = arrayData[leftIndex];
						cmd("Move", barObjects[leftIndex], barPositionsX[insertIndex], LOWER_ARRAY_Y_POS);
						cmd("Move", barLabels[leftIndex], barPositionsX[insertIndex], LOWER_ARRAY_LABEL_Y_POS);
						cmd("Step");
						labelsSwap[insertIndex] = barLabels[leftIndex];
						objectsSwap[insertIndex] = barObjects[leftIndex];
						insertIndex++;
						leftIndex++;
					}
					else
					{
						arraySwap[insertIndex] = arrayData[rightIndex];
						cmd("Move", barLabels[rightIndex], barPositionsX[insertIndex], LOWER_ARRAY_LABEL_Y_POS);
						cmd("Move", barObjects[rightIndex], barPositionsX[insertIndex], LOWER_ARRAY_Y_POS);
						cmd("Step");
						labelsSwap[insertIndex] = barLabels[rightIndex];
						objectsSwap[insertIndex] = barObjects[rightIndex];

						insertIndex++;
						rightIndex++;					
					}
				}
				for (insertIndex = low; insertIndex <= high; insertIndex++)
				{
					barObjects[insertIndex] = objectsSwap[insertIndex];
					barLabels[insertIndex] = labelsSwap[insertIndex];
					arrayData[insertIndex] = arraySwap[insertIndex];
					cmd("Move", barObjects[insertIndex], barPositionsX[insertIndex], ARRAY_Y_POS);
					cmd("Move", barLabels[insertIndex], barPositionsX[insertIndex], ARRAY_LABEL_Y_POS);
				}
    			cmd("Step");				
			}
			else
			{
		    	cmd("Step");				
			}
			
		}
		
		function shellSortCallback(event):void
		{
			animationManager.clearHistory();

			commands = new Array();
			var inc:int;
			for (inc = array_size / 2; inc >=1; inc = inc / 2)
			{
				for (var offset:int = 0; offset < inc; offset = offset + 1)
				{
					for (var k:int = 0; k < array_size; k++)
					{
						if ((k - offset) % inc == 0)
						{
							if (obscureObject[k])
							{
								obscureObject[k] = false;
								cmd("SetAlpha", barObjects[k], 1.0);
								cmd("SetAlpha", barLabels[k], 1.0);
							}
							
						}
						else
						{
							if (!obscureObject[k])
							{
								obscureObject[k] = true;
								cmd("SetAlpha", barObjects[k], 0.08);
								cmd("SetAlpha", barLabels[k], 0.08);
							}
						}												
					}
						cmd("Step");
						insertionSortSkip(inc, offset)

				}
				
			}
			animationManager.StartNewAnimation(commands);

		}
		
		function insertionSortSkip(inc, offset)
		{
			for (var i:int =inc + offset; i < array_size; i = i + inc)
			{
				var j:int = i;
				while (j > inc - 1)
				{
					cmd("SetForegroundColor", barObjects[j], HIGHLIGHT_BAR_COLOR);
					cmd("SetForegroundColor", barObjects[j-inc], HIGHLIGHT_BAR_COLOR);
					cmd("Step");
					if (arrayData[j-inc] <= arrayData[j])
					{
						cmd("SetForegroundColor", barObjects[j], BAR_FOREGROUND_COLOR);
						cmd("SetForegroundColor", barObjects[j-inc], BAR_FOREGROUND_COLOR);
						break;
					}
					swap(j,j-inc);
					cmd("SetForegroundColor", barObjects[j], BAR_FOREGROUND_COLOR);
					cmd("SetForegroundColor", barObjects[j-inc], BAR_FOREGROUND_COLOR);
					j = j - inc;					
				}
				
			}

			
			
		}
		
		override function enableUI(event:AnimationStateEvent):void
		{
			resetButton.enabled = true;
			insertSortButton.enabled = true;
			selectSortButton.enabled = true;
			bubbleSortButton.enabled = true;
			quickSortButton.enabled = true;
			mergeSortButton.enabled = true;
			shellSortButton.enabled = true;
			sizeButton.enabled = true;
		}
		override function disableUI(event:AnimationStateEvent):void
		{
			resetButton.enabled = false;
			insertSortButton.enabled = false;
			selectSortButton.enabled = false;
			bubbleSortButton.enabled = false;
			quickSortButton.enabled = false;
			mergeSortButton.enabled = false;
			shellSortButton.enabled = false;
			sizeButton.enabled = false;
		}
	}
}