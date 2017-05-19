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


	public class TopologicalSort extends Graph
	{
		// Input Controls
		var startButton:Button;
		var enterFieldStart:TextInput;
		
		static const INDEGREE_ARRAY_ELEM_WIDTH = 25;
		static const INDEGREE_ARRAY_ELEM_HEIGHT = 25;
		static const INDEGREE_ARRAY_START_X = 50;
		static const INDEGREE_ARRAY_START_Y = 130;
		

		static const STACK_START_X = INDEGREE_ARRAY_START_X + 100;
		static const STACK_START_Y = INDEGREE_ARRAY_START_Y;
		static const STACK_HEIGHT = INDEGREE_ARRAY_ELEM_HEIGHT;

		
		static const TOPO_ARRAY_START_X = STACK_START_X + 150;
		static const TOPO_ARRAY_START_Y = INDEGREE_ARRAY_START_Y;
		static const TOPO_HEIGHT = INDEGREE_ARRAY_ELEM_HEIGHT;
			
			
		
			
	
		static const FIND_LABEL_1_X = 30;
		static const FIND_LABEL_2_X = 100;
		static const FIND_LABEL_1_Y = 30;
		static const FIND_LABEL_2_Y = FIND_LABEL_1_Y;
		
		static const MESSAGE_LABEL_1_X = 30;
		static const MESSAGE_LABEL_1_Y = 30;
		
		static const MESSAGE_LABEL_2_X = 30;
		static const MESSAGE_LABEL_2_Y = 60;
		
		static const ORDER_X = 150;
		static const ORDER_Y = 50;
		static const ORDER_HEIGHT = 20;
		
		
		static const HIGHLIGHT_CIRCLE_COLOR = 0xFF0000;
				
				
		var stackLabelID:int;
		var topoLabelID:int;
		
		
		var indegreeID: Array;
		var setIndexID: Array;
		
		var indegree:Array;
		
		var messageID:Array;
		
		var topologicalOrderID:Array;

		var stackID:Array;
		var stack:Array;
		var stackTop:int;
		
		var orderID:Array;
		
		var message1ID:int;
		var message2ID:int 
		
		var highlightCircleL:int;
		var highlightCircleAL:int;
		var highlightCircleAM:int;
		
		
		function TopologicalSort(am)
		{
			showEdgeCosts = false;
			isDAG = true;
			directed = true;
			startButton = new Button();
			startButton.label = "Topological Sort";
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
			indegreeID = new Array(size);
			setIndexID = new Array(size);
			indegree = new Array(size);
			orderID = new Array(size);
			
			highlightCircleL = nextIndex++;
		   	highlightCircleAL = nextIndex++;
			highlightCircleAM= nextIndex++;
			
			
			for (var i:int = 0; i < size; i++)
			{
				indegreeID[i] = nextIndex++;
				setIndexID[i] = nextIndex++;
				orderID[i] = nextIndex++;
				cmd("CreateRectangle", indegreeID[i], " ", INDEGREE_ARRAY_ELEM_WIDTH, INDEGREE_ARRAY_ELEM_HEIGHT, INDEGREE_ARRAY_START_X, INDEGREE_ARRAY_START_Y + i*INDEGREE_ARRAY_ELEM_HEIGHT);
				cmd("CreateLabel", setIndexID[i], i, INDEGREE_ARRAY_START_X - INDEGREE_ARRAY_ELEM_WIDTH ,INDEGREE_ARRAY_START_Y + i*INDEGREE_ARRAY_ELEM_HEIGHT);
				cmd("SetForegroundColor",  setIndexID[i], VERTEX_INDEX_COLOR);				
			}
			cmd("CreateLabel", nextIndex++, "Indegree", INDEGREE_ARRAY_START_X - 1 * INDEGREE_ARRAY_ELEM_WIDTH, INDEGREE_ARRAY_START_Y - INDEGREE_ARRAY_ELEM_HEIGHT * 1.5, 0);
			
			
			message1ID = nextIndex++;
			message2ID = nextIndex++;
			cmd("CreateLabel", message1ID, "", MESSAGE_LABEL_1_X, MESSAGE_LABEL_1_Y, 0);
			cmd("CreateLabel", message2ID, "", MESSAGE_LABEL_2_X, MESSAGE_LABEL_2_Y);

			stackLabelID = nextIndex++;
			topoLabelID = nextIndex++;
			cmd("CreateLabel", stackLabelID, "", STACK_START_X, STACK_START_Y - STACK_HEIGHT);
			cmd("CreateLabel", topoLabelID, "", TOPO_ARRAY_START_X, TOPO_ARRAY_START_Y - TOPO_HEIGHT);
			
			animationManager.setAllLayers(0, currentLayer);
			animationManager.StartNewAnimation(commands);
			animationManager.skipForward();
			animationManager.clearHistory();
		}
		
		function startCallback(event)
		{

			implementAction(doTopoSort,"");
			
		}
		
		

		
			
		function doTopoSort(ignored)
		{
			commands = new Array();
			stack = new Array(size);
			stackID = new Array(size);
			stackTop = 0;
			
			for (var vertex:int = 0; vertex < size; vertex++)
			{
				cmd("SetText", indegreeID[vertex], "0");
				indegree[vertex] = 0;
				stackID[vertex] = nextIndex++;
				cmd("Delete", orderID[vertex]);
			}
			
			cmd("SetText", message1ID, "Calculate indegree of all verticies by going through every edge of the graph");
			cmd("SetText", topoLabelID, "");
			cmd("SetText", stackLabelID, "");
			for (vertex = 0; vertex < size; vertex++)
			{
				var adjListIndex:int = 0;
				for (var neighbor:int = 0; neighbor < size; neighbor++)
				if (adj_matrix[vertex][neighbor] >= 0)
				{
					adjListIndex++;
					highlightEdge(vertex, neighbor, 1);
					cmd("Step");
					
					cmd("CreateHighlightCircle", highlightCircleL, HIGHLIGHT_CIRCLE_COLOR, x_pos_logical[neighbor], y_pos_logical[neighbor]);
					cmd("SetLayer", highlightCircleL, 1);
					cmd("CreateHighlightCircle", highlightCircleAL, HIGHLIGHT_CIRCLE_COLOR,adj_list_x_start + adjListIndex * (adj_list_width + adj_list_spacing), adj_list_y_start + vertex*adj_list_height);
					cmd("SetLayer", highlightCircleAL, 2);
					cmd("CreateHighlightCircle", highlightCircleAM, HIGHLIGHT_CIRCLE_COLOR,adj_matrix_x_start  + neighbor * adj_matrix_width, adj_matrix_y_start - adj_matrix_height);
					cmd("SetLayer", highlightCircleAM, 3);
					
					cmd("Move", highlightCircleL,INDEGREE_ARRAY_START_X - INDEGREE_ARRAY_ELEM_WIDTH ,INDEGREE_ARRAY_START_Y + neighbor*INDEGREE_ARRAY_ELEM_HEIGHT);
					
					cmd("Move", highlightCircleAL, INDEGREE_ARRAY_START_X - INDEGREE_ARRAY_ELEM_WIDTH ,INDEGREE_ARRAY_START_Y + neighbor*INDEGREE_ARRAY_ELEM_HEIGHT);
					cmd("Move", highlightCircleAM,INDEGREE_ARRAY_START_X - INDEGREE_ARRAY_ELEM_WIDTH ,INDEGREE_ARRAY_START_Y + neighbor*INDEGREE_ARRAY_ELEM_HEIGHT);
					
					cmd("Step");
					indegree[neighbor] = indegree[neighbor] + 1;
					cmd("SetText", indegreeID[neighbor], indegree[neighbor]);
					cmd("SetTextColor", indegreeID[neighbor], 0xFF0000);
					cmd("Step");
					cmd("Delete", highlightCircleL);
					cmd("Delete", highlightCircleAL);
					cmd("Delete", highlightCircleAM);
					cmd("SetTextColor", indegreeID[neighbor], EDGE_COLOR);
					highlightEdge(vertex, neighbor, 0);
				}
				
			}
			cmd("SetText", message1ID, "Collect all vertices with 0 indegree onto a stack");
			cmd("SetText", stackLabelID, "Zero Indegree Vertices");

			for (vertex = 0; vertex < size; vertex++)
			{
				cmd("SetHighlight", indegreeID[vertex], 1);
				cmd("Step");
				if (indegree[vertex] == 0)
				{
					stack[stackTop] =vertex;
					cmd("CreateLabel", stackID[stackTop], vertex, INDEGREE_ARRAY_START_X - INDEGREE_ARRAY_ELEM_WIDTH, INDEGREE_ARRAY_START_Y + vertex*INDEGREE_ARRAY_ELEM_HEIGHT);
					cmd("Move", stackID[stackTop], STACK_START_X, STACK_START_Y + stackTop * STACK_HEIGHT);
					cmd("Step")
					stackTop++;
				}
				cmd("SetHighlight", indegreeID[vertex], 0);

			}
			
			cmd("SetText", topoLabelID, "Topological Order");

			
			var nextInOrder:int = 0;
			while (stackTop >  0)
			{
				stackTop--;
				var nextElem = stack[stackTop];
				cmd("SetText", message1ID, "Pop off top vertex with indegree 0, add to topological sort");
				cmd("CreateLabel", orderID[nextInOrder], nextElem, STACK_START_X, STACK_START_Y + stackTop * STACK_HEIGHT);
				cmd("Delete", stackID[stackTop]);
				cmd("Step");
				cmd("Move", orderID[nextInOrder], TOPO_ARRAY_START_X, TOPO_ARRAY_START_Y + nextInOrder * TOPO_HEIGHT);
				cmd("Step");
				cmd("SetText", message1ID, "Find all neigbors of vertex " + String(nextElem) + ", decrease their indegree.  If indegree becomes 0, add to stack");
				cmd("SetHighlight", circleID[nextElem], 1);
				cmd("Step")

				adjListIndex = 0;

				for (vertex = 0; vertex < size; vertex++)
				{
					if (adj_matrix[nextElem][vertex] >= 0)
					{
						adjListIndex++;
						highlightEdge(nextElem, vertex, 1);
						cmd("Step");

						cmd("CreateHighlightCircle", highlightCircleL, HIGHLIGHT_CIRCLE_COLOR, x_pos_logical[vertex], y_pos_logical[vertex]);
						cmd("SetLayer", highlightCircleL, 1);
						cmd("CreateHighlightCircle", highlightCircleAL, HIGHLIGHT_CIRCLE_COLOR,adj_list_x_start + adjListIndex * (adj_list_width + adj_list_spacing), adj_list_y_start + nextElem*adj_list_height);
						cmd("SetLayer", highlightCircleAL, 2);
						cmd("CreateHighlightCircle", highlightCircleAM, HIGHLIGHT_CIRCLE_COLOR,adj_matrix_x_start  + vertex * adj_matrix_width, adj_matrix_y_start - adj_matrix_height);
						cmd("SetLayer", highlightCircleAM, 3);
						
						cmd("Move", highlightCircleL,INDEGREE_ARRAY_START_X - INDEGREE_ARRAY_ELEM_WIDTH ,INDEGREE_ARRAY_START_Y + vertex*INDEGREE_ARRAY_ELEM_HEIGHT);
						
						cmd("Move", highlightCircleAL, INDEGREE_ARRAY_START_X - INDEGREE_ARRAY_ELEM_WIDTH ,INDEGREE_ARRAY_START_Y + vertex*INDEGREE_ARRAY_ELEM_HEIGHT);
						cmd("Move", highlightCircleAM,INDEGREE_ARRAY_START_X - INDEGREE_ARRAY_ELEM_WIDTH ,INDEGREE_ARRAY_START_Y + vertex*INDEGREE_ARRAY_ELEM_HEIGHT);
						
						cmd("Step");
						indegree[vertex] = indegree[vertex] - 1;
						cmd("SetText", indegreeID[vertex], indegree[vertex]);
						cmd("SetTextColor", indegreeID[vertex], 0xFF0000);
						cmd("Step");
						if (indegree[vertex] == 0)
						{
							stack[stackTop] =vertex;
							cmd("CreateLabel", stackID[stackTop], vertex, INDEGREE_ARRAY_START_X - INDEGREE_ARRAY_ELEM_WIDTH, INDEGREE_ARRAY_START_Y + vertex*INDEGREE_ARRAY_ELEM_HEIGHT);
							cmd("Move", stackID[stackTop], STACK_START_X, STACK_START_Y + stackTop * STACK_HEIGHT);
							cmd("Step");
							stackTop++;							
						}
						cmd("Delete", highlightCircleL);
						cmd("Delete", highlightCircleAL);
						cmd("Delete", highlightCircleAM);
						cmd("SetTextColor", indegreeID[vertex], EDGE_COLOR);
						highlightEdge(nextElem, vertex, 0);
						
					}
				}
				cmd("SetHighlight", circleID[nextElem], 0);

				nextInOrder++;

				
				
			}

			
			cmd("SetText", message1ID, "");
			cmd("SetText", stackLabelID, "");

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