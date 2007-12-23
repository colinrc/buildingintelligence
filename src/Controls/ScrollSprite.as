package Controls
{
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	import mx.controls.scrollClasses.ScrollBar;
	import mx.events.SliderEvent;
	
	public class ScrollSprite extends Sprite
	{
	
		public var _content:Sprite;
		public var _background:Sprite;
		protected var _scrollbar:ScrollBar;
		protected var _contentHeight:Number;
	
		public var _width:Number = 0;
		public var _height:Number = 0; 

		public function ScrollSprite() {
			init();
			createChildren();
			draw();
		} 

		
		/**
		* Constructor
		*/
		public function ScrollSprite( cont:Sprite, back:Sprite scroller:Scrollbar, scrollRect:Rectangle ){
			_content = cont;
			_background = back;
			contentHeight = cont.height;
			content.scrollRect = scrollRect;
			
			scrollbar = scroller;
			
			scrollbar.addEventListener( SliderEvent.CHANGE, updateContent );
		}
		
		public function updateContent( e:SliderEvent ):void{
			var scrollable:Number = contentHeight - content.scrollRect.height;
			var sr:Rectangle = content.scrollRect.clone();
			
			sr.y = scrollable * e.percent;
			
			content.scrollRect = sr;
		}
				private function init():void { 

			_width = width;
			_height = height;
			scaleX = 1;
			scaleY = 1; 

			// remove the avatar
			removeChildAt(0);
		} 

		private function createChildren():void { 

			_background = new Sprite();
			_content = new Sprite();
			
			addChild(_background);
			addChild(_content);
		} 

		public function setSize(w:Number, h:Number):void {
			_width = w;
			_height = h;
		
		} 

	}
}