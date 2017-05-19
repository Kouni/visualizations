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




	public class QueueLL extends AlgorithmAnimation {
		
		// Input Controls
		var enterFieldPush:TextInput;
		var pushButton:Button;
		var popButton:Button;
		var clearButton:Button;
		
		
		static const LINKED_LIST_START_X:int = 100;
		static const LINKED_LIST_START_Y:int = 200;
		static const LINKED_LIST_ELEM_WIDTH:int = 70;
		static const LINKED_LIST_ELEM_HEIGHT:int = 30;
		
		
		static const LINKED_LIST_INSERT_X = 250;
		static const LINKED_LIST_INSERT_Y = 50;
		
		static const LINKED_LIST_ELEMS_PER_LINE = 8;
		static const LINKED_LIST_ELEM_SPACING = 100;
		static const LINKED_LIST_LINE_SPACING = 100;
		
		static const TOP_POS_X = 180;
		static const TOP_POS_Y = 100;
		static const TOP_LABEL_X = 130;
		static const TOP_LABEL_Y =  100;
				
		static const TOP_ELEM_WIDTH = 30;
		static const TOP_ELEM_HEIGHT = 30;
		
		static const TAIL_POS_X = 180;
		static const TAIL_POS_Y = 500;
		static const TAIL_LABEL_X = 130;
		static const TAIL_LABEL_Y =  500;
		
		static const PUSH_LABEL_X = 50;
		static const PUSH_LABEL_Y = 30;
		static const PUSH_ELEMENT_X = 120;
		static const PUSH_ELEMENT_Y = 30;
		
		static const SIZE:int = 32;

		var arrayLabelID:Array;
		var linkedListElemID:Array;
		
		var headID :int;
		var headLabelID :int;
		
		var tailID :int;
		var tailLabelID :int;
		
		var highlight1ID:int;
		var highlight2ID:int;
		
		var arrayData:Array;
		var top:int;
		
		var leftoverLabelID:int;
		
		
		var nextIndex:int  = 0;
		
		
		const LINK_COLOR = 0x007700;
		const HIGHLIGHT_CIRCLE_COLOR = 0x007700;
		const FOREGROUND_COLOR = 0x007700;
		const BACKGROUND_COLOR = 0xEEFFEE;
		const PRINT_COLOR = FOREGROUND_COLOR;
		
		public function QueueLL(am)
		{
			super(am);
			
			
			enterFieldPush = addTextInput(2,2,100,20);
			pushButton = new Button();
			pushButton.label = "Enqueue";
			pushButton.x = 107;
			pushButton.width = 100;
			addChild(pushButton);
			
			popButton = new Button();
			popButton.label = "Dequeue";
			popButton.x = 212;
			popButton.width = 100;
			addChild(popButton);
			
			clearButton = new Button();
			clearButton.label = "Clear";
			clearButton.x = 317;
			clearButton.width = 100;
			addChild(clearButton);
					
			
			pushButton.addEventListener(MouseEvent.MOUSE_DOWN, pushCallback);
			popButton.addEventListener(MouseEvent.MOUSE_DOWN, popCallback);
			enterFieldPush.addEventListener(ComponentEvent.ENTER, pushCallback);
			clearButton.addEventListener(MouseEvent.MOUSE_DOWN, clearCallback);

			
			nextIndex = 0;
			highlight1ID = nextIndex++;
			highlight2ID = nextIndex++;
			
			linkedListElemID = new Array(SIZE);
			
			headID = nextIndex++;
			headLabelID = nextIndex++;
			
			tailID = nextIndex++;
			tailLabelID = nextIndex++;
			
			arrayData = new Array(SIZE);
			top = 0;
			leftoverLabelID = nextIndex++;

			setup();
		
		}
		
		function setup()
		{
			commands = new Array();

			cmd("CreateLabel", headLabelID, "Head", TOP_LABEL_X, TOP_LABEL_Y);
			cmd("CreateRectangle", headID, "", TOP_ELEM_WIDTH, TOP_ELEM_HEIGHT, TOP_POS_X, TOP_POS_Y);
			cmd("SetNull", headID, 1);

			
			cmd("CreateLabel", tailLabelID, "Tail", TAIL_LABEL_X, TAIL_LABEL_Y);
			cmd("CreateRectangle", tailID, "", TOP_ELEM_WIDTH, TOP_ELEM_HEIGHT, TAIL_POS_X, TAIL_POS_Y);
			cmd("SetNull", tailID, 1);
			
			cmd("CreateLabel", leftoverLabelID, "", 5, PUSH_LABEL_Y,0);
			
			animationManager.StartNewAnimation(commands);
			animationManager.skipForward();
			animationManager.clearHistory();		
			
		}
		
		
		function resetLinkedListPositions()
		{
			for (var i:int = top - 1; i >= 0; i--)
			{
				var nextX = (top - 1 - i) % LINKED_LIST_ELEMS_PER_LINE * LINKED_LIST_ELEM_SPACING + LINKED_LIST_START_X;
				var nextY = int((top - 1 - i) / LINKED_LIST_ELEMS_PER_LINE) * LINKED_LIST_LINE_SPACING + LINKED_LIST_START_Y;
				cmd("Move", linkedListElemID[i], nextX, nextY);				
			}
			
		}
		
		override function reset()
		{
			top = 0;

		}
		
		
		override function enableUI(event:AnimationStateEvent):void
		{
			pushButton.enabled = true;
			popButton.enabled = true;
			clearButton.enabled = true;

			enterFieldPush.enabled =true;
			enterFieldPush.addEventListener(ComponentEvent.ENTER, pushCallback);
			
		}
		override function disableUI(event:AnimationStateEvent):void
		{
			pushButton.enabled = false;
			popButton.enabled = false;
			clearButton.enabled = false;

			enterFieldPush.enabled = false;
			enterFieldPush.removeEventListener(ComponentEvent.ENTER, pushCallback);
			
			
		}
		
		
		
		
				
		function pushCallback(event):void
		{
			if (top < SIZE && enterFieldPush.text != "")
			{
				var pushVal = enterFieldPush.text;
				enterFieldPush.text = ""
				implementAction(enqueue, pushVal);
			}
		}
		
		
		function popCallback(event):void
		{
			if (top > 0)
			{
				implementAction(dequeue, "");
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
		

		function enqueue(elemToPush)
		{
			commands = new Array();
			
			var labPushID = nextIndex++;
			var labPushValID = nextIndex++;
			arrayData[top] = elemToPush;
			
			cmd("SetText", leftoverLabelID, "");
			
			for (var i : int = top; i > 0; i--)
			{
				arrayData[i] = arrayData[i-1];
				linkedListElemID[i] =linkedListElemID[i-1];
			}
			arrayData[0] = elemToPush;
			linkedListElemID[0] = nextIndex++;
			
			cmd("CreateLinkedList",linkedListElemID[0], "" ,LINKED_LIST_ELEM_WIDTH, LINKED_LIST_ELEM_HEIGHT, 
											   LINKED_LIST_INSERT_X, LINKED_LIST_INSERT_Y, 0.25, 0, 1, 1);

			cmd("SetNull", linkedListElemID[0], 1);
			cmd("CreateLabel", labPushID, "Enqueuing Value: ", PUSH_LABEL_X, PUSH_LABEL_Y);
			cmd("CreateLabel", labPushValID,elemToPush, PUSH_ELEMENT_X, PUSH_ELEMENT_Y);
						
			cmd("Step");

			

			cmd("Move", labPushValID, LINKED_LIST_INSERT_X, LINKED_LIST_INSERT_Y);
			
			cmd("Step");
			cmd("SetText", linkedListElemID[0], elemToPush);
			cmd("Delete", labPushValID);

			if (top == 0)
			{
				cmd("SetNull", headID, 0);
				cmd("SetNull", tailID, 0);
				cmd("connect", headID, linkedListElemID[top]);
				cmd("connect", tailID, linkedListElemID[top]);
			}
			else
			{
				cmd("SetNull", linkedListElemID[1], 0);
				cmd("Connect",  linkedListElemID[1], linkedListElemID[0]);
				cmd("Step");
				cmd("Disconnect", tailID, linkedListElemID[1]);
			}
			cmd("Connect", tailID, linkedListElemID[0]);
			
			cmd("Step");
			top = top + 1;
			resetLinkedListPositions();
			cmd("Delete", labPushID);
			cmd("Step");
			
			return commands;
		}
		
		function dequeue(ignored = "")
		{
			commands = new Array();
			
			var labPopID = nextIndex++;
			var labPopValID = nextIndex++;
			
			cmd("SetText", leftoverLabelID, "");

			
			cmd("CreateLabel", labPopID, "Dequeued Value: ", PUSH_LABEL_X, PUSH_LABEL_Y);
			cmd("CreateLabel", labPopValID,arrayData[top - 1], LINKED_LIST_START_X, LINKED_LIST_START_Y);
			
			cmd("Move", labPopValID,  PUSH_ELEMENT_X, PUSH_ELEMENT_Y);
			cmd("Step");
			cmd("Disconnect", headID, linkedListElemID[top - 1]);
			
			if (top == 1)
			{
				cmd("SetNull", headID, 1);
				cmd("SetNull", tailID, 1);
				cmd("Disconnect", tailID, linkedListElemID[top-1]);
			}
			else
			{
				cmd("Connect", headID, linkedListElemID[top-2]);
			}
			cmd("Step");
			cmd("Delete", linkedListElemID[top - 1]);
			top = top - 1;
			resetLinkedListPositions();

			cmd("Delete", labPopValID)
			cmd("Delete", labPopID);
			cmd("Delete", highlight1ID);
			cmd("SetText", leftoverLabelID, "Dequeued Value: " + arrayData[top]);


			
			return commands;
		}

		
	
		function clearAll()
		{
			commands = new Array();
			for (var i:int = 0; i < top; i++)
			{
				cmd("Delete", linkedListElemID[i]);
			}
			top = 0;
			cmd("SetNull", headID, 1);
			return commands;
					
		}
	
				
	}
}

