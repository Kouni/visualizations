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


	public class Hash extends AlgorithmAnimation
	{
		static const MAX_HASH_LENGTH = 10;

		
		static const HASH_NUMBER_START_X = 100;
		static const HASH_X_DIFF = 7;
		static const HASH_NUMBER_START_Y = 100;
		static const HASH_ADD_START_Y = 125;
		static const HASH_INPUT_START_X = 60;
		static const HASH_INPUT_X_DIFF = 7;
		static const HASH_INPUT_START_Y = 45;
		static const HASH_ADD_LINE_Y = 145;
		static const HASH_RESULT_Y = 150;
		static const ELF_HASH_SHIFT = 10;
		
		// Input Controls
		var enterFieldInsert:TextInput;
		var enterFieldDelete:TextInput;
		var enterFieldFind:TextInput;
		var insertButton:Button;
		var deleteButton:Button;
		var findButton:Button;
		
		var hashingTypeGroup:RadioButtonGroup;
		var hashingIntegersButton:RadioButton;
		var hashingStringsButton:RadioButton;
		
		var nextIndex = 0;
		var hashingIntegers:Boolean = true;
		
		var currHash:uint;
		
		
		var hashTableVisual:Array;
		var hashTableValues:Array;
		var hashTableIndices:Array;
		
		var indexXPos:Array;
		var indexYPos:Array;
		
		var table_size;
		
		var HIGHLIGHT_COLOR = 0x0000FF;
		
		public function Hash(am)
		{
			super(am);

			commands = new Array();

			enterFieldInsert = addTextInput(2,2,80,20, false, false);
			enterFieldInsert.addEventListener(Event.CHANGE, restrictLengthHash);				
			insertButton = new Button();
			insertButton.label = "Insert";
			insertButton.x = 85;		
			insertButton.width = 80;
			addChild(insertButton);
					
			enterFieldDelete = addTextInput(170,2,80,20, false, false);
			enterFieldDelete.addEventListener(Event.CHANGE, restrictLengthHash);				
			deleteButton = new Button();
			deleteButton.label = "Delete";
			deleteButton.x = 253;
			deleteButton.width = 80;

			addChild(deleteButton);
			
			enterFieldFind = addTextInput(338,2,80,20, false, false);
			enterFieldFind.addEventListener(Event.CHANGE, restrictLengthHash);							
			findButton = new Button();
			findButton.label = "Find";
			findButton.x = 421;
			findButton.width = 80;
			addChild(findButton);

			
			hashingTypeGroup = new RadioButtonGroup("HashingType");


			hashingIntegersButton = new RadioButton();
			hashingIntegersButton.x = 510;
			hashingIntegersButton.label = "Table contains integers"
			hashingIntegersButton.width = 250;
			hashingIntegersButton.selected = true;
			hashingIntegersButton.addEventListener(Event.CHANGE, hashingTypeChangedHandler);
			hashingIntegersButton.group = hashingTypeGroup;
			addChild(hashingIntegersButton);
			
			hashingStringsButton = new RadioButton();
			hashingStringsButton.x = 510;
			hashingStringsButton.y = 20;
			hashingStringsButton.label = "Table contains strings";
			hashingStringsButton.width = 250;
			hashingStringsButton.addEventListener(Event.CHANGE, hashingTypeChangedHandler);
			hashingStringsButton.group = hashingTypeGroup;
			addChild(hashingStringsButton);
			
			
			
					
			
			insertButton.addEventListener(MouseEvent.MOUSE_DOWN, insertCallback);
			deleteButton.addEventListener(MouseEvent.MOUSE_DOWN, deleteCallback);
			findButton.addEventListener(MouseEvent.MOUSE_DOWN, findCallback);
			enterFieldDelete.addEventListener(ComponentEvent.ENTER, deleteCallback);
			enterFieldInsert.addEventListener(ComponentEvent.ENTER, insertCallback);			
			enterFieldFind.addEventListener(ComponentEvent.ENTER, findCallback);						
		}
		
		
		private function restrictLengthHash(event:Event):void 
		{
			if ( event.target.text.length > MAX_HASH_LENGTH) 
			{
				event.target.text = event.target.text.substr(0, MAX_HASH_LENGTH);
			}
		}
		
		function restrictToInegers(integerOnly = true)
		{
			fieldAcceptsIntegerOnly(enterFieldInsert, integerOnly)
			fieldAcceptsIntegerOnly(enterFieldFind, integerOnly)
			fieldAcceptsIntegerOnly(enterFieldDelete, integerOnly)
		}
		
		
		function doHash(input:String) : int
		{
			if (hashingIntegers)
			{
				var labelID1 = nextIndex++;
				var labelID2 = nextIndex++;
				var highlightID = nextIndex++;
				var index:int = int(input) % table_size;
				currHash =  int(input);
				cmd("CreateLabel", labelID1, input + " % " + String(table_size) + " = " , 100, 150);
				cmd("CreateLabel", labelID2,index, 150, 150);
				cmd("Step");
				cmd("CreateHighlightCircle", highlightID, HIGHLIGHT_COLOR, 150, 150);
				cmd("Move", highlightID, indexXPos[index], indexYPos[index]);
				cmd("Step");
				cmd("Delete", labelID1);
				cmd("Delete", labelID2);
				cmd("Delete", highlightID);
				nextIndex -= 3;
				
				return index;
								
			}
			else
			{
				var oldNextIndex = nextIndex;
				var label1= nextIndex++;
				cmd("CreateLabel", label1, "Hashing:" , 10, 45, 0);
				var wordToHashID = new Array(input.length);
				var wordToHash = new Array(input.length);
				for (var i:int = 0; i < input.length; i++)
				{
					wordToHashID[i] = nextIndex++;
					wordToHash[i] = input.charAt(i);
					cmd("CreateLabel", wordToHashID[i], wordToHash[i], HASH_INPUT_START_X + i * HASH_INPUT_X_DIFF, HASH_INPUT_START_Y, 0);
				}
				var digits = new Array(32);
				var hashValue = new Array(32);
				var nextByte = new Array(8);
				var nextByteID = new Array(8);
				var resultDigits = new Array(32);
				var floatingDigits = new Array(4);
				var floatingVals = new Array(4);

				var operatorID = nextIndex++;
				var barID = nextIndex++;
				for (i = 0; i < 32; i++)
				{
					hashValue[i] = 0;
					digits[i] = nextIndex++;
					resultDigits[i] = nextIndex++;
				}
				for (i=0; i<8; i++)
				{
					nextByteID[i] = nextIndex++;
				}
				for (i = 0; i < 4; i++)
				{
					floatingDigits[i] = nextIndex++;
				}
				cmd("Step");
				for (i = wordToHash.length-1; i >= 0; i--)
				{
					for (j = 0; j < 32; j++)
					{
						cmd("CreateLabel", digits[j],hashValue[j], HASH_NUMBER_START_X + j * HASH_X_DIFF, HASH_NUMBER_START_Y, 0);					
					}
					cmd("Delete", wordToHashID[i]);
					var nextChar = wordToHash[i].charCodeAt(0);
					for (var j:int = 7; j >= 0; j--)
					{
						nextByte[j] = nextChar % 2;
						nextChar = Math.floor((nextChar / 2));
						cmd("CreateLabel", nextByteID[j], nextByte[j], HASH_INPUT_START_X + i*HASH_INPUT_X_DIFF, HASH_INPUT_START_Y, 0);
						cmd("Move", nextByteID[j], HASH_NUMBER_START_X + (j + 24) * HASH_X_DIFF, HASH_ADD_START_Y);
					}
					cmd("Step");
					cmd("CreateRectangle", barID, "", 32 * HASH_X_DIFF, 0, HASH_NUMBER_START_X, HASH_ADD_LINE_Y,"left","bottom");
					cmd("CreateLabel", operatorID, "+", HASH_NUMBER_START_X, HASH_ADD_START_Y, 0);
					cmd("Step");

					var carry:int = 0;
					for (j = 7; j>=0; j--)
					{
						hashValue[j+24] = hashValue[j+24] + nextByte[j] + carry;
						if (hashValue[j+24] > 1)
						{
							hashValue[j+24] = hashValue[j+24] - 2;
							carry = 1;
						}
						else
						{
							carry = 0;
						}						
					}
					for (j = 23; j>=0; j--)
					{
						hashValue[j] = hashValue[j]  + carry;
						if (hashValue[j] > 1)
						{
							hashValue[j] = hashValue[j] - 2;
							carry = 1;
						}
						else
						{
							carry = 0;
						}		
					}
					for (j = 0; j < 32; j++)
					{
						cmd("CreateLabel", resultDigits[j], hashValue[j], HASH_NUMBER_START_X + j * HASH_X_DIFF, HASH_RESULT_Y, 0);					
					}
					
					cmd("Step");
					for (j=0; j<8; j++)
					{
						cmd("Delete", nextByteID[j]);
					}
					cmd("Delete", barID);
					cmd("Delete", operatorID);
					for (j = 0; j<32; j++)
					{
						cmd("Delete", digits[j]);
						cmd("Move", resultDigits[j], HASH_NUMBER_START_X + j * HASH_X_DIFF, HASH_NUMBER_START_Y)
					}
					cmd("Step");
					if (i > 0)
					{
						for (j = 0; j < 32; j++)
						{
							cmd("Move", resultDigits[j], HASH_NUMBER_START_X + (j - 4) * HASH_X_DIFF, HASH_NUMBER_START_Y)						
						}
						cmd("Step");
						for (j = 0; j < 28; j++)
						{
							floatingVals[j] = hashValue[j];
							hashValue[j] = hashValue[j+4];
						}

						for (j = 0; j < 4; j++)
						{
							cmd("Move", resultDigits[j], HASH_NUMBER_START_X + (j + ELF_HASH_SHIFT) * HASH_X_DIFF, HASH_ADD_START_Y);
							hashValue[j+28] = 0;
							cmd("CreateLabel", floatingDigits[j],0, HASH_NUMBER_START_X + (j + 28) * HASH_X_DIFF, HASH_NUMBER_START_Y,0);
							if (floatingVals[j])
							{
								hashValue[j + ELF_HASH_SHIFT] = 1 - hashValue[j + ELF_HASH_SHIFT];
							}
						}
						cmd("CreateRectangle", barID, "", 32 * HASH_X_DIFF, 0, HASH_NUMBER_START_X, HASH_ADD_LINE_Y,"left","bottom");
						cmd("CreateLabel", operatorID, "XOR", HASH_NUMBER_START_X, HASH_ADD_START_Y, 0);
						cmd("Step");
						for (j = 0; j < 32; j++)
						{
							cmd("CreateLabel", digits[j], hashValue[j], HASH_NUMBER_START_X + j * HASH_X_DIFF, HASH_RESULT_Y, 0);					
						}
						cmd("Step");

						cmd("Delete", operatorID);
						cmd("Delete", barID);
						for (j = 0; j<32; j++)
						{
							cmd("Delete", resultDigits[j]);
							cmd("Move", digits[j], HASH_NUMBER_START_X + j * HASH_X_DIFF, HASH_NUMBER_START_Y)
						}
						for (j = 0; j < 4; j++)
						{
							cmd("Delete", floatingDigits[j]);
						}
						cmd("Step");
						for (j = 0; j<32; j++)
						{
							cmd("Delete", digits[j]);
						}
					} 
					else
					{
						for (j = 0; j<32; j++)
						{
							cmd("Delete", resultDigits[j]);
						}
					}
					
				}
				cmd("Delete", label1);
				for (j = 0; j < 32; j++)
				{
					cmd("CreateLabel", digits[j],hashValue[j], HASH_NUMBER_START_X + j * HASH_X_DIFF, HASH_NUMBER_START_Y, 0);
				}
				currHash = 0;
				for (j=0; j < 32; j++)
				{
					currHash = currHash * 2 + hashValue[j];
				}
				cmd("CreateLabel", label1, " = " + String(currHash), HASH_NUMBER_START_X + 32*HASH_X_DIFF, HASH_NUMBER_START_Y, 0);
				cmd("Step");
				for (j = 0; j < 32; j++)
				{
					cmd("Delete", digits[j]);
				}
				
				var label2 = nextIndex++;
				cmd("SetText", label1, String(currHash) + " % " +  String(table_size) + " = ");
				index = currHash % table_size;
				cmd("CreateLabel", label2, index,  HASH_NUMBER_START_X + 32*HASH_X_DIFF + 105, HASH_NUMBER_START_Y, 0);
				cmd("Step");
				highlightID = nextIndex++;
				cmd("CreateHighlightCircle", highlightID, HIGHLIGHT_COLOR,  HASH_NUMBER_START_X + 30*HASH_X_DIFF + 120,  HASH_NUMBER_START_Y+ 15);
				cmd("Move", highlightID, indexXPos[index], indexYPos[index]);
				cmd("Step");
				cmd("Delete", highlightID);
				cmd("Delete", label1);
				cmd("Delete", label2);
				//nextIndex = oldNextIndex;

				return index;
			}
		}
		
		
		private function hashingTypeChangedHandler(event:Event):void 
		{
			if ( event.currentTarget.selected )
			{
				
				if (event.currentTarget == hashingIntegersButton && !hashingIntegers)
				{
					hashingIntegers = true;
					restrictToInegers(hashingIntegers);
					resetAll();
				}
				else if (event.currentTarget == hashingStringsButton && hashingIntegers)
				{
					hashingIntegers = false;
					restrictToInegers(hashingIntegers);
					resetAll();
				}
			}
		}
		
		
				
		function resetAll()
		{
			
		}
		function insertCallback(event):void
		{
			var insertedValue:String = enterFieldInsert.text;
			if (insertedValue != "")
			{
				enterFieldInsert.text = "";
				implementAction(insertElement,insertedValue);
			}
		}
		
		function deleteCallback(event):void
		{
			var deletedValue:String = enterFieldDelete.text;
			if (deletedValue != "")
			{
				enterFieldDelete.text = "";
				implementAction(deleteElement,deletedValue);		
			}
		}
		
		function findCallback(event):void
		{
			var findValue:String = enterFieldFind.text;
			if (findValue != "")
			{
				enterFieldFind.text = "";
				implementAction(findElement,findValue);		
			}
		}

		
		
		
		
		
		function insertElement(elem)
		{
			
		}
	
		function deleteElement(elem)
		{
			
			
		}
		function findElement(elem)
		{
			
		}
	
			
		
		// NEED TO OVERRIDE IN PARENT
		override function reset()
		{
			// Throw an error?
		}
		
		
		
		
		override function enableUI(event:AnimationStateEvent):void
		{
			deleteButton.enabled = true;
			insertButton.enabled = true;
			findButton.enabled = true;
			enterFieldInsert.enabled = true;
			enterFieldDelete.enabled = true;
			enterFieldFind.enabled =true;
			hashingIntegersButton.enabled = true;
			hashingStringsButton.enabled = true;
			enterFieldDelete.addEventListener(ComponentEvent.ENTER, deleteCallback);
			enterFieldInsert.addEventListener(ComponentEvent.ENTER, insertCallback);
			enterFieldFind.addEventListener(ComponentEvent.ENTER, findCallback);
		}
		override function disableUI(event:AnimationStateEvent):void
		{
			insertButton.enabled = false;
			deleteButton.enabled = false;
			findButton.enabled = false;
			hashingIntegersButton.enabled = false;
			hashingStringsButton.enabled = false;

			enterFieldDelete.removeEventListener(ComponentEvent.ENTER, deleteCallback);
			enterFieldInsert.removeEventListener(ComponentEvent.ENTER, insertCallback);
			enterFieldFind.removeEventListener(ComponentEvent.ENTER, findCallback);
			enterFieldInsert.enabled = false;
			enterFieldDelete.enabled = false;
			enterFieldFind.enabled = false;
		}
	}
}