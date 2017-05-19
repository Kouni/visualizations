package 
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.display.DisplayObjectContainer;


	public class AnimationMainLoop extends Sprite
	{

		// Holder for all animated objects.
		// All animation is done by manipulating objects in\
		// this container
		private var animatedObjects : ObjectManager;


		// Control variables for stopping / starting animation

		private var animationPaused : Boolean;
		private var doNextStep : Boolean;
		private var awaitingStep : Boolean;
		private var currentlyAnimating:Boolean;

		// Array holding the code for the animation.  This is 
		// an array of strings, each of which is an animation command
		// currentAnimation is an index into this array
		private var AnimationSteps:Array;
		private var currentAnimation:int;
		
		private var previousAnimationSteps:Array;

		// Control variables for where we are in the current animation block.
		//  currFrame holds the frame number of the current animation block,
		//  while animationBlockLength holds the length of the current animation
		//  block (in frame numbers).  
		private var currFrame:Number;
		private var animationBlockLength:Number;

		//  The animation block that is currently running.  Array of singleAnimations
		private var currentBlock:Array;

		/////////////////////////////////////
		// Variables for handling undo. 
		//////////////////////////////////// already implemented animations. 
		//  A stack of UndoBlock objects (subclassed, UndoBlock is an abstract base class)
		//  each of which can undo a single animation element
		private var undoStack:Array;

		// A stack containing the beginning of each animation block, as an index
		// into the AnimationSteps array
		private var undoAnimationStepIndices:Array;
		private var undoAnimationStepIndicesStack:Array;


		/////////////////////////////////////////////////////
		// Public Methods
		/////////////////////////////////////////////////////

		function AnimationMainLoop():void
		{
			animatedObjects = new ObjectManager();
			addChild(animatedObjects);
			currentBlock = null;
			currentlyAnimating = false;
			animationPaused = true;
			animationBlockLength = 60;
			currFrame = 0;
			awaitingStep = false;
			undoStack = new Array();
			undoAnimationStepIndices = null;
			previousAnimationSteps = new Array();
			AnimationSteps = null;
			undoAnimationStepIndicesStack = new Array();
		}
		// Pause / unpause animation
		public function SetPaused(pausedValue)
		{
			animationPaused = pausedValue;
			if (!animationPaused)
			{
				step();
			}
		}

		// Set the speed of the animation, from 0 (slow) to 100 (fast)
		public function SetSpeed(newSpeed)
		{
			animationBlockLength = 100-newSpeed + 1;
		}
		//  Start a new animation.  The input parameter commands is an array of strings,
		//  which represents the animation
		public function StartNewAnimation(commands)
		{
			if (AnimationSteps != null)
			{
				previousAnimationSteps.push(AnimationSteps);
				undoAnimationStepIndicesStack.push(undoAnimationStepIndices);
			}
			AnimationSteps = commands;
			undoAnimationStepIndices = new Array();
			currentAnimation = 0;
			startNextBlock();
			currentlyAnimating = true;
			dispatchEvent(new AnimationStateEvent(AnimationStateEvent.AnimationStarted));

		}
		
		

		// Step backwards one step.  A no-op if the animation is not currently paused
		public function stepBack()
		{
			if (awaitingStep)
			{
				awaitingStep = false;
				undoLastBlock();
			}
			else if (!currentlyAnimating && animationPaused && undoAnimationStepIndices != null)
			{
				dispatchEvent(new AnimationStateEvent(AnimationStateEvent.AnimationStarted));				
				undoLastBlock();
			}

		}
		// Step forwards one step.  A no-op if the animation is not currently paused
		public function step()
		{
			if (awaitingStep)
			{
				startNextBlock();
				currentlyAnimating = true;
			}
		}

		
		
		// Implement one step of the animation.  Must be called on each frame.
		public function oneIteration():void
		{
			if (currentlyAnimating)
			{
				currFrame = currFrame + 1;
				var i:int;
				for (i = 0; i < currentBlock.length; i++)
				{
					if (currFrame >= animationBlockLength)
					{
						animatedObjects.setNodePosition(currentBlock[i].objectID,
						                                currentBlock[i].toX,
						                                currentBlock[i].toY);
					}
					else
					{
						var objectID:int = currentBlock[i].objectID;
						var percent:Number =  1 / (animationBlockLength - currFrame);
						var newX:int = lerp(animatedObjects.nodeX(objectID), currentBlock[i].toX, percent);
						var newY:int = lerp(animatedObjects.nodeY(objectID), currentBlock[i].toY, percent);
						animatedObjects.setNodePosition(objectID,
						                                newX,
						                                newY);
					}
				}
				animatedObjects.redoEdges();
				if (currFrame >= animationBlockLength)
				{
					if (animationPaused && (currentAnimation < AnimationSteps.length))
					{
						awaitingStep = true;
						currentlyAnimating = false;
					}
					else
					{
						startNextBlock();
					}
				}
			}
		}
		
		
		
		public function skipBack()
		{
			if (undoAnimationStepIndices != null && undoAnimationStepIndices.length != 0)
			{
				var cont:Boolean = true;
				
				while (undoAnimationStepIndices.length > 1)
				{
					undoLastBlock();
					for (var i:int = 0; i < currentBlock.length; i++)
					{
						var objectID:int = currentBlock[i].objectID;
						animatedObjects.setNodePosition(objectID,
						                                currentBlock[i].toX,
						                                currentBlock[i].toY);
					}
				}
				undoLastBlock();
				animatedObjects.redoEdges();
			}			
		}
		
		public function skipForward()
		{
			while (AnimationSteps != null && currentAnimation < AnimationSteps.length)
			{
				    for (var i:int = 0; currentBlock != null && i < currentBlock.length; i++)
					{
						var objectID:int = currentBlock[i].objectID;
						animatedObjects.setNodePosition(objectID,
						                                currentBlock[i].toX,
						                                currentBlock[i].toY);
					}		
					startNextBlock();
					for (var i:int = 0; i < currentBlock.length; i++)
					{
						var objectID:int = currentBlock[i].objectID;
						animatedObjects.setNodePosition(objectID,
						                                currentBlock[i].toX,
						                                currentBlock[i].toY);
					}		
				
			}
			animatedObjects.redoEdges();
			currentlyAnimating = false;
			awaitingStep = false;
			dispatchEvent(new AnimationStateEvent(AnimationStateEvent.AnimationEnded));
		}
		
		
		
		private function undoLastBlock()
		{
			
			if (undoAnimationStepIndices.length == 0)
			{

				// Nothing on the undo stack.  Return
				return;
				
			}
			if (undoAnimationStepIndices.length > 0)
			{
				var anyAnimations:Boolean = false;
				currentAnimation = undoAnimationStepIndices.pop();
				currentBlock= new Array();
				var undo : Array = undoStack.pop();
				var i:int;
				for (i = undo.length - 1; i >= 0; i--)
				{
					var animateNext : Boolean =  undo[i].implementUndo(animatedObjects, currentBlock);
					anyAnimations = anyAnimations || animateNext;

				}
				currFrame = 0;

				// Hack:  If there are not any animations, and we are currently paused,
				// then set the current frame to the end of the anumation, so that we will
				// advance immediagely upon the next step button.  If we are not paused, then
				// animate as normal.
				if (!anyAnimations && animationPaused  )
				{
					currFrame = animationBlockLength;
				}
				currentlyAnimating = true;
				// Hack #2:  If we are undoing the last part of an animation, end the animation immediately, and
				//           return control to the user.
				if (undoAnimationStepIndices.length == 0)
				{
					for (i = 0; i < currentBlock.length; i++)
					{
						var objectID:int = currentBlock[i].objectID;
						animatedObjects.setNodePosition(objectID,
						                                currentBlock[i].toX,
						                                currentBlock[i].toY);
					}
					awaitingStep = false;
					currentlyAnimating = false;
					awaitingStep = false;
					undoAnimationStepIndices = undoAnimationStepIndicesStack.pop();
					AnimationSteps = previousAnimationSteps.pop();
					dispatchEvent(new AnimationStateEvent(AnimationStateEvent.AnimationEnded));				
					dispatchEvent(new AnimationStateEvent(AnimationStateEvent.AnimationUndo));				
					currentBlock = new Array();
				}
			}
			
		}
		private function parseBool(str):Boolean
		{
			var uppercase:String = str.toUpperCase();
			var returnVal:Boolean =  ! (uppercase == "False" || uppercase == "f" || uppercase == " 0" || uppercase == "0");
			return returnVal;

		}
		private function startNextBlock()
		{
			awaitingStep = false;
			currentBlock = new Array();
			var undoBlock : Array = new Array();
			if (currentAnimation == AnimationSteps.length )
			{
				currentlyAnimating = false;
				awaitingStep = false;
				dispatchEvent(new AnimationStateEvent(AnimationStateEvent.AnimationEnded));
				return;
			}
			undoAnimationStepIndices.push(currentAnimation);

			var foundBreak:Boolean = false;

			var anyAnimations:Boolean = false;
			while (currentAnimation < AnimationSteps.length && !foundBreak)
			{

				
				var nextCommand:Array = AnimationSteps[currentAnimation].split(",");
				if (nextCommand[0].toUpperCase() == "CREATECIRCLE")
				{
					animatedObjects.addCircleObject(int(nextCommand[1]), nextCommand[2]);
					if (nextCommand.length > 4)
					{
						animatedObjects.setNodePosition(int(nextCommand[1]), int(nextCommand[3]), int(nextCommand[4]));
						undoBlock.push(new UndoCreate(int(nextCommand[1])));
					}

				}
				else if (nextCommand[0].toUpperCase() == "CREATELABEL")
				{
					if (nextCommand.length == 6)
					{
						animatedObjects.addLabelObject(int(nextCommand[1]), nextCommand[2], parseBool(nextCommand[5]));						
					}
					else
					{
						animatedObjects.addLabelObject(int(nextCommand[1]), nextCommand[2]);
					}
					if (nextCommand.length > 4)
					{

						animatedObjects.setNodePosition(int(nextCommand[1]), int(nextCommand[3]), int(nextCommand[4]));
					}
					undoBlock.push(new UndoCreate(int(nextCommand[1])));
				}
				else if (nextCommand[0].toUpperCase() == "DELETE")
				{
					var objectID : int  = int(nextCommand[1]);
					var objectLabel : String = animatedObjects.objectLabel(objectID);
					var x : int =  animatedObjects.nodeX(objectID);
					var y : int =  animatedObjects.nodeY(objectID);
					var i : int;
					var removedEdges = animatedObjects.deleteIncident(objectID);
					if (removedEdges[0] != null)
					{
						for (i = removedEdges[0].length -1; i >= 0; i--)
						{
							undoBlock.push(new UndoConnect(objectID, removedEdges[0][i], true));
						}
					}
					if (removedEdges[1] != null)
					{
						for (i = removedEdges[1].length -1; i >= 0; i--)
						{
							undoBlock.push(new UndoConnect(removedEdges[1][i],objectID, true));
						}
					}
					undoBlock.push(new UndoDelete(objectID, objectLabel, x, y));
					animatedObjects.removeObject(objectID);
				}
				else if (nextCommand[0].toUpperCase() == "MOVE")
				{
					var nextAnim:SingleAnimation = new SingleAnimation();
					nextAnim.objectID = int(nextCommand[1]);
					nextAnim.fromX = animatedObjects.nodeX(nextAnim.objectID);
					nextAnim.fromY = animatedObjects.nodeY(nextAnim.objectID);
					nextAnim.toX = int(nextCommand[2]);
					nextAnim.toY = int(nextCommand[3]);
					currentBlock.push(nextAnim);

					undoBlock.push(new UndoMove(nextAnim.objectID, nextAnim.toX, nextAnim.toY, nextAnim.fromX, nextAnim.fromY));

					anyAnimations = true;
				}
				else if (nextCommand[0].toUpperCase() == "CONNECT")
				{
					// TODO:  Handle directed as well as undirected edges
					animatedObjects.connectEdge(int(nextCommand[1]), int (nextCommand[2]));
					undoBlock.push(new UndoConnect(int(nextCommand[1]), int (nextCommand[2]), false));
				}
				else if (nextCommand[0].toUpperCase() == "DISCONNECT")
				{
					// TODO:  Handle directed as well as undirected edges
					animatedObjects.disconnect(int(nextCommand[1]), int (nextCommand[2]));
					undoBlock.push(new UndoConnect(int(nextCommand[1]), int (nextCommand[2]), true));
				}
				else if (nextCommand[0].toUpperCase() == "SETTEXT")
				{
					var oldText:String = animatedObjects.getText(int(nextCommand[1]));
					animatedObjects.setText(int(nextCommand[1]), nextCommand[2]);
					undoBlock.push(new UndoSetText(int(nextCommand[1]), oldText));					
				}
				else if (nextCommand[0].toUpperCase() == "STEP")
				{
					foundBreak = true;
				}
				else if (nextCommand[0].toUpperCase() == "SETHIGHLIGHT")
				{
					var newHighlight:Boolean = parseBool(nextCommand[2]);
					animatedObjects.setHighlight( int(nextCommand[1]), newHighlight);
					undoBlock.push(new UndoHighlight( int(nextCommand[1]), !newHighlight));
				}
				currentAnimation = currentAnimation+1;
			}
			currFrame = 0;

			// Hack:  If there are not any animations, and we are currently paused,
			// then set the current frame to the end of the anumation, so that we will
			// advance immediagely upon the next step button.  If we are not paused, then
			// animate as normal.

			if (!anyAnimations && animationPaused  )
			{
				currFrame = animationBlockLength;
			}

			undoStack.push(undoBlock);
		}
		public function lerp(from, to, percent):int
		{
			// STOP CHANGING ME!
			var returnVal : int = (to - from) * percent + from;
			return returnVal;
			// STOP CHANGING ME!
		}

	}
}