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




	public class StackLL extends AlgorithmAnimation {
		
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
		
		static const PUSH_LABEL_X = 50;
		static const PUSH_LABEL_Y = 30;
		static const PUSH_ELEMENT_X = 120;
		static const PUSH_ELEMENT_Y = 30;
		
		static const SIZE:int = 32;

		var arrayLabelID:Array;
		var linkedListElemID:Array;
		
		var topID :int;
		var topLabelID :int;
		
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
		
		public function StackLL(am)
		{
			super(am);
			
			
			enterFieldPush = addTextInput(2,2,100,20);
			pushButton = new Button();
			pushButton.label = "Push";
			pushButton.x = 107;
			pushButton.width = 100;
			addChild(pushButton);
			
			popButton = new Button();
			popButton.label = "Pop";
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

			

		
		}
		
		function setup()
		{
			commands = new Array();

			cmd("CreateLabel", topLabelID, "Top", TOP_LABEL_X, TOP_LABEL_Y);
			cmd("CreateRectangle", topID, "", TOP_ELEM_WIDTH, TOP_ELEM_HEIGHT, TOP_POS_X, TOP_POS_Y);
			cmd("SetNull", topID, 1);
			
			cmd("CreateLabel", leftoverLabelID, "", PUSH_LABEL_X, PUSH_LABEL_Y);
			
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
				implementAction(push, pushVal);
			}
		}
		
		
		function popCallback(event):void
		{
			if (top > 0)
			{
				implementAction(pop, "");
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
		

		function push(elemToPush)
		{
			commands = new Array();
			
			var labPushID = nextIndex++;
			var labPushValID = nextIndex++;
			arrayData[top] = elemToPush;
			
			cmd("SetText", leftoverLabelID, "");
			
			cmd("CreateLinkedList",linkedListElemID[top], "" ,LINKED_LIST_ELEM_WIDTH, LINKED_LIST_ELEM_HEIGHT, 
											   LINKED_LIST_INSERT_X, LINKED_LIST_INSERT_Y, 0.25, 0, 1, 1);

			cmd("CreateLabel", labPushID, "Pushing Value: ", PUSH_LABEL_X, PUSH_LABEL_Y);
			cmd("CreateLabel", labPushValID,elemToPush, PUSH_ELEMENT_X, PUSH_ELEMENT_Y);
						
			cmd("Step");

			

			cmd("Move", labPushValID, LINKED_LIST_INSERT_X, LINKED_LIST_INSERT_Y);
			
			cmd("Step");
			cmd("SetText", linkedListElemID[top], elemToPush);
			cmd("Delete", labPushValID);

			if (top == 0)
			{
				cmd("SetNull", topID, 0);
				cmd("SetNull", linkedListElemID[top], 1);
			}
			else
			{
				cmd("Connect",  linkedListElemID[top], linkedListElemID[top - 1]);
				cmd("Step");
				cmd("Disconnect", topID, linkedListElemID[top-1]);
			}
			cmd("Connect", topID, linkedListElemID[top]);
			
			cmd("Step");
			top = top + 1;
			resetLinkedListPositions();
			cmd("Delete", labPushID);
			cmd("Step");
			
			return commands;
		}
		
		function pop(ignored = "")
		{
			commands = new Array();
			
			var labPopID = nextIndex++;
			var labPopValID = nextIndex++;
			
			cmd("SetText", leftoverLabelID, "");

			
			cmd("CreateLabel", labPopID, "Popped Value: ", PUSH_LABEL_X, PUSH_LABEL_Y);
			cmd("CreateLabel", labPopValID,arrayData[top - 1], LINKED_LIST_START_X, LINKED_LIST_START_Y);
			
			cmd("Move", labPopValID,  PUSH_ELEMENT_X, PUSH_ELEMENT_Y);
			cmd("Step");
			cmd("Disconnect", topID, linkedListElemID[top - 1]);
			
			if (top == 1)
			{
				cmd("SetNull", topID, 1);
			}
			else
			{
				cmd("Connect", topID, linkedListElemID[top-2]);
				
			}
			cmd("Step");
			cmd("Delete", linkedListElemID[top - 1]);
			top = top - 1;
			resetLinkedListPositions();

			cmd("Delete", labPopValID)
			cmd("Delete", labPopID);
			cmd("Delete", highlight1ID);
			cmd("SetText", leftoverLabelID, "Popped Value: " + arrayData[top]);


			
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
			cmd("SetNull", topID, 1);
			return commands;
					
		}
	
				
	}
}

