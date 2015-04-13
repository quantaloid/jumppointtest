package  
{
	import flash.display.Shape;
	/**
	 * AS3 port of the jump point test pathfinding algorithm from Pathfinding.js
	 * https://github.com/qiao/PathFinding.js
	 * 
	 * @author Anna Zajaczkowski
	 */
	public class Pathfinder extends Shape
	{
		public var nodes:Vector.<Vector.<Node>>;
		public var numTilesX:int = 25;
		public var numTilesY:int = 25;
		
		public function Pathfinder() 
		{
			nodes = new Vector.<Vector.<Node>>();
			
			for (var ix:int = 0; ix < numTilesX; ++ix)
			{
				nodes.push(new Vector.<Node>());
				for (var iy:int = 0; iy < numTilesY; ++iy)
				{
					nodes[ix].push(new Node(ix, iy));
				}
			}
		}
		
		public function Reset():void
		{
			for (var ix:int = 0; ix < numTilesX; ++ix)
			{
				for (var iy:int = 0; iy < numTilesY; ++iy)
				{
					nodes[ix][iy].Reset();
				}
			}
		}
		
		public function FindPath(startx:int, starty:int, endx:int, endy:int):Vector.<Node>
		{
			var openList:Vector.<Node> = new Vector.<Node>();
			
			var startNode:Node = nodes[startx][starty];
			var endNode:Node = nodes[endx][endy];
			
			// set the `g` and `f` value of the start node to be 0
			startNode.g = 0;
			startNode.f = 0;
			
			// push the start node into the open list
			openList.push(startNode);
			startNode.opened = true;
			
			graphics.clear();
			
			// while the open list is not empty
			while (openList.length > 0)
			{
				// pop the position of node which has the minimum `f` value.
				var smallestf:Function = CompareF;
				openList.sort(smallestf);
				var node:Node = openList.pop();
				node.closed = true;
				
				if (node === endNode)
				{
					//trace("found a path");
					return BackTrace(endNode);
				}
				
				IdentifySuccessors(node, endNode, openList);
			}
			
			// fail to find the path
			//trace("failed to find a path");
			return null;
		}
		
		private function CompareF(node1:Node, node2:Node):int
		{
			if (node1.f < node2.f)
			{
				return 1;
			}
			else if (node1.f > node2.f)
			{
				return -1;
			}
			
			return 0;
		}
		
		private function BackTrace(node:Node):Vector.<Node>
		{
			var totalDist:Number = 0;
			var path:Vector.<Node> = new Vector.<Node>();
			while (node.parentNode)
			{
				var dx:Number = Math.abs(node.x - node.parentNode.x);
				var dy:Number = Math.abs(node.y - node.parentNode.y);
				//d:Number = Math.sqrt(dx * dx + dy * dy); // euclidean distance
				//d:Number = dx + dy; // manhattan distance
				var F:Number = Math.SQRT2 - 1;
				var d:Number = (dx < dy) ? F * dx + dy : F * dy + dx; // octile distance
				totalDist += d;
				node = node.parentNode;
				path.push(node);
			}
			trace("total distance: " + totalDist.toString());
			return path.reverse();
		}
		
		private function IdentifySuccessors(node:Node, endNode:Node, openList:Vector.<Node>):void
		{
			var neighbors:Vector.<Node> = FindNeighbors(node);
			var endx:int = endNode.x;
			var endy:int = endNode.y;
			
			for (var i:int = 0; i < neighbors.length; ++i)
			{
				var neighbor:Node = neighbors[i];
				var jumpNode:Node = Jump(neighbor.x, neighbor.y, node.x, node.y, endNode);
				
				if (jumpNode)
				{
					var jumpx:int = jumpNode.x;
					var jumpy:int = jumpNode.y;
					
					if (jumpNode.closed)
					{
						continue;
					}
					
					// include distance, as parent may not be immediately adjacent:
					var dx:Number = Math.abs(jumpx - node.x);
					var dy:Number = Math.abs(jumpy - node.y);
					//d:Number = Math.sqrt(dx * dx + dy * dy); // euclidean distance
					//d:Number = dx + dy; // manhattan distance
					var F:Number = Math.SQRT2 - 1;
					var d:Number = (dx < dy) ? F * dx + dy : F * dy + dx; // octile distance
					var nextg:Number = node.g + d; // next `g` value
					
					if (!jumpNode.opened || nextg < jumpNode.g)
					{
						jumpNode.g = nextg;
						dx = Math.abs(jumpx - endx);
						dy = Math.abs(jumpy - endy);
						jumpNode.h = (dx + dy); // use octile distance here instead of manhattan for better accuracy?
						jumpNode.f = jumpNode.g + jumpNode.h;
						jumpNode.parentNode = node;
						
						if (!jumpNode.opened)
						{
							openList.push(jumpNode);
							graphics.lineStyle(1.0, 0x33FFFF, 0.2);
							graphics.drawCircle(jumpNode.x * 20+10, jumpNode.y * 20+10, 4.0);
							graphics.lineStyle(0, 0, 0);
							trace("node added to open list (" + jumpx.toString() + ", " + jumpy.toString() + ")");
							trace("f = " + jumpNode.f.toString() + ", g = " + jumpNode.g.toString() + ", h = " + jumpNode.h);
							jumpNode.opened = true;
						}
					}
				}
			}
		}
		
		private function FindNeighbors(node:Node):Vector.<Node>
		{
			var x:int = node.x;
			var y:int = node.y;
			
			var neighbors:Vector.<Node>;
			
			// directed pruning: can ignore most neighbors, unless forced.
			if (node.parentNode != null)
			{
				neighbors = new Vector.<Node>();
				
				var px:int = node.parentNode.x;
				var py:int = node.parentNode.y;
				// get the normalized direction of travel
				var dx:Number = (x - px) / Math.max(Math.abs(x - px), 1);
				var dy:Number = (y - py) / Math.max(Math.abs(y - py), 1);
				
				// search diagonally
				if (dx !== 0 && dy !== 0) // test if either value or type are not equal to 0
				{
					if (IsWalkableAt(x, y + dy))
					{
						neighbors.push(nodes[x][y + dy]);
					}
					if (IsWalkableAt(x + dx, y))
					{
						neighbors.push(nodes[x + dx][y]);
					}
					if (IsWalkableAt(x, y + dy) || IsWalkableAt(x + dx, y))
					{
						if (IsWalkableAt(x + dx, y + dy)) // NOTE: i added this check
						{
							neighbors.push(nodes[x + dx][y + dy]);
						}
					}
					if (!IsWalkableAt(x - dx, y) && IsWalkableAt(x, y + dy))
					{
						if (IsWalkableAt(x - dx, y - dy)) // NOTE: i added this check
						{
							neighbors.push(nodes[x - dx][y + dy]);
						}
					}
					if (!IsWalkableAt(x, y - dy) && IsWalkableAt(x + dx, y))
					{
						if (IsWalkableAt(x + dx, y - dy)) // NOTE: i added this check
						{
							neighbors.push(nodes[x + dx][y - dy]);
						}
					}
				}
				// search horizontally/vertically
				else
				{
					if (dx === 0) // test if both value and type are equal
					{
						if (IsWalkableAt(x, y + dy))
						{
							neighbors.push(nodes[x][y + dy]);
							
							if (!IsWalkableAt(x + 1, y))
							{
								if (IsWalkableAt(x + 1, y + dy)) // NOTE: i added this check
								{
									neighbors.push(nodes[x + 1][y + dy]);
								}
							}
							if (!IsWalkableAt(x - 1, y))
							{
								if (IsWalkableAt(x - 1, y + dy)) // NOTE: i added this check
								{
									neighbors.push(nodes[x - 1][y + dy]);
								}
							}
						}
					}
					else
					{
						if (IsWalkableAt(x + dx, y))
						{
							neighbors.push(nodes[x + dx][y]);
							
							if (!IsWalkableAt(x, y + 1))
							{
								if (IsWalkableAt(x + dx, y + 1)) // NOTE: i added this check
								{
									neighbors.push(nodes[x + dx][y + 1]);
								}
							}
							if (!IsWalkableAt(x, y - 1))
							{
								if (IsWalkableAt(x + dx, y - 1)) // NOTE: i added this check
								{
									neighbors.push(nodes[x + dx][y - 1]);
								}
							}
						}
					}
				}
			}
			// return all neighbors
			else
			{
				neighbors = GetNeighbors(node);
			}
			
			return neighbors;
		}
		
		private function IsWalkableAt(locx:int, locy:int):Boolean
		{
			if (locx >= 0 && locy >= 0 && locx < numTilesX && locy < numTilesY
				&& nodes[locx][locy].isWalkable)
			{
				return true;
			}
			return false;
		}
		
		private function GetNeighbors(node:Node):Vector.<Node>
		{
			var x:int = node.x;
			var y:int = node.y;
			
			var s0:Boolean = false; var d0:Boolean = false;
			var s1:Boolean = false; var d1:Boolean = false;
			var s2:Boolean = false; var d2:Boolean = false;
			var s3:Boolean = false; var d3:Boolean = false;
			
			var neighbors:Vector.<Node> = new Vector.<Node>();
			
			// ↑
			if (IsWalkableAt(x, y - 1))
			{
				neighbors.push(nodes[x][y - 1]);
				s0 = true;
			}
			// →
			if (IsWalkableAt(x + 1, y)) {
				neighbors.push(nodes[x + 1][y]);
				s1 = true;
			}
			// ↓
			if (IsWalkableAt(x, y + 1)) {
				neighbors.push(nodes[x][y + 1]);
				s2 = true;
			}
			// ←
			if (IsWalkableAt(x - 1, y)) {
				neighbors.push(nodes[x - 1][y]);
				s3 = true;
			}
				
			d0 = s3 || s0;
			d1 = s0 || s1;
			d2 = s1 || s2;
			d3 = s2 || s3;
			
			// ↖
			if (d0 && IsWalkableAt(x - 1, y - 1))
			{
				neighbors.push(nodes[x - 1][y - 1]);
			}
			// ↗
			if (d1 && IsWalkableAt(x + 1, y - 1))
			{
				neighbors.push(nodes[x + 1][y - 1]);
			}
			// ↘
			if (d2 && IsWalkableAt(x + 1, y + 1))
			{
				neighbors.push(nodes[x + 1][y + 1]);
			}
			// ↙
			if (d3 && IsWalkableAt(x - 1, y + 1))
			{
				neighbors.push(nodes[x - 1][y + 1]);
			}
			
			return neighbors;
		}
		
		private function Jump(x:int, y:int, px:int, py:int, endNode:Node):Node
		{
			var dx:int = x - px;
			var dy:int = y - py;
			
			if (!IsWalkableAt(x, y))
			{
				return null;
			}
			
			/*if (trackJumpRecursion === true)
			{
				nodes[x][y].tested = true;
			}*/
			
			graphics.beginFill(0x33FFFF, 0.2);
			graphics.drawCircle(x * 20 + 10, y * 20 + 10, 1);
			graphics.endFill();
			
			if (nodes[x][y] == endNode)
			{
				return nodes[x][y];
			}
			
			// check for forced neighbors
			if (dx != 0 && dy != 0) // along the diagonal
			{
				if ((IsWalkableAt(x - dx, y + dy) && !IsWalkableAt(x - dx, y))
					|| (IsWalkableAt(x + dx, y - dy) && !IsWalkableAt(x, y - dy)))
				{
					return nodes[x][y];
				}
				
				// when moving diagonally, must check for vertical/horizontal jump points
				if (Jump(x + dx, y, x, y, endNode) || Jump(x, y + dy, x, y, endNode))
				{
					return nodes[x][y];
				}
			}
			else // horizontally/vertically
			{
				if ( dx != 0 ) // moving along x
				{ 
					if ((IsWalkableAt(x + dx, y + 1) && !IsWalkableAt(x, y + 1))
						|| (IsWalkableAt(x + dx, y - 1) && !IsWalkableAt(x, y - 1)))
					{
						return nodes[x][y];
					}
				}
				else // moving along y
				{
					if ((IsWalkableAt(x + 1, y + dy) && !IsWalkableAt(x + 1, y))
						|| (IsWalkableAt(x - 1, y + dy) && !IsWalkableAt(x - 1, y)))
					{
						return nodes[x][y];
					}
				}
			}
			
			// moving diagonally, must make sure one of the vertical/horizontal
			// neighbors is open to allow the path
			if (IsWalkableAt(x + dx, y) || IsWalkableAt(x, y + dy))
			{
				return Jump(x + dx, y + dy, x, y, endNode);
			}
			else
			{
				return null;
			}
		}
	}
}