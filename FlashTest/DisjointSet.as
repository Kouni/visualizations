package {
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.display.DisplayObjectContainer;
	import fl.controls.Button;
	import fl.controls.CheckBox;
	import fl.controls.TextInput;
	import flash.text.TextFormat;
	import flash.events.MouseEvent;
	import fl.events.ComponentEvent;
	import fl.controls.RadioButton;
	import fl.controls.RadioButtonGroup;
	import flash.events.Event;




	public class DisjointSet extends AlgorithmAnimation {
		
		// Input Controls
		var enterFieldFind:TextInput;
		var enterFieldUnion1:TextInput;
		var enterFieldUnion2:TextInput;
		var findButton:Button;
		var unionButton:Button;
		var clearButton:Button;
		
		
		var rankBySizeButton:RadioButton;
		var rankByHeightButton:RadioButton;
		var rankTypeGroup:RadioButtonGroup;
		
		var pathCompressionBox:CheckBox;
		var unionByRankBox:CheckBox;
		
		static const ARRAY_START_X:int = 50;
		static const ARRAY_START_Y:int = 550;
		static const ARRAY_WIDTH:int = 30;
		static const ARRAY_HEIGHT:int = 30;
		
		static const TREE_START_X:int = 50;
		static const TREE_START_Y:int = 500;
		static const TREE_ELEM_WIDTH:int = 50;
		static const TREE_ELEM_HEIGHT:int = 50; 
		
		static const SIZE:int = 16;

		var arrayLabelID:Array;
		var arrayID:Array;
		var treeID:Array;
		var treeY:Array;
		var setData:Array;
		
		var highlight1ID:int;
		var highlight2ID:int;
		
		var pathCompression:Boolean = false;
		var unionByRank:Boolean = false;
		var rankAsHeight:Boolean = false;
		
		var treeIndexToLocation:Array;
		var locationToTreeIndex:Array;
		
		var nextIndex:int  = 0;
		
		var heights:Array;


		
		const LINK_COLOR = 0x007700;
		const HIGHLIGHT_CIRCLE_COLOR = 0x007700;
		const FOREGROUND_COLOR = 0x007700;
		const BACKGROUND_COLOR = 0xEEFFEE;
		const PRINT_COLOR = FOREGROUND_COLOR;
		
		public function DisjointSet(am)
		{
			super(am);
			
			
			enterFieldFind = addTextInput(2,2,50,20, true, true);
			findButton = new Button();
			findButton.label = "Find";
			findButton.x = 55;
			findButton.width = 80;
			addChild(findButton);
					
			enterFieldUnion1 = addTextInput(140,2,50,20, true, true);
			enterFieldUnion2 = addTextInput(195,2,50,20, true, true);
			unionButton = new Button();
			unionButton.label = "Union";
			unionButton.x = 250;			
			unionButton.width = 80;
			addChild(unionButton);
			
			clearButton = new Button();
			clearButton.label = "Reset";
			clearButton.x = 335;
			clearButton.width = 80;
			addChild(clearButton);
			
			
			pathCompressionBox = new CheckBox();
			pathCompressionBox.label = "Path Compression";
			pathCompressionBox.x = 420;
			pathCompressionBox.width = 150;
			addChild(pathCompressionBox);

			
			unionByRankBox = new CheckBox();
			unionByRankBox.label = "Union by Rank";
			unionByRankBox.x = 575;
			unionByRankBox.width = 150;
			addChild(unionByRankBox);

			
			
						
			rankTypeGroup = new RadioButtonGroup("RankType");


			rankBySizeButton = new RadioButton();
			rankBySizeButton.x = 730;
			rankBySizeButton.label = "Rank = # of Nodes";
			rankBySizeButton.width = 150;
			rankBySizeButton.selected = !rankAsHeight;
			rankBySizeButton.addEventListener(Event.CHANGE, rankTypeChangedHandler);
			rankBySizeButton.group = rankTypeGroup;
			addChild(rankBySizeButton);
			
			rankByHeightButton = new RadioButton();
			rankByHeightButton.x = 730;
			rankByHeightButton.y = 20;

			rankByHeightButton.label = "Rank = Estimated Height";
			rankByHeightButton.width = 150;
			rankByHeightButton.selected = rankAsHeight;
			rankByHeightButton.addEventListener(Event.CHANGE, rankTypeChangedHandler);
			rankByHeightButton.group = rankTypeGroup;
			addChild(rankByHeightButton);
			
			
			findButton.addEventListener(MouseEvent.MOUSE_DOWN, findCallback);
			enterFieldFind.addEventListener(ComponentEvent.ENTER, findCallback);

			unionButton.addEventListener(MouseEvent.MOUSE_DOWN, unionCallback);
			enterFieldUnion1.addEventListener(ComponentEvent.ENTER, unionCallback);			
			enterFieldUnion2.addEventListener(ComponentEvent.ENTER, unionCallback);

			pathCompressionBox.addEventListener(MouseEvent.CLICK, pathCompressionChangeCallback);
			unionByRankBox.addEventListener(MouseEvent.CLICK, unionByRankChangeCallback);
			
			clearButton.addEventListener(MouseEvent.MOUSE_DOWN, clearCallback);

			
			nextIndex = 0;
			highlight1ID = nextIndex++;
			highlight2ID = nextIndex++;
			
			arrayID = new Array(SIZE);
			arrayLabelID = new Array(SIZE);
			treeID = new Array(SIZE);
			setData = new Array(SIZE);
			treeY = new Array(SIZE);
			treeIndexToLocation = new Array(SIZE);
			locationToTreeIndex = new Array(SIZE);
			heights = new Array(SIZE);
			for (var i = 0; i < SIZE; i++)
			{
				treeIndexToLocation[i] = i;
				locationToTreeIndex[i] = i;
				arrayID[i]= nextIndex++;
				arrayLabelID[i]= nextIndex++;
				treeID[i] = nextIndex++;
				setData[i] = -1;
				treeY[i] =  TREE_START_Y;
				heights[i] = 0;
			}
			
			setup();
			
			
//			cmd("CreateLabel", 0, "", 20, 50, 0);
//			animationManager.StartNewAnimation(commands);
//			animationManager.skipForward();
//			animationManager.clearHistory();
//			commands = new Array();			
		}
		
		function setup()
		{
			commands = new Array();

			for (var i:int = 0; i < SIZE; i++)
			{
				cmd("CreateRectangle", arrayID[i], setData[i], ARRAY_WIDTH, ARRAY_HEIGHT, ARRAY_START_X + i *ARRAY_WIDTH, ARRAY_START_Y);
				cmd("CreateLabel",arrayLabelID[i],  i,  ARRAY_START_X + i *ARRAY_WIDTH, ARRAY_START_Y + ARRAY_HEIGHT);
				cmd("SetForegroundColor", arrayLabelID[i], 0x0000FF);

                cmd("CreateCircle", treeID[i], i,  TREE_START_X + treeIndexToLocation[i] * TREE_ELEM_WIDTH, treeY[i]);
				cmd("SetForegroundColor",  treeID[i], FOREGROUND_COLOR);
				cmd("SetBackgroundColor",  treeID[i], BACKGROUND_COLOR);
				
			}
			
			
			animationManager.StartNewAnimation(commands);
			animationManager.skipForward();
			animationManager.clearHistory();		
			
		}
		
		
		override function reset()
		{
			for (var i:int = 0; i < SIZE; i++)
			{
				setData[i] = -1;
			}
			pathCompression = false;
			unionByRank = false;
			pathCompressionBox.selected = pathCompression;
			unionByRankBox.selected = unionByRank;
		}
		
		
		override function enableUI(event:AnimationStateEvent):void
		{
			findButton.enabled = true;
			unionButton.enabled = true;
			clearButton.enabled = true;
			
			rankBySizeButton.enabled = true;
			rankByHeightButton.enabled = true;
			
			pathCompressionBox.enabled = true;
			unionByRankBox.enabled = true;
			
			enterFieldFind.enabled =true;
			enterFieldUnion1.enabled =true;
			enterFieldUnion2.enabled =true;
			enterFieldFind.addEventListener(ComponentEvent.ENTER, findCallback);
			enterFieldUnion1.addEventListener(ComponentEvent.ENTER, unionCallback);
			enterFieldUnion2.addEventListener(ComponentEvent.ENTER, unionCallback);			
			
		}
		override function disableUI(event:AnimationStateEvent):void
		{
			findButton.enabled = false;
			unionButton.enabled = false;
			clearButton.enabled = false;

			rankBySizeButton.enabled = false;
			rankByHeightButton.enabled = false;
			
			pathCompressionBox.enabled = false;
			unionByRankBox.enabled = false;
			
			enterFieldFind.enabled = false;
			enterFieldUnion1.enabled = false;
			enterFieldUnion2.enabled = false;
			
			enterFieldFind.removeEventListener(ComponentEvent.ENTER, findCallback);
			enterFieldUnion1.removeEventListener(ComponentEvent.ENTER, unionCallback);
			enterFieldUnion2.removeEventListener(ComponentEvent.ENTER, unionCallback);				
		}
		
		
		
		
		private function rankTypeChangedHandler(event:Event):void 
		{
			if ( event.currentTarget.selected )
			{
				if (event.currentTarget == rankBySizeButton && rankAsHeight)
				{
					implementAction(changeRankType,  "False");
				}
				else if (event.currentTarget == rankByHeightButton && !rankAsHeight)
				{
					implementAction(changeRankType, "True");
				}
			}
		}
		
	
		
		function pathCompressionChangeCallback(event)
		{
			if (pathCompression != pathCompressionBox.selected)
			{
				implementAction(changePathCompression, String(pathCompressionBox.selected));
			}
		}
		
		function unionByRankChangeCallback(event)
		{
			if (unionByRank != unionByRankBox.selected)
			{
				implementAction(changeUnionByRank, String(unionByRankBox.selected));
			}
		}
		
		function changeRankType(newValue)
		{
			commands = new Array();
			rankAsHeight = (newValue == "True");			
			if (rankBySizeButton.selected == rankAsHeight)
			{
				rankBySizeButton.selected = !rankAsHeight;
			}
			if (rankByHeightButton.selected != rankAsHeight)
			{
				rankByHeightButton.selected = rankAsHeight;
			}
			// When we change union by rank, we can either create a blank slate using clearAll,
			// or we can rebuild the root values to what they shoue be given the current state of
			// the tree.  
			// clearAll();
			rebuildRootValues();
			return commands;			

			
		}
		
		
		function changeUnionByRank(newValue)
		{
			commands = new Array();
			unionByRank = (newValue == String(true));
			if (unionByRankBox.selected != unionByRank)
			{
				unionByRankBox.selected = unionByRank;
			}
			// When we change union by rank, we can either create a blank slate using clearAll,
			// or we can rebuild the root values to what they shoue be given the current state of
			// the tree.  
			// clearAll();
			rebuildRootValues();
			return commands;			

		}
		
		
		function changePathCompression(newValue)
		{
			commands = new Array();
			cmd("Step");
			pathCompression = (newValue == String(true));
			if (pathCompressionBox.selected != pathCompression)
			{
				pathCompressionBox.selected = pathCompression;
			}
			// clearAll();
			return commands;			

		}
		
		function findCallback(event):void
		{
			var findValue:String;
			
			findValue = enterFieldFind.text;
			if (isAllDigits(findValue) && findValue != "" && int(findValue) < SIZE)
			{
				enterFieldFind.text = "";
				implementAction(findElement, findValue);
			}
		}
		
		function clearCallback(event):void
		{
			implementAction(clearData, "");
		}
		
		function clearData(ignored)
		{
			commands = new Array();
			clearAll();
			return commands;			
		}
		
		
		function getSizes()
		{
			var sizes:Array = new Array(SIZE);
			
			for (var i:int = 0; i < SIZE; i++)
			{
				sizes[i] = 1;				
			}
			var changed:Boolean = true;
			while (changed)
			{
				changed = false;
				for (i = 0; i < SIZE; i++)
				{
					if (sizes[i] > 0 && setData[i] >= 0)
					{
						sizes[setData[i]] += sizes[i];
						sizes[i] = 0;
						changed = true;
					}					
				}				
			}
			return sizes;
		}
		
		function rebuildRootValues()
		{
			var changed:Boolean = false;
			
			if (unionByRank)
			{
				if (!rankAsHeight)
				{
					var sizes:Array = getSizes();
				}
				for (var i:int = 0; i < SIZE; i++)
				{
					if (setData[i] < 0)
					{
						if (rankAsHeight)
						{						
							setData[i] = 0 - heights[i] - 1;
						}
						else
						{
							setData[i] = - sizes[i];
						}
					}
				}
			}
			else
			{
				for (i = 0; i < SIZE; i++)
				{
					if (setData[i] < 0)
					{
						setData[i] = -1;
					}
				}
			}
			for (i = 0; i < SIZE; i++)
			{
				cmd("SetText", arrayID[i], setData[i]);
			}
			
		}
		
		function unionCallback(event):void
		{
			var union1:String;
			var union2:String;
			
			union1 = enterFieldUnion1.text;
			union2 = enterFieldUnion2.text;

			if (isAllDigits(union1) && union1 != "" && int(union1) < SIZE && 
			    isAllDigits(union2) && union2 != "" && int(union2) < SIZE)
			{
				enterFieldUnion1.text = "";
				enterFieldUnion2.text = "";
				implementAction(doUnion, union1 + ";" + union2);		
			}
		}
		
	
		function clearAll()
		{
			for (var i:int = 0; i < SIZE; i++)
			{
				if (setData[i] >= 0)
				{
					cmd("Disconnect", treeID[i], treeID[setData[i]]);
				}
				setData[i] = -1;
				cmd("SetText", arrayID[i], setData[i]);
				treeIndexToLocation[i] = i;
				locationToTreeIndex[i] = i;
				treeY[i] =  TREE_START_Y;
				cmd("SetPosition", treeID[i], TREE_START_X + treeIndexToLocation[i] * TREE_ELEM_WIDTH, treeY[i]);				
			}
			
			
		}
	
				
		function findElement(findValue:String):Array
		{
			commands = new Array();
			

			var found = doFind(int(findValue));
			
			if (pathCompression)
			{
				var changed = adjustHeights();
				if (changed)
				{
					animateNewPositions();
				}
			}
			return commands;
		}
				
				
				
		function doFind(elem:int)
		{
			cmd("SetHighlight", treeID[elem], 1);
			cmd("SetHighlight", arrayID[elem], 1);
			cmd("Step");
			cmd("SetHighlight", treeID[elem], 0);
			cmd("SetHighlight", arrayID[elem], 0);
			if (setData[elem] >= 0)
			{
			    var treeRoot = doFind(setData[elem]);
				if (pathCompression)
				{
					if (setData[elem] != treeRoot)
					{
						cmd("Disconnect", treeID[elem], treeID[setData[elem]]);
						setData[elem] = treeRoot;
						cmd("SetText", arrayID[elem], setData[elem]);
						cmd("Connect", treeID[elem],
						  			   treeID[treeRoot],
						   			   FOREGROUND_COLOR, 
					                   0, // Curve
							           1, // Directed
							           ""); // Label
					}
				}				
				return treeRoot;
			}
			else
			{
				return elem;
			}
			
		}
				
				
		function findRoot(elem:int)
		{
			while (setData[elem] >= 0)
				elem = setData[elem];
			return elem;			
		}
				
				
				
		// After linking two trees, move them next to each other.			
		function adjustXPos(pos1, pos2)
		{

			var left1 = treeIndexToLocation[pos1];
			while (left1 > 0 && findRoot(locationToTreeIndex[left1 - 1]) == pos1)
			{
				left1--;
			}
			var right1 = treeIndexToLocation[pos1];
			while (right1 < SIZE - 1 && findRoot(locationToTreeIndex[right1 + 1]) == pos1)
			{
				right1++;
			}
			var left2 = treeIndexToLocation[pos2];
			while (left2 > 0 && findRoot(locationToTreeIndex[left2-1]) == pos2)
			{
				left2--;
			}
			var right2 = treeIndexToLocation[pos2];
			while (right2 < SIZE - 1 && findRoot(locationToTreeIndex[right2 + 1]) == pos2)
			{
				right2++;
			}
			if (right1 == left2-1)
			{
				return false;
			}
			
			var tmpLocationToTreeIndex:Array = new Array(SIZE);
			var nextInsertIndex = 0;
			for (var i:int = 0; i <= right1; i++)
			{
				tmpLocationToTreeIndex[nextInsertIndex++] = locationToTreeIndex[i];
			}
			for (i = left2; i <= right2; i++)
			{
				tmpLocationToTreeIndex[nextInsertIndex++] = locationToTreeIndex[i];
			}
			for (i = right1+1; i < left2; i++)
			{
				tmpLocationToTreeIndex[nextInsertIndex++] = locationToTreeIndex[i];				
			}
			for (i = right2+1; i < SIZE; i++)
			{
				tmpLocationToTreeIndex[nextInsertIndex++] = locationToTreeIndex[i];
			}
			for (i = 0; i < SIZE; i++)
			{
				locationToTreeIndex[i] = tmpLocationToTreeIndex[i];
			}
			for (i = 0; i < SIZE; i++)
			{
				treeIndexToLocation[locationToTreeIndex[i]] = i;
			}
			return true;
		}
		
		function doUnion(value:String)
		{
			commands = new Array();
			var args:Array = value.split(";");
			var arg1:int = doFind(int(args[0]));

			cmd("CreateHighlightCircle", highlight1ID, HIGHLIGHT_CIRCLE_COLOR, TREE_START_X + treeIndexToLocation[arg1] * TREE_ELEM_WIDTH, treeY[arg1]);

			
			var arg2:int = doFind(int(args[1]));
			cmd("CreateHighlightCircle", highlight2ID, HIGHLIGHT_CIRCLE_COLOR, TREE_START_X + treeIndexToLocation[arg2] * TREE_ELEM_WIDTH, treeY[arg2]);
			
			
			if (arg1 == arg2)
			{
				cmd("Delete", highlight1ID);
				cmd("Delete", highlight2ID);
				return commands;
			}
			
			var changed:Boolean;
			
			if (treeIndexToLocation[arg1] < treeIndexToLocation[arg2])
			{
				changed = adjustXPos(arg1, arg2) || changed
			}
			else
			{
				changed = adjustXPos(arg2, arg1) || changed
			}
			
			
			if (unionByRank && setData[arg1] < setData[arg2])
			{
				var tmp:int = arg1;
				arg1 = arg2;
				arg2 = tmp;
			}
		
			if (unionByRank && rankAsHeight)
			{
				if (setData[arg2] == setData[arg1])
				{
					setData[arg2] -= 1;
				}
			}
			else if (unionByRank)
			{
				setData[arg2] = setData[arg2] + setData[arg1];				
			}
			
			setData[arg1] = arg2;
			
			cmd("SetText", arrayID[arg1], setData[arg1]);
			cmd("SetText", arrayID[arg2], setData[arg2]);
			
			cmd("Connect", treeID[arg1],
						   treeID[arg2],
						   FOREGROUND_COLOR, 
					           0, // Curve
							   1, // Directed
							   ""); // Label
			
			if (adjustHeights())
			{
				changed = true;
			}
					
			if (changed)
			{
				cmd("Step");
				cmd("Delete", highlight1ID);
				cmd("Delete", highlight2ID);
				animateNewPositions();
			}
			else
			{
				cmd("Delete", highlight1ID);
				cmd("Delete", highlight2ID);		
			}
			
			return commands;
		}
		

		function adjustHeights() :Boolean
		{
			var changed:Boolean = false;
			for (var i:int = 0; i < SIZE; i++)
			{
				heights[i] = 0;
			}
			
			for (var j = 0; j < SIZE; j++)
			{
				for (i = 0; i < SIZE; i++)
				{
					if (setData[i] >= 0)
					{
						heights[setData[i]] = Math.max(heights[setData[i]], heights[i] + 1);
					}
					
				}
			}
			for (j = 0; j < SIZE; j++)
			{
				for (i = 0; i < SIZE; i++)
				{
					if (setData[i] >= 0)
					{
						heights[i] = heights[setData[i]] - 1;
					}
					
				}
			}
			for (i = 0; i < SIZE; i++)
			{
				var newY = TREE_START_Y - heights[i] * TREE_ELEM_HEIGHT;
				if (treeY[i] != newY)
				{
					treeY[i] = newY;
					changed = true;
				}
			}
			return changed;
		}

			
		function setNewPositions()
		{

			
		}
		function animateNewPositions()
		{
			for (var i:int = 0; i < SIZE; i++)
			{
				cmd("Move", treeID[i], TREE_START_X + treeIndexToLocation[i] * TREE_ELEM_WIDTH, treeY[i]);
			}
		}
		
	}
}

