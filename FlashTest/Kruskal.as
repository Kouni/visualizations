package 
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.display.DisplayObjectContainer;
	import fl.controls.Button;
	import fl.controls.TextInput;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.events.MouseEvent;
	import fl.events.ComponentEvent;
	import fl.controls.RadioButton;
	import fl.controls.RadioButtonGroup;

	import flash.events.Event;


	public class Kruskal extends Graph
	{
		// Input Controls
		var startButton:Button;
		var enterFieldStart:TextInput;
		
		static const SET_ARRAY_ELEM_WIDTH = 25;
		static const SET_ARRAY_ELEM_HEIGHT = 25;
		static const SET_ARRAY_START_X = 50;
		static const SET_ARRAY_START_Y = 130;
		
		static const EDGE_LIST_ELEM_WIDTH = 40;
		static const EDGE_LIST_ELEM_HEIGHT = 40;
		static const EDGE_LIST_COLUMN_WIDTH = 100;
		static const EDGE_LIST_MAX_PER_COLUMN = 10;
		
		static const EDGE_LIST_START_X = 150;
		static const EDGE_LIST_START_Y = 130;
	
	
		static const FIND_LABEL_1_X = 30;
		static const FIND_LABEL_2_X = 100;
		static const FIND_LABEL_1_Y = 30;
		static const FIND_LABEL_2_Y = FIND_LABEL_1_Y;
		
		static const MESSAGE_LABEL_X = 30;
		static const MESSAGE_LABEL_Y = 50;
		
		static const HIGHLIGHT_CIRCLE_COLOR_1 = 0xFFAAAA;
		static const HIGHLIGHT_CIRCLE_COLOR_2 = 0xFF0000;
				
		
		
		var setID: Array;
		var setIndexID: Array;
		
		var setData:Array;
		
		var messageID:Array;
		
		var edgesListLeft:Array;
		var edgesListRight:Array;
		var edgesListLeftID:Array;
		var edgesListRightID:Array;
		
		var highlightCircleL:int;
		var highlightCircleAL:int;
		var highlightCircleAM:int;
		var messageY:int;
		
		
		function Kruskal(am)
		{
			showEdgeCosts = true;
			startButton = new Button();
			startButton.label = "Run Kruskal";
			startButton.x = 2;			
			startButton.y = 2;			
			addChild(startButton);
			
			startButton.addEventListener(MouseEvent.MOUSE_DOWN, startCallback);
			super(am);
			
			removeChild(undirectedGraphButton);
			removeChild(directedGraphButton);
		}
		
		
		override function setup() : void
		{
			super.setup();
			messageID = new Array();
			commands = new Array();
			setID = new Array(size);
			setIndexID = new Array(size);
			setData = new Array(size);
			
			
			for (var i:int = 0; i < size; i++)
			{
				setID[i] = nextIndex++;
				setIndexID[i] = nextIndex++;
				cmd("CreateRectangle", setID[i], "-1", SET_ARRAY_ELEM_WIDTH, SET_ARRAY_ELEM_HEIGHT, SET_ARRAY_START_X, SET_ARRAY_START_Y + i*SET_ARRAY_ELEM_HEIGHT);
				cmd("CreateLabel", setIndexID[i], i, SET_ARRAY_START_X - SET_ARRAY_ELEM_WIDTH ,SET_ARRAY_START_Y + i*SET_ARRAY_ELEM_HEIGHT);
				cmd("SetForegroundColor",  setIndexID[i], VERTEX_INDEX_COLOR);				
			}
			cmd("CreateLabel", nextIndex++, "Disjoint Set", SET_ARRAY_START_X - 1 * SET_ARRAY_ELEM_WIDTH, SET_ARRAY_START_Y - SET_ARRAY_ELEM_HEIGHT * 1.5, 0);
			animationManager.setAllLayers(0, currentLayer);
			animationManager.StartNewAnimation(commands);
			animationManager.skipForward();
			animationManager.clearHistory();
		}
		
		function startCallback(event)
		{

			implementAction(doKruskal,"");
			
		}
		
		
		
		function disjointSetFind(valueToFind, highlightCircleID):int
		{
			cmd("SetTextColor", setID[valueToFind], 0xFF0000);
			cmd("Step");
			while (setData[valueToFind] >= 0)
			{
				cmd("SetTextColor", setID[valueToFind], 0x000000);
				cmd("Move", highlightCircleID,  SET_ARRAY_START_X - SET_ARRAY_ELEM_WIDTH ,SET_ARRAY_START_Y + setData[valueToFind]*SET_ARRAY_ELEM_HEIGHT);
				cmd("Step");
				valueToFind =  setData[valueToFind];
				cmd("SetTextColor", setID[valueToFind], 0xFF0000);
				cmd("Step");		
			}
			cmd("SetTextColor", setID[valueToFind], 0x000000);
			return valueToFind;
		}

		
			
		function doKruskal(ignored)
		{
			commands = new Array();
			
			edgesListLeftID = new Array();
			edgesListRightID = new Array();
			edgesListLeft = new Array();
			edgesListRight = new Array();
			
			for (var i:int = 0; i < size; i++)
			{
				setData[i] = -1;
				cmd("SetText", setID[i], "-1");
			}
			
			recolorGraph();
			
			// Create Edge List
			for (i = 0; i < size; i++)
			{
				for (var j:int = i+1; j < size; j++)
				{
					if (adj_matrix[i][j] >= 0)
					{
						edgesListLeftID.push(nextIndex++);
						edgesListRightID.push(nextIndex++);
						var top = edgesListLeftID.length - 1;
						edgesListLeft.push(i);
						edgesListRight.push(j);
						cmd("CreateLabel", edgesListLeftID[top], i, EDGE_LIST_START_X + Math.floor(top / EDGE_LIST_MAX_PER_COLUMN) * EDGE_LIST_COLUMN_WIDTH,
																	EDGE_LIST_START_Y + (top % EDGE_LIST_MAX_PER_COLUMN) * EDGE_LIST_ELEM_HEIGHT);
						cmd("CreateLabel", edgesListRightID[top], j, EDGE_LIST_START_X +EDGE_LIST_ELEM_WIDTH +  Math.floor(top / EDGE_LIST_MAX_PER_COLUMN) * EDGE_LIST_COLUMN_WIDTH,
																	EDGE_LIST_START_Y + (top % EDGE_LIST_MAX_PER_COLUMN) * EDGE_LIST_ELEM_HEIGHT);
						cmd("Connect", edgesListLeftID[top], edgesListRightID[top], EDGE_COLOR, 0, 0, adj_matrix[i][j])
					 }					
				}
			}
			cmd("Step");
			
			// Sort edge list based on edge cost
			var edgeCount = edgesListLeftID.length;
			for (i = 1; i < edgeCount; i++)
			{
				var tmpLeftID = edgesListLeftID[i];
				var tmpRightID = edgesListRightID[i];
				var tmpLeft = edgesListLeft[i];
				var tmpRight = edgesListRight[i];
				j = i;
				while (j > 0 && adj_matrix[edgesListLeft[j-1]][edgesListRight[j-1]] > adj_matrix[tmpLeft][tmpRight])
				{
					edgesListLeft[j] = edgesListLeft[j-1];
					edgesListRight[j] = edgesListRight[j-1];
					edgesListLeftID[j] = edgesListLeftID[j-1];
					edgesListRightID[j] = edgesListRightID[j-1];
					j = j -1
				}
				edgesListLeft[j] = tmpLeft;				
				edgesListRight[j] = tmpRight;			
				edgesListLeftID[j] = tmpLeftID;
				edgesListRightID[j] = tmpRightID;				
			}
			for (i = 0; i < edgeCount; i++)
			{
				cmd("Move", edgesListLeftID[i], EDGE_LIST_START_X + Math.floor(i / EDGE_LIST_MAX_PER_COLUMN) * EDGE_LIST_COLUMN_WIDTH,
												EDGE_LIST_START_Y + (i % EDGE_LIST_MAX_PER_COLUMN) * EDGE_LIST_ELEM_HEIGHT);
				cmd("Move",  edgesListRightID[i], EDGE_LIST_START_X +EDGE_LIST_ELEM_WIDTH +  Math.floor(i / EDGE_LIST_MAX_PER_COLUMN) * EDGE_LIST_COLUMN_WIDTH,
																	EDGE_LIST_START_Y + (i % EDGE_LIST_MAX_PER_COLUMN) * EDGE_LIST_ELEM_HEIGHT);
				
			}
			
			cmd("Step");

			var findLabelLeft:int = nextIndex++;
			var findLabelRight:int = nextIndex++;
			var highlightCircle1:int = nextIndex++;
			var highlightCircle2:int = nextIndex++;
			var moveLabelID:int = nextIndex++;
			var messageLabelID:int = nextIndex++;
			
			var edgesAdded = 0;
			var nextListIndex = 0;
			cmd("CreateLabel", findLabelLeft, "",  FIND_LABEL_1_X, FIND_LABEL_1_Y, 0);
			cmd("CreateLabel", findLabelRight, "",  FIND_LABEL_2_X, FIND_LABEL_2_Y, 0);

			while (edgesAdded < size - 1 && nextListIndex < edgeCount)
			{				
				cmd("SetEdgeHighlight", edgesListLeftID[nextListIndex],edgesListRightID[nextListIndex], 1);
				
				
				cmd("SetText", findLabelLeft, "find(" + String(edgesListLeft[nextListIndex]) + ") = ");
				

				cmd("CreateHighlightCircle", highlightCircle1, HIGHLIGHT_CIRCLE_COLOR_1,  EDGE_LIST_START_X + Math.floor(nextListIndex / EDGE_LIST_MAX_PER_COLUMN) * EDGE_LIST_COLUMN_WIDTH, 
							EDGE_LIST_START_Y + (nextListIndex % EDGE_LIST_MAX_PER_COLUMN) * EDGE_LIST_ELEM_HEIGHT, 15);
				cmd("Move", highlightCircle1,  SET_ARRAY_START_X - SET_ARRAY_ELEM_WIDTH ,SET_ARRAY_START_Y + edgesListLeft[nextListIndex]*SET_ARRAY_ELEM_HEIGHT);
				cmd("Step");
				
				var left = disjointSetFind(edgesListLeft[nextListIndex], highlightCircle1);
				cmd("SetText", findLabelLeft, "find(" + String(edgesListLeft[nextListIndex]) + ") = " + String(left));
				
				
				cmd("SetText", findLabelRight, "find(" + String(edgesListRight[nextListIndex]) + ") = ");

				cmd("CreateHighlightCircle", highlightCircle2, HIGHLIGHT_CIRCLE_COLOR_2,  EDGE_LIST_START_X +EDGE_LIST_ELEM_WIDTH  + Math.floor(nextListIndex / EDGE_LIST_MAX_PER_COLUMN) * EDGE_LIST_COLUMN_WIDTH, 
							EDGE_LIST_START_Y + (nextListIndex % EDGE_LIST_MAX_PER_COLUMN) * EDGE_LIST_ELEM_HEIGHT, 15);
				
				
				cmd("Move", highlightCircle2,  SET_ARRAY_START_X - SET_ARRAY_ELEM_WIDTH ,SET_ARRAY_START_Y + edgesListRight[nextListIndex]*SET_ARRAY_ELEM_HEIGHT);
				cmd("Step");
				
				var right = disjointSetFind(edgesListRight[nextListIndex], highlightCircle2);
				cmd("SetText", findLabelRight, "find(" + String(edgesListRight[nextListIndex]) + ") = " + String(right));
				
				cmd("Step");
				
				if (left != right)
				{
					cmd("CreateLabel", messageLabelID, "Vertices in different trees.  Add edge to tree: Union(" + String(left) + "," + String(right) + ")",  MESSAGE_LABEL_X, MESSAGE_LABEL_Y, 0);
					cmd("Step");
					highlightEdge(edgesListLeft[nextListIndex], edgesListRight[nextListIndex], 1)
					highlightEdge(edgesListRight[nextListIndex], edgesListLeft[nextListIndex], 1)
					edgesAdded++;
					setEdgeColor(edgesListLeft[nextListIndex], edgesListRight[nextListIndex], 0xFF0000);				
					setEdgeColor( edgesListRight[nextListIndex], edgesListLeft[nextListIndex], 0xFF0000);
					if (setData[left] < setData[right])
					{
						cmd("SetText", setID[right], "")
						cmd("CreateLabel", moveLabelID, setData[right], SET_ARRAY_START_X, SET_ARRAY_START_Y + right*SET_ARRAY_ELEM_HEIGHT);
						cmd("Move", moveLabelID,  SET_ARRAY_START_X, SET_ARRAY_START_Y + left*SET_ARRAY_ELEM_HEIGHT);
						cmd("Step");
						cmd("Delete", moveLabelID);
						setData[left] = setData[left] + setData[right]
						setData[right] = left;
					}
					else
					{
						cmd("SetText", setID[left], "")
						cmd("CreateLabel", moveLabelID, setData[left], SET_ARRAY_START_X, SET_ARRAY_START_Y + left*SET_ARRAY_ELEM_HEIGHT);
						cmd("Move", moveLabelID,  SET_ARRAY_START_X, SET_ARRAY_START_Y + right*SET_ARRAY_ELEM_HEIGHT);
						cmd("Step");
						cmd("Delete", moveLabelID);
						setData[right] = setData[right] + setData[left]
						setData[left] = right;
					}
					cmd("SetText", setID[left], setData[left]);
					cmd("SetText", setID[right], setData[right]);
				}
				else
				{
					cmd("CreateLabel", messageLabelID, "Vertices in the same tree.  Skip edge",  MESSAGE_LABEL_X, MESSAGE_LABEL_Y, 0);
					cmd("Step");
			
				}
				
				highlightEdge(edgesListLeft[nextListIndex], edgesListRight[nextListIndex], 0)
				highlightEdge(edgesListRight[nextListIndex], edgesListLeft[nextListIndex], 0)

				cmd("Delete", messageLabelID);
				cmd("Delete", highlightCircle1);
				cmd("Delete", highlightCircle2);

				
				cmd("Delete", edgesListLeftID[nextListIndex]);
				cmd("Delete", edgesListRightID[nextListIndex]);
				cmd("SetText", findLabelLeft, "");
				cmd("SetText", findLabelRight, "");
				nextListIndex++;
				
			}
			cmd("Delete", findLabelLeft);
			cmd("Delete", findLabelRight);
			
			

			return commands

		}
		
		
		
		// NEED TO OVERRIDE IN PARENT
		override function reset()
		{
			// Throw an error?
		}
		
		
		
		
		override function enableUI(event:AnimationStateEvent):void
		{			
			startButton.enabled = true;

			super.enableUI(event);
		}
		override function disableUI(event:AnimationStateEvent):void
		{
			startButton.enabled = false;

			super.disableUI(event);
		}
	}
}