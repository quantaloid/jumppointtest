package  
{
	/**
	 * ...
	 * @author Anna Zajaczkowski
	 */
	public class Node 
	{
		public var x:int = 0;
		public var y:int = 0;
		public var isWalkable:Boolean = true;
		
		public var g:Number = 0;
		public var f:Number = 0;
		public var h:Number = 0;
		public var parentNode:Node = null;
		public var opened:Boolean = false;
		public var closed:Boolean = false;
		//public var tested:Boolean = false;
		
		public function Node(x_:int, y_:int) 
		{
			x = x_;
			y = y_;
		}
		
		public function Reset():void
		{
			g = 0;
			f = 0;
			h = 0;
			parentNode = null;
			opened = false;
			closed = false;
		}
	}

}