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


	public class ConnectedComponent extends Graph
	{
		// Input Controls
		var startButton:Button;
		var enterFieldStart:TextInput;
		
		static const AUX_ARRAY_WIDTH = 25;
		static const AUX_ARRAY_HEIGHT = 25;
		static const AUX_ARRAY_START_Y = 100;
		
		static const VISITED_START_X = 475;
		static const PARENT_START_X = 400;
		
		
		static const D_X_POS_SMALL:Array = [760, 685, 915, 610, 910, 685, 915, 760];
		static const F_X_POS_SMALL:Array = [760, 685, 915, 610, 910, 685, 915, 760];
		
		
		
		static const D_Y_POS_SMALL:Array = [118, 218, 218, 318, 318, 418, 418, 518];
		static const F_Y_POS_SMALL:Array = [132, 232, 232, 332, 332, 432, 432, 532];
		
		static const D_X_POS_LARGE:Array = [560, 660, 760, 860,
											   610, 710, 810,
										 	560, 660, 760, 860,
											   610, 710, 810,
											560, 660, 760, 860];

		static const F_X_POS_LARGE:Array = [560, 660, 760, 860,
											   610, 710, 810,
										 	560, 660, 760, 860,
											   610, 710, 810,
											560, 660, 760, 860];


		
		static const D_Y_POS_LARGE:Array = [113, 113, 113, 113,
												      213, 213, 213,
												  313, 313, 313, 313, 
												      413, 413, 413, 
												  513,  513, 513, 513];
		
		static const F_Y_POS_LARGE:Array = [137, 137, 137, 137,
												      237, 237, 237,
												  337, 337, 337, 337, 
												      437, 437, 437, 
												  537,  537, 537, 537];
		
		
		static const HIGHLIGHT_CIRCLE_COLOR = 0x000000;
		static const DFS_TREE_COLOR = 0x0000FF;
		
		var visited:Array;
		var messageID:Array;
		
		var highlightCircleL:int;
		var highlightCircleAL:int;
		var highlightCircleAM:int;
		var messageY:int;
		
		var d_x_pos : Array;
		var d_y_pos : Array;
		var f_x_pos : Array;
		var f_y_pos : Array;
		
		
		var d_times:Array;
		var f_times:Array;
		var currentTime;
		var d_timesID_L:Array;
		var f_timesID_L:Array;
		var d_timesID_AL:Array;
		var f_timesID_AL:Array;
		
		function ConnectedComponent(am)
		{
			showEdgeCosts = false;
			directed = true;
			startButton = new Button();
			startButton.label = "Run Connected Components";
			startButton.x = 2;			
			startButton.y = 2;		
			startButton.width = 150;
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
			animationManager.setAllLayers(0, currentLayer);
			animationManager.StartNewAnimation(commands);
			animationManager.skipForward();
			animationManager.clearHistory();

			highlightCircleL = nextIndex++;
		   	highlightCircleAL = nextIndex++;
			highlightCircleAM= nextIndex++
		}
		
		function startCallback(event)
		{
			implementAction(doCC,"");
		}
		
		
		
		function transpose()
		{
			for (var i:int = 0; i < size; i++)
			{
				for (var j:int = i+1; j <size; j++)
				{
					var tmp = adj_matrix[i][j];
					adj_matrix[i][j] = adj_matrix[j][i];
					adj_matrix[j][i] = tmp;
				}
			}
		}
		
		function doCC(ignored)
		{
			visited = new Array(size);
			commands = new Array();
			if (messageID != null)
			{
				for (i = 0; i < messageID.length; i++)
				{
					cmd("Delete", messageID[i]);
				}
			}
			rebuildEdges();
			messageID = new Array();
			
			d_timesID_L = new Array(size);
			f_timesID_L = new Array(size);
			d_timesID_AL = new Array(size);
			f_timesID_AL = new Array(size);
			d_times = new Array(size);
			f_times = new Array(size);
			currentTime = 1
			for (var i:int = 0; i < size; i++)
			{
				d_timesID_L[i] = nextIndex++;
				f_timesID_L[i] = nextIndex++;
				d_timesID_AL[i] = nextIndex++;
				f_timesID_AL[i] = nextIndex++;
			}

			messageY = 30;
			for (var vertex:int  = 0; vertex < size; vertex++)
			{
				if (!visited[vertex])
				{
					cmd("CreateHighlightCircle", highlightCircleL, HIGHLIGHT_CIRCLE_COLOR, x_pos_logical[vertex], y_pos_logical[vertex]);
					cmd("SetLayer", highlightCircleL, 1);
					cmd("CreateHighlightCircle", highlightCircleAL, HIGHLIGHT_CIRCLE_COLOR,adj_list_x_start - adj_list_width, adj_list_y_start + vertex*adj_list_height);
					cmd("SetLayer", highlightCircleAL, 2);
						
					cmd("CreateHighlightCircle", highlightCircleAM, HIGHLIGHT_CIRCLE_COLOR,adj_matrix_x_start  - adj_matrix_width, adj_matrix_y_start + vertex*adj_matrix_height);
					cmd("SetLayer", highlightCircleAM, 3);

					if (vertex > 0)
					{
						var breakID:int = nextIndex++;
						messageID.push(breakID);
						cmd("CreateRectangle", breakID, "", 200, 0, 10, messageY,"left","bottom");
						messageY = messageY + 20;			
					}
					dfsVisit(vertex, 10);
					cmd("Delete", highlightCircleL);
					cmd("Delete", highlightCircleAL);
					cmd("Delete", highlightCircleAM);
				}
			}
			clearEdges();
			removeAdjList();
			transpose();
			buildEdges();
			buildAdjList();
			currentTime = 1

			for (i=0; i < size; i++)
			{
				for (j = 0; j < size; j++)
				{
					if (adj_matrix[i][j] >= 0)
					{
						cmd("SetText", adj_matrixID[i][j], "1");
					}
					else
					{
						cmd("SetText", adj_matrixID[i][j], "");						
					}
				}
			}
			
			
			for (vertex = 0; vertex < size; vertex++)
			{
				visited[vertex] = false;
				cmd("Delete", d_timesID_L[vertex]);
				cmd("Delete", f_timesID_L[vertex]);
				cmd("Delete", d_timesID_AL[vertex]);
				cmd("Delete", f_timesID_AL[vertex]);
			}
			
			var sortedVertex:Array = new Array(size);
			var sortedID:Array = new Array(size);
			for (vertex = 0; vertex < size; vertex++)
			{
				sortedVertex[vertex] = vertex;
				sortedID[vertex] = nextIndex++;
				cmd("CreateLabel", sortedID[vertex], "Vertex: " + String(vertex)+ " f = " + String(f_times[vertex]), 400, 110 + vertex*20, 0);
			}
			cmd("Step");
		
			for (i = 1; i < size; i++)
			{
				var j = i;
				var tmpTime = f_times[i];
				var tmpIndex = sortedVertex[i];
				var tmpID = sortedID[i];
				while (j > 0 && f_times[j-1] < tmpTime)
				{
					f_times[j] = f_times[j-1];
					sortedVertex[j] = sortedVertex[j-1];
					sortedID[j] = sortedID[j-1];
					j--;
				}
				f_times[j] = tmpTime;
				sortedVertex[j] = tmpIndex;
				sortedID[j] = tmpID;
			}
			for (vertex = 0; vertex < size; vertex++)
			{
				cmd("Move", sortedID[vertex],  400, 110 + vertex*20);
			}
			
			for (i = 0; i < messageID.length; i++)
			{
				cmd("Delete", messageID[i]);
			}
			
			messageID = new Array();
			messageY = 30;

			var ccNum = 1;
			for (i  = 0; i < size; i++)
			{
				vertex = sortedVertex[i];
				if (!visited[vertex])
				{
					
					var breakID1:int = nextIndex++;
					messageID.push(breakID1);
					var breakID2:int = nextIndex++;
					messageID.push(breakID2);
					cmd("CreateRectangle", breakID1, "", 200, 0, 50, messageY + 8,"left","center");
					cmd("CreateLabel", breakID2, "CC #" + String(ccNum++), 10, messageY, 0);
					cmd("SetForegroundColor",breakID1 ,0x004B00);
					cmd("SetForegroundColor",breakID2 ,0x004B00);
					messageY = messageY + 20;			

					cmd("CreateHighlightCircle", highlightCircleL, HIGHLIGHT_CIRCLE_COLOR, x_pos_logical[vertex], y_pos_logical[vertex]);
					cmd("SetLayer", highlightCircleL, 1);
					cmd("CreateHighlightCircle", highlightCircleAL, HIGHLIGHT_CIRCLE_COLOR,adj_list_x_start - adj_list_width, adj_list_y_start + vertex*adj_list_height);
					cmd("SetLayer", highlightCircleAL, 2);
					dfsVisit(vertex, 75, true);
					cmd("Delete", highlightCircleL);
					cmd("Delete", highlightCircleAL);
					cmd("Delete", highlightCircleAM);
				}
				cmd("Delete", sortedID[i]);
			}
			
			for (vertex = 0; vertex < size; vertex++)
			{
				cmd("Delete", d_timesID_L[vertex]);
				cmd("Delete", f_timesID_L[vertex]);
				cmd("Delete", d_timesID_AL[vertex]);
				cmd("Delete", f_timesID_AL[vertex]);
			}
			
			return commands

		}
		
		
		override function setup_large()
		{
			d_x_pos = D_X_POS_LARGE;
			d_y_pos = D_Y_POS_LARGE;
			f_x_pos = F_X_POS_LARGE;
			f_y_pos = F_Y_POS_LARGE;
			
			super.setup_large();
		}		
		override function setup_small()
		{
			
			d_x_pos = D_X_POS_SMALL;
			d_y_pos = D_Y_POS_SMALL;
			f_x_pos = F_X_POS_SMALL;
			f_y_pos = F_Y_POS_SMALL;
			super.setup_small();
		}
		
		function dfsVisit(startVertex, messageX, printCCNum:Boolean = false)
		{
			if (printCCNum)
			{
				var ccNumberID:int = nextIndex++;
				messageID.push(ccNumberID);
				cmd("CreateLabel",ccNumberID, "Vertex " +  String(startVertex), 5, messageY, 0);
				cmd("SetForegroundColor", ccNumberID, 0x0000FF);
			}
			var nextMessage:int = nextIndex++;
			messageID.push(nextMessage);
			cmd("CreateLabel",nextMessage, "DFS(" +  String(startVertex) +  ")", messageX, messageY, 0);
			
			messageY = messageY + 20;
			if (!visited[startVertex])
			{
				d_times[startVertex] = currentTime++;
				cmd("CreateLabel", d_timesID_L[startVertex], "d = " + String(d_times[startVertex]), d_x_pos[startVertex], d_y_pos[startVertex]);				
				cmd("CreateLabel", d_timesID_AL[startVertex], "d = " + String(d_times[startVertex]), adj_list_x_start - 2*adj_list_width, adj_list_y_start + startVertex*adj_list_height - 1/4*adj_list_height);
				cmd("SetLayer",  d_timesID_L[startVertex], 1);
				cmd("SetLayer",  d_timesID_AL[startVertex], 2);

				visited[startVertex] = true;
				cmd("Step");
				for (var neighbor:int = 0; neighbor < size; neighbor++)
				{
					if (adj_matrix[startVertex][neighbor] > 0)
					{
						highlightEdge(startVertex, neighbor, 1);
						if (visited[neighbor])
						{
							nextMessage = nextIndex;
							cmd("CreateLabel", nextMessage, "Vertex " + String(neighbor) + " already visited.", messageX, messageY, 0);
						}
						cmd("Step");
						highlightEdge(startVertex, neighbor, 0);
						if (visited[neighbor])
						{
							cmd("Delete", nextMessage);
						}

						if (!visited[neighbor])
						{
							cmd("Disconnect", circleID[startVertex], circleID[neighbor]);
							cmd("Connect", circleID[startVertex], circleID[neighbor], DFS_TREE_COLOR, curve[startVertex][neighbor], 1, "");
							cmd("Move", highlightCircleL, x_pos_logical[neighbor], y_pos_logical[neighbor]);
							cmd("Move", highlightCircleAL, adj_list_x_start - adj_list_width, adj_list_y_start + neighbor*adj_list_height);
							cmd("Move", highlightCircleAM, adj_matrix_x_start - adj_matrix_width, adj_matrix_y_start + neighbor*adj_matrix_height);

							cmd("Step");
							dfsVisit(neighbor, messageX + 10, printCCNum);							
							nextMessage = nextIndex;
							cmd("CreateLabel", nextMessage, "Returning from recursive call: DFS(" + String(neighbor) + ")", messageX + 20, messageY, 0);

							cmd("Move", highlightCircleAL, adj_list_x_start - adj_list_width, adj_list_y_start + startVertex*adj_list_height);
							cmd("Move", highlightCircleL, x_pos_logical[startVertex], y_pos_logical[startVertex]);
							cmd("Move", highlightCircleAM, adj_matrix_x_start - adj_matrix_width, adj_matrix_y_start + startVertex*adj_matrix_height);
							cmd("Step");
							cmd("Delete", nextMessage);
						}
						cmd("Step");

						
						
					}
					
				}
				f_times[startVertex] = currentTime++;
				cmd("CreateLabel", f_timesID_L[startVertex],"f = " + String(f_times[startVertex]), f_x_pos[startVertex], f_y_pos[startVertex]);
				cmd("CreateLabel", f_timesID_AL[startVertex], "f = " + String(f_times[startVertex]), adj_list_x_start - 2*adj_list_width, adj_list_y_start + startVertex*adj_list_height + 1/4*adj_list_height);

				cmd("SetLayer",  f_timesID_L[startVertex], 1);
				cmd("SetLayer",  f_timesID_AL[startVertex], 2);


				
			}
			
		}
		
		// NEED TO OVERRIDE IN PARENT
		override function reset()
		{
			// Throw an error?
		}
		
		
		override function enableUI(event:AnimationStateEvent):void
		{
			startButton.enabled = true;
			newGraphButton.enabled = true;
			smallGraphButton.enabled = true;
			largeGraphButton.enabled = true;
		}
		override function disableUI(event:AnimationStateEvent):void
		{
			newGraphButton.enabled = false;
			smallGraphButton.enabled = false;
			largeGraphButton.enabled = false;
			startButton.enabled = false;
		}
		
		
	}
}