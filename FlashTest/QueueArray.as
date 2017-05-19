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




	public class QueueArray extends AlgorithmAnimation {
		
		// Input Controls
		var enterFieldEnqueue:TextInput;
		var enqueueButton:Button;
		var dequeueButton:Button;
		var clearButton:Button;
		
		
		static const ARRAY_START_X:int = 100;
		static const ARRAY_START_Y:int = 200;
		static const ARRAY_ELEM_WIDTH:int = 50;
		static const ARRAY_ELEM_HEIGHT:int = 50;
		
		static const ARRRAY_ELEMS_PER_LINE = 15;
		static const ARRAY_LINE_SPACING = 130;
		
		static const HEAD_POS_X = 180;
		static const HEAD_POS_Y = 100;
		static const HEAD_LABEL_X = 130;
		static const HEAD_LABEL_Y =  100;
		
		static const TAIL_POS_X = 280;
		static const TAIL_POS_Y = 100;
		static const TAIL_LABEL_X = 230;
		static const TAIL_LABEL_Y =  100;
		
		static const QUEUE_LABEL_X = 50;
		static const QUEUE_LABEL_Y = 30;
		static const QUEUE_ELEMENT_X = 120;
		static const QUEUE_ELEMENT_Y = 30;
		
		static const SIZE:int = 15;

		var arrayLabelID:Array;
		var arrayID:Array;
		
		var headID :int;
		var headLabelID :int;
		
		var tailID :int;
		var tailLabelID :int;
		
		var highlight1ID:int;
		var highlight2ID:int;
		
		var arrayData:Array;
		
		var head:int;
		var tail:int;
		
		var leftoverLabelID:int;
		
		var queueElems:int = 0;
		var nextIndex:int  = 0;
		
		
		const LINK_COLOR = 0x007700;
		const HIGHLIGHT_CIRCLE_COLOR = 0x007700;
		const FOREGROUND_COLOR = 0x007700;
		const BACKGROUND_COLOR = 0xEEFFEE;
		const PRINT_COLOR = FOREGROUND_COLOR;
		
		public function QueueArray(am)
		{
			super(am);
			
			
			enterFieldEnqueue = addTextInput(2,2,100,20);
			enqueueButton = new Button();
			enqueueButton.label = "Enqueue";
			enqueueButton.x = 107;
			enqueueButton.width = 100;
			addChild(enqueueButton);
			
			dequeueButton = new Button();
			dequeueButton.label = "Dequeue";
			dequeueButton.x = 212;
			dequeueButton.width = 100;
			addChild(dequeueButton);
			
			clearButton = new Button();
			clearButton.label = "Clear";
			clearButton.x = 317;
			clearButton.width = 100;
			addChild(clearButton);
					
			
			enqueueButton.addEventListener(MouseEvent.MOUSE_DOWN, enqueueCallback);
			dequeueButton.addEventListener(MouseEvent.MOUSE_DOWN, dequeueCallback);
			enterFieldEnqueue.addEventListener(ComponentEvent.ENTER, enqueueCallback);
			clearButton.addEventListener(MouseEvent.MOUSE_DOWN, clearCallback);

			
			nextIndex = 0;
			highlight1ID = nextIndex++;
			highlight2ID = nextIndex++;
			
			arrayID = new Array(SIZE);
			arrayLabelID = new Array(SIZE);
			for (var i = 0; i < SIZE; i++)
			{

				arrayID[i]= nextIndex++;
				arrayLabelID[i]= nextIndex++;
			}
			headID = nextIndex++;
			headLabelID = nextIndex++;
			tailID = nextIndex++;
			tailLabelID = nextIndex++;
			
			arrayData = new Array(SIZE);
			head = 0;
			tail = 0;
			leftoverLabelID = nextIndex++;

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
				var xpos = (i  % ARRRAY_ELEMS_PER_LINE) * ARRAY_ELEM_WIDTH + ARRAY_START_X;
				var ypos = int(i / ARRRAY_ELEMS_PER_LINE) * ARRAY_LINE_SPACING +  ARRAY_START_Y;
				cmd("CreateRectangle", arrayID[i],"", ARRAY_ELEM_WIDTH, ARRAY_ELEM_HEIGHT,xpos, ypos);
				cmd("CreateLabel",arrayLabelID[i],  i,  xpos, ypos + ARRAY_ELEM_HEIGHT);
				cmd("SetForegroundColor", arrayLabelID[i], 0x0000FF);
				
			}
			cmd("CreateLabel", headLabelID, "Head", HEAD_LABEL_X, HEAD_LABEL_Y);
			cmd("CreateRectangle", headID, 0, ARRAY_ELEM_WIDTH, ARRAY_ELEM_HEIGHT, HEAD_POS_X, HEAD_POS_Y);

			cmd("CreateLabel", tailLabelID, "Tail", TAIL_LABEL_X, TAIL_LABEL_Y);
			cmd("CreateRectangle", tailID, 0, ARRAY_ELEM_WIDTH, ARRAY_ELEM_HEIGHT, TAIL_POS_X, TAIL_POS_Y);
			
			
			
			cmd("CreateLabel", leftoverLabelID, "", QUEUE_LABEL_X, QUEUE_LABEL_Y);

			
			animationManager.StartNewAnimation(commands);
			animationManager.skipForward();
			animationManager.clearHistory();		
			
		}
		
		
		override function reset()
		{
			head = 0;
			tail = 0;

		}
		
		
		override function enableUI(event:AnimationStateEvent):void
		{
			enqueueButton.enabled = true;
			dequeueButton.enabled = true;
			clearButton.enabled = true;

			enterFieldEnqueue.enabled =true;
			enterFieldEnqueue.addEventListener(ComponentEvent.ENTER, enqueueCallback);
			
		}
		override function disableUI(event:AnimationStateEvent):void
		{
			enqueueButton.enabled = false;
			dequeueButton.enabled = false;
			clearButton.enabled = false;

			enterFieldEnqueue.enabled = false;
			enterFieldEnqueue.removeEventListener(ComponentEvent.ENTER, enqueueCallback);
			
			
		}
		
		
		
		
				
		function enqueueCallback(event):void
		{
			if ((tail + 1) % SIZE  != head && enterFieldEnqueue.text != "")
			{
				var enqueuehVal = enterFieldEnqueue.text;
				enterFieldEnqueue.text = ""
				implementAction(enqueue, enqueuehVal);
			}
		}
		
		
		function dequeueCallback(event):void
		{
			if (head != tail)
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
		

		function enqueue(elemToEnqueue)
		{
			commands = new Array();
			
			var labEnqueueID = nextIndex++;
			var labEnqueueValID = nextIndex++;
			arrayData[tail] = elemToEnqueue;
			cmd("SetText", leftoverLabelID, "");
			
			cmd("CreateLabel", labEnqueueID, "Enqueuing Value: ", QUEUE_LABEL_X, QUEUE_LABEL_Y);
			cmd("CreateLabel", labEnqueueValID,elemToEnqueue, QUEUE_ELEMENT_X, QUEUE_ELEMENT_Y);
			
			cmd("Step");			
			cmd("CreateHighlightCircle", highlight1ID, 0x0000FF,  TAIL_POS_X, TAIL_POS_Y);
			cmd("Step");
			
			var xpos = (tail  % ARRRAY_ELEMS_PER_LINE) * ARRAY_ELEM_WIDTH + ARRAY_START_X;
			var ypos = int(tail / ARRRAY_ELEMS_PER_LINE) * ARRAY_LINE_SPACING +  ARRAY_START_Y;
			
			cmd("Move", highlight1ID, xpos, ypos + ARRAY_ELEM_HEIGHT); 				
			cmd("Step");
			
			cmd("Move", labEnqueueValID, xpos, ypos);
			cmd("Step");
			
			cmd("Settext", arrayID[tail], elemToEnqueue);
			cmd("Delete", labEnqueueValID);
			
			cmd("Delete", highlight1ID);
			
			cmd("SetHighlight", tailID, 1);
			cmd("Step");
			tail = (tail + 1) % SIZE;
			cmd("SetText", tailID, tail)
			cmd("Step");
			cmd("SetHighlight", tailID, 0);
			cmd("Delete", labEnqueueID);
			
			return commands;
		}
		
		function dequeue(ignored = "")
		{
			commands = new Array();
			
			var labDequeueID = nextIndex++;
			var labDequeueValID = nextIndex++;
			
			cmd("SetText", leftoverLabelID, "");

			
			cmd("CreateLabel", labDequeueID, "Dequeued Value: ", QUEUE_LABEL_X, QUEUE_LABEL_Y);
						
			cmd("CreateHighlightCircle", highlight1ID, 0x0000FF,  HEAD_POS_X, HEAD_POS_Y);
			cmd("Step");
			
			var xpos = (head  % ARRRAY_ELEMS_PER_LINE) * ARRAY_ELEM_WIDTH + ARRAY_START_X;
			var ypos = int(head / ARRRAY_ELEMS_PER_LINE) * ARRAY_LINE_SPACING +  ARRAY_START_Y;
			
			cmd("Move", highlight1ID, xpos, ypos + ARRAY_ELEM_HEIGHT); 				
			cmd("Step");		

			cmd("Delete", highlight1ID);

			
			var dequeuedVal = arrayData[head]
			cmd("CreateLabel", labDequeueValID,dequeuedVal, xpos, ypos);
			cmd("Settext", arrayID[head], "");
			cmd("Move", labDequeueValID,  QUEUE_ELEMENT_X, QUEUE_ELEMENT_Y);
			cmd("Step");
			
			cmd("SetHighlight", headID, 1);
			cmd("Step");
			head = (head + 1 ) % SIZE;
			cmd("SetText", headID, head)
			cmd("Step");
			cmd("SetHighlight", headID, 0);
			
			cmd("SetText", leftoverLabelID, "Dequeued Value: " + dequeuedVal);

			
			cmd("Delete", labDequeueID)
			cmd("Delete", labDequeueValID);


			
			return commands;
		}

		
	
		function clearAll()
		{
			commands = new Array();
			cmd("SetText", leftoverLabelID, "");

			for (var i:int = 0; i < SIZE; i++)
			{
				cmd("SetText", arrayID[i], "");
			}
			head = 0;
			tail = 0;
			cmd("SetText", headID, "0");
			cmd("SetText", tailID, "0");
			return commands;
					
		}
	
				
	}
}

