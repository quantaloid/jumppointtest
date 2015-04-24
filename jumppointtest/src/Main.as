package 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * jump point test
	 * @author Anna Zajaczkowski
	 */
	public class Main extends Sprite 
	{
		// A* with jump point
		private var tileSize:int = 20;
		private var pf:Pathfinder;
		private var path:Vector.<Node>;
		
		private var startx:int = 3;
		private var starty:int = 3;
		private var endx:int = 21;
		private var endy:int = 21;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			// draw grid
			/*graphics.lineStyle(1.0, 0x404040, 1.0);
			for (var i:int = 0; i <= int(stage.stageHeight / tileSize); ++i)
			{
				graphics.moveTo(0, i * tileSize);
				graphics.lineTo(stage.stageWidth, i * tileSize);
			}
			for (i = 0; i <= int(stage.stageWidth / tileSize); ++i)
			{
				graphics.moveTo(i * tileSize, 0);
				graphics.lineTo(i * tileSize, stage.stageHeight);
			}*/
			
			pf = new Pathfinder();
			addChild(pf.s);
			
			path = pf.FindPath(startx, starty, endx, endy);
			
			Redraw();
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}
		
		private var setWalkable:Boolean = false;
		
		private function onMouseDown(e:MouseEvent):void
		{
			var tilex:int = int(Math.min(Math.max(Math.floor(e.stageX / tileSize), 0), pf.numTilesX - 1));
			var tiley:int = int(Math.min(Math.max(Math.floor(e.stageY / tileSize), 0), pf.numTilesY - 1));
			
			setWalkable = !pf.nodes[tilex][tiley].isWalkable;
			
			pf.nodes[tilex][tiley].isWalkable = setWalkable;
			path = pf.FindPath(startx, starty, endx, endy);
			Redraw();
		}
		
		private function onMouseUp(e:MouseEvent):void
		{
			
		}
		
		private function onMouseMove(e:MouseEvent):void
		{
			if (e.buttonDown)
			{
				var tilex:int = int(Math.min(Math.max(Math.floor(e.stageX / tileSize), 0), pf.numTilesX - 1));
				var tiley:int = int(Math.min(Math.max(Math.floor(e.stageY / tileSize), 0), pf.numTilesY - 1));
				
				if (pf.nodes[tilex][tiley].isWalkable != setWalkable)
				{
					pf.nodes[tilex][tiley].isWalkable = setWalkable;
					path = pf.FindPath(startx, starty, endx, endy);
					Redraw();
				}
			}
		}
		
		private function Redraw():void
		{
			graphics.clear();
			
			graphics.beginFill(0xFF3366);
			for (var ix:int = 0; ix < pf.numTilesX; ++ix)
			{
				for (var iy:int = 0; iy < pf.numTilesY; ++iy)
				{
					if (!pf.nodes[ix][iy].isWalkable)
					{
						graphics.drawRect(ix * tileSize, iy * tileSize, tileSize, tileSize);
					}
				}
			}
			graphics.endFill();
			
			if (path != null && path.length > 0)
			{
				graphics.lineStyle(2.0, 0xFFFFFF, 1.0);
				//graphics.moveTo(startx * tileSize + tileSize * 0.5, starty * tileSize + tileSize * 0.5);
				graphics.moveTo(path[0].x * tileSize + tileSize * 0.5, path[0].y * tileSize + tileSize * 0.5);
				for (var i:int = 1; i < path.length; ++i)
				{
					graphics.lineTo(path[i].x * tileSize + tileSize * 0.5, path[i].y * tileSize + tileSize * 0.5);
				}
				//graphics.lineTo(endx * tileSize + tileSize * 0.5, endy * tileSize + tileSize * 0.5);
			}
			
			graphics.lineStyle(0, 0, 0);
			graphics.beginFill(0xFFFFFF, 1.0);
			graphics.drawCircle(startx * tileSize + tileSize * 0.5, starty * tileSize + tileSize * 0.5, tileSize * 0.25);
			graphics.drawCircle(endx * tileSize + tileSize * 0.5, endy * tileSize + tileSize * 0.5, tileSize * 0.25);
			graphics.endFill();
		}
	}
	
}