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


	public class FloydWarshall extends Graph
	{
		// Input Controls
		var startButton:Button;
		var enterFieldStart:TextInput;
		
		
		
		static const SMALL_COST_TABLE_WIDTH = 30;
		static const SMALL_COST_TABLE_HEIGHT = 30;
		static const SMALL_COST_TABLE_START_X = 40;
		static const SMALL_COST_TABLE_START_Y = 120;
		
		static const SMALL_PATH_TABLE_WIDTH = 30;
		static const SMALL_PATH_TABLE_HEIGHT = 30;
		static const SMALL_PATH_TABLE_START_X = 330;
		static const SMALL_PATH_TABLE_START_Y = 120;
		
		
		static const SMALL_NODE_1_X_POS = 50;
		static const SMALL_NODE_1_Y_POS = 500;
		static const SMALL_NODE_2_X_POS = 150;
		static const SMALL_NODE_2_Y_POS = 450;
		static const SMALL_NODE_3_X_POS = 250;
		static const SMALL_NODE_3_Y_POS = 500;
		
		static const SMALL_MESSAGE_X = 400;
		static const SMALL_MESSAGE_Y = 450;
		
		static const LARGE_COST_TABLE_WIDTH = 20;
		static const LARGE_COST_TABLE_HEIGHT = 20;
		static const LARGE_COST_TABLE_START_X = 40;
		static const LARGE_COST_TABLE_START_Y = 120;
		
		static const LARGE_PATH_TABLE_WIDTH = 20;
		static const LARGE_PATH_TABLE_HEIGHT = 20;
		static const LARGE_PATH_TABLE_START_X = 500;
		static const LARGE_PATH_TABLE_START_Y = 120;
		

		
		static const LARGE_NODE_1_X_POS = 50;
		static const LARGE_NODE_1_Y_POS = 600;
		static const LARGE_NODE_2_X_POS = 150;
		static const LARGE_NODE_2_Y_POS = 550;
		static const LARGE_NODE_3_X_POS = 250;
		static const LARGE_NODE_3_Y_POS = 600;
		
		static const LARGE_MESSAGE_X = 300;
		static const LARGE_MESSAGE_Y = 550;


		var cost_table_width:int;
		var cost_table_height:int;
		var cost_table_start_x:int;
		var cost_table_start_y:int;

		var path_table_width:int;
		var path_table_height:int;
		var path_table_start_x:int;
		var path_table_start_y:int;

		var costTable:Array;
		var pathTable:Array;
		var costTableID:Array;
		var pathTableID:Array;
		
		var pathIndexXID:Array;
		var pathIndexYID:Array;
		var costIndexXID:Array;
		var costIndexYID:Array;
		
		var node_1_x_pos:int;
		var node_1_y_pos:int;
		var node_2_x_pos:int;
		var node_2_y_pos:int;
		var node_3_x_pos:int;
		var node_3_y_pos:int;
		
		var message_x:int;
		var message_y:int;

		var node1ID:int;
		var node2ID:int;
		var node3ID:int;
		
		function FloydWarshall(am)
		{
			showEdgeCosts = true;
			directed = false;

			startButton = new Button();
			startButton.label = "Run Floyd-Warshall";
			startButton.x = 2;			
			startButton.y = 2;
			startButton.width = 200;
			addChild(startButton);
						
			startButton.addEventListener(MouseEvent.MOUSE_DOWN, startCallback);
			super(am);
			
		}
		
		
		override function graphSizeChangedHandler(event:Event):void 
		{
			if ( event.currentTarget.selected )
			{
				if (event.currentTarget == smallGraphButton && size != SMALL_SIZE)
				{
					animationManager.resetAll();
					animationManager.setAllLayers(0,currentLayer);
					adjMatrixRepButton.enabled = true;
					adjListRepButton.enabled = true;
					logicalRepButton.enabled = true;
					setup_small();
				}
				else if (event.currentTarget == largeGraphButton && size != LARGE_SIZE)
				{
					animationManager.resetAll();
					adjMatrixRepButton.enabled = false;
					adjListRepButton.enabled = false;
					logicalRepButton.enabled = false;
					setup_large();
					animationManager.setAllLayers(0);
				}
			}
		}
		
		
		function getCostLabel(value, alwaysUseINF:Boolean = false):String
		{
			if (value >= 0)
			{
				return String(value);
			}
			else if (size == SMALL_SIZE || alwaysUseINF)
			{
				return "INF";
			}
			else
			{
				return ""
			}			
		}
		
		override function setup_small()
		{
			cost_table_width = SMALL_COST_TABLE_WIDTH;
			cost_table_height = SMALL_COST_TABLE_HEIGHT;
			cost_table_start_x = SMALL_COST_TABLE_START_X;
			cost_table_start_y = SMALL_COST_TABLE_START_Y;
			
			path_table_width = SMALL_PATH_TABLE_WIDTH;
			path_table_height = SMALL_PATH_TABLE_HEIGHT;
			path_table_start_x = SMALL_PATH_TABLE_START_X;
			path_table_start_y = SMALL_PATH_TABLE_START_Y;
			
			node_1_x_pos = SMALL_NODE_1_X_POS;
			node_1_y_pos = SMALL_NODE_1_Y_POS;
			node_2_x_pos = SMALL_NODE_2_X_POS;
			node_2_y_pos = SMALL_NODE_2_Y_POS;
			node_3_x_pos = SMALL_NODE_3_X_POS;
			node_3_y_pos = SMALL_NODE_3_Y_POS;
			
			message_x = SMALL_MESSAGE_X;
			message_y = SMALL_MESSAGE_Y;
			super.setup_small();
		}
		
		override function setup_large()
		{
			cost_table_width = LARGE_COST_TABLE_WIDTH;
			cost_table_height = LARGE_COST_TABLE_HEIGHT;
			cost_table_start_x = LARGE_COST_TABLE_START_X;
			cost_table_start_y = LARGE_COST_TABLE_START_Y;
			
			path_table_width = LARGE_PATH_TABLE_WIDTH;
			path_table_height = LARGE_PATH_TABLE_HEIGHT;
			path_table_start_x = LARGE_PATH_TABLE_START_X;
			path_table_start_y = LARGE_PATH_TABLE_START_Y;
			
			node_1_x_pos = LARGE_NODE_1_X_POS;
			node_1_y_pos = LARGE_NODE_1_Y_POS;
			node_2_x_pos = LARGE_NODE_2_X_POS;
			node_2_y_pos = LARGE_NODE_2_Y_POS;
			node_3_x_pos = LARGE_NODE_3_X_POS;
			node_3_y_pos = LARGE_NODE_3_Y_POS;
			
			message_x = LARGE_MESSAGE_X;
			message_y = LARGE_MESSAGE_Y;
			
			super.setup_large();
		}

		
		override function setup() : void
		{
			super.setup();
			commands = new Array();
			
			costTable = new Array(size);
			pathTable = new Array(size);
			costTableID = new Array(size);
			pathTableID = new Array(size);
			pathIndexXID = new Array(size);
			pathIndexYID = new Array(size);
			costIndexXID = new Array(size);
			costIndexYID = new Array(size);
			
			node1ID = nextIndex++;
			node2ID = nextIndex++;
			node3ID = nextIndex++;
						
			for (var i:int = 0; i < size; i++)
			{
				costTable[i] = new Array(size);
				pathTable[i] = new Array(size);
				costTableID[i] = new Array(size);
				pathTableID[i] = new Array(size);
				
			}
			
			var costTableHeader:int = nextIndex++;
			var pathTableHeader:int = nextIndex++;
			
			cmd("CreateLabel", costTableHeader, "Cost Table", cost_table_start_x, cost_table_start_y - 2*cost_table_height, 0);
			cmd("CreateLabel", pathTableHeader, "Path Table", path_table_start_x, path_table_start_y - 2*path_table_height, 0);
		
			for (i= 0; i < size; i++)
			{
				pathIndexXID[i] = nextIndex++;
				pathIndexYID[i] = nextIndex++;
				costIndexXID[i] = nextIndex++;
				costIndexYID[i] = nextIndex++;
				cmd("CreateLabel", pathIndexXID[i], i, path_table_start_x + i * path_table_width, path_table_start_y - path_table_height);
				cmd("SetTextColor", pathIndexXID[i], 0x0000FF);
				cmd("CreateLabel", pathIndexYID[i], i, path_table_start_x   - path_table_width, path_table_start_y + i * path_table_height);
				cmd("SetTextColor", pathIndexYID[i], 0x0000FF);
				
				cmd("CreateLabel", costIndexXID[i], i, cost_table_start_x + i * cost_table_width, cost_table_start_y - cost_table_height);
				cmd("SetTextColor", costIndexXID[i], 0x0000FF);
				cmd("CreateLabel", costIndexYID[i], i, cost_table_start_x - cost_table_width, cost_table_start_y + i * cost_table_height);
				cmd("SetTextColor", costIndexYID[i], 0x0000FF);
				for (var j = 0; j < size; j++)
				{
					costTable[i][j] = adj_matrix[i][j];
					if (costTable[i][j] >= 0)
					{
						pathTable[i][j] = i;
					}
					else
					{
						pathTable[i][j] = -1
					}
					costTableID[i][j] = nextIndex++;
					pathTableID[i][j] = nextIndex++;
					cmd("CreateRectangle", costTableID[i][j], getCostLabel(costTable[i][j], true), cost_table_width, cost_table_height, cost_table_start_x + j* cost_table_width, cost_table_start_y + i*cost_table_height);
					cmd("CreateRectangle", pathTableID[i][j], pathTable[i][j], path_table_width, path_table_height, path_table_start_x + j* path_table_width, path_table_start_y + i*path_table_height);
				}
			}
			animationManager.StartNewAnimation(commands);
			animationManager.skipForward();
			animationManager.clearHistory();
			if (size == LARGE_SIZE)
			{
				animationManager.setAllLayers(0);
			}

		}
		
		function startCallback(event)
		{
			var insertedValue:String;

			implementAction(doFloydWarshall,"");
		}

			
		function doFloydWarshall(startVertex)
		{
			commands = new Array();
			
			var oldIndex= nextIndex;
			var messageID  = nextIndex++;
			var moveLabel1ID = nextIndex++;
			var moveLabel2ID = nextIndex++;
			
			cmd("CreateCircle", node1ID, "", node_1_x_pos, node_1_y_pos);
			cmd("CreateCircle", node2ID, "", node_2_x_pos, node_2_y_pos);
			cmd("CreateCircle", node3ID, "", node_3_x_pos, node_3_y_pos);
			cmd("CreateLabel", messageID, "",  message_x, message_y, 0); 
			
			for (var k = 0; k < size; k++)
			{
				for (var i = 0; i < size; i++)
				{
					for (var j = 0; j < size; j++)
					{
						if (i != j && j != k && i != k)
						{
							cmd("SetText", node1ID, i);
							cmd("SetText", node2ID, k);
							cmd("SetText", node3ID, j);
							cmd("Connect",node1ID, node2ID, 0x009999, -0.1, 1, getCostLabel(costTable[i][k], true))
							cmd("Connect",node2ID, node3ID, 0x9900CC, -0.1, 1, getCostLabel(costTable[k][j], true))
							cmd("Connect",node1ID, node3ID, 0xCC0000, 0, 1, getCostLabel(costTable[i][j], true))
							cmd("SetHighlight", costTableID[i][k], 1);
							cmd("SetHighlight", costTableID[k][j], 1);
							cmd("SetHighlight", costTableID[i][j], 1);
							cmd("SetTextColor", costTableID[i][k], 0x009999);
							cmd("SetTextColor", costTableID[k][j], 0x9900CC);
							cmd("SetTextColor", costTableID[i][j], 0xCC0000);
							if (costTable[i][k] >= 0 && costTable[k][j] >= 0)
							{
								if (costTable[i][j] < 0 || costTable[i][k] + costTable[k][j] < costTable[i][j])
								{							
									cmd("SetText", messageID, getCostLabel(costTable[i][k], true) + " + " +  getCostLabel(costTable[k][j], true) + " < " + getCostLabel(costTable[i][j], true));
									cmd("Step");
									costTable[i][j] = costTable[i][k] + costTable[k][j];
									cmd("SetText", pathTableID[i][j], "");
									cmd("SetText", costTableID[i][j], "");
									cmd("CreateLabel", moveLabel1ID, pathTable[k][j],  path_table_start_x + j* path_table_width, path_table_start_y + k*path_table_height);
									cmd("Move", moveLabel1ID, path_table_start_x + j* path_table_width, path_table_start_y + i*path_table_height)						
									cmd("CreateLabel", moveLabel2ID,costTable[i][j],  message_x, message_y);
									cmd("Move", moveLabel2ID, cost_table_start_x + j* cost_table_width, cost_table_start_y + i*cost_table_height)						
									pathTable[i][j] = pathTable[k][j];
									cmd("Step");
									cmd("SetText", costTableID[i][j], costTable[i][j]);
									cmd("SetText", pathTableID[i][j], pathTable[i][j]);
									cmd("Delete", moveLabel1ID);
									cmd("Delete", moveLabel2ID);
								}
								else
								{
									cmd("SetText", messageID, "!("+getCostLabel(costTable[i][k], true) + " + " + getCostLabel(costTable[k][j], true) + " < " + getCostLabel(costTable[i][j], true) + ")");
									cmd("Step");

								}
								
							}
							else
							{
								cmd("SetText", messageID, "!("+getCostLabel(costTable[i][k], true) + " + " + getCostLabel(costTable[k][j], true) + " < " + getCostLabel(costTable[i][j], true) + ")");								
								cmd("Step");
							}
							cmd("SetTextColor", costTableID[i][k], 0x000000);
							cmd("SetTextColor", costTableID[k][j], 0x000000);
							cmd("SetTextColor", costTableID[i][j], 0x000000);
							cmd("Disconnect",node1ID, node2ID)
							cmd("Disconnect",node2ID, node3ID)
							cmd("Disconnect",node1ID, node3ID)
							cmd("SetHighlight", costTableID[i][k], 0);
							cmd("SetHighlight", costTableID[k][j], 0);
							cmd("SetHighlight", costTableID[i][j], 0);
						}
					}
					
					
				}
			}
			cmd("Delete", node1ID);
			cmd("Delete", node2ID);
			cmd("Delete", node3ID);
			cmd("Delete", messageID);
			nextIndex = oldIndex;

			
			
			return commands
		}
		
	}
}