import bi.ui.Icon;
import flash.filters.ColorMatrixFilter;

class bi.ui.Tabs extends bi.ui.CoreUI {
	private var tabsContent_mc:MovieClip;
	private var tabsMask_mc:MovieClip;
	private var	tabsForeground_mc:MovieClip;
	private var	tabsBackground_mc:MovieClip;
	
	private var _tabOpacity:Number;
	private var _tabOnColour:Number;
	private var _tabOffColour:Number;
	private var _tabOffAlpha:Number;

	private var _position:String;
	private var _displayAs:String;
	private var _tabWidth:Number;
	private var _tabHeight:Number;
	private var _tabSpacing:Number;
	private var _cornerRadius:Number;
	private var _contentPadding:Number;
	
	private var _font:String;
	private var _fontSize:Number;
	private var _fontColour:Number;
	
	private var _activeTabId:Number;
		
	private var _tabs_array:Array = [];
	private var _contentClips_array:Array;
	
	/* Getters and Setters */
	
	public function set tabData(tabs_array:Array):Void {
		_tabs_array = tabs_array;
		draw();
	}

	public function get tabData():Array {
		return _tabs_array;
	}

	public function set tabOpacity(tabOpacity:Number):Void {
		_tabOpacity = tabOpacity;
	}
	
	public function set tabOnColour(tabOnColour:Number):Void {
		_tabOnColour = tabOnColour;
	}
	
	public function set tabOffColour(tabOffColour:Number):Void {
		_tabOffColour = tabOffColour;
	}
	
	public function set tabOffAlpha(tabOffAlpha:Number):Void {
		_tabOffAlpha = tabOffAlpha;
	}
	
	public function set tabPosition(position:String):Void {
		_position = position;
	}

	public function set tabDisplayAs(displayAs:String):Void {
		_displayAs = displayAs;
	}
	
	public function set tabWidth(tabWidth:Number):Void {
		_tabWidth = tabWidth;
	}
	
	public function set tabHeight(tabHeight:Number):Void {
		_tabHeight = tabHeight;
	}
	
	public function set tabSpacing(tabSpacing:Number):Void {
		_tabSpacing = tabSpacing;
	}
	
	public function set tabCornerRadius(cornerRadius:Number):Void {
		_cornerRadius = cornerRadius;
	}
	
	public function set contentPadding(contentPadding:Number):Void {
		_contentPadding = contentPadding;
	}
	
	public function get contentClips():Array {
		return _contentClips_array;
	}
	
	public function set activeTab(id:Number):Void {
		var oldId:Number = _activeTabId;
		tabsForeground_mc["tab" + oldId + "_mc"]._visible = false;
		tabsContent_mc["tab" + oldId + "_mc"]._visible = false;
		tabsBackground_mc["tab" + oldId + "_mc"]._visible = true;
		
		tabsForeground_mc["tab" + id + "_mc"]._visible = true;
		tabsContent_mc["tab" + id + "_mc"]._visible = true;
		tabsBackground_mc["tab" + id + "_mc"]._visible = false;
		
		_activeTabId = id;
		
		var eventObj = new Object();
		eventObj.type = "changeTab";
		eventObj.target = this;
		eventObj.oldTab = tabsContent_mc["tab" + oldId + "_mc"];
		eventObj.newTab = tabsContent_mc["tab" + id + "_mc"];
		eventObj.id = id;
		eventObj.oldId = oldId;
		for (var i in _tabs_array[id]) {
			eventObj[i] = _tabs_array[id][i];
		}
		dispatchEvent(eventObj);
	}

	public function get activeTab():Number {
		return _activeTabId;
	}
	
	/* Constructor */
	
	function Tabs() {
		if (_tabOpacity == null) _tabOpacity = _global.settings.tabBgOpacity;
		if (_tabOnColour == null) _tabOnColour = _global.settings.tabOnColour;
		if (_tabOffColour == null) _tabOffColour = _global.settings.tabOffColour;
		if (_tabOffAlpha == null) _tabOffAlpha = _global.settings.tabOffAlpha;
		if (_position == null) _position = _global.settings.tabPosition;
		if (_displayAs == null) _displayAs = _global.settings.tabDisplayAs;
		if (_tabWidth == null) _tabWidth = _global.settings.tabWidth;
		if (_tabHeight == null) _tabHeight = _global.settings.tabHeight;
		if (_tabSpacing == null) _tabSpacing = _global.settings.tabSpacing;
		if (_cornerRadius == null) _cornerRadius = _global.settings.tabCornerRadius;
		if (_contentPadding == null) _contentPadding = _global.settings.tabContentPadding;
		
		if (_font == null) _font = _global.settings.tabFont;
		if (_fontColour == null) _fontColour = _global.settings.tabFontColour;
		if (_fontSize == null) _fontSize = _global.settings.tabFontSize;
		
		createChildren();
		draw();
	}

	/* Private Functions */
	
	private function init():Void {
	}

	private function createChildren():Void {
	}
  
	private function draw():Void {
		if (!__width || !__height) return;
		
		//trace("drawing tabs");
		
		createEmptyMovieClip("tabsBackground_mc", 10);
		createEmptyMovieClip("tabsForeground_mc", 20);
		createEmptyMovieClip("tabsContent_mc", 30);
		createEmptyMovieClip("tabsMask_mc", 40);
				
		var bg_mc:MovieClip = tabsForeground_mc.createEmptyMovieClip("bg_mc", -1);
		if (_position == "left") bg_mc._x = _tabWidth;
		if (_position == "top") bg_mc._y = _tabHeight;
		bg_mc.beginFill(_tabOnColour, _tabOpacity);
		if (_position == "left" || _position == "right") {
			bg_mc.drawRect(0, 0, __width - _tabWidth, __height, _cornerRadius);
		}
		if (_position == "top" || _position == "bottom") {
			bg_mc.drawRect(0, 0, __width, __height - _tabHeight, _cornerRadius);
		}
		bg_mc.endFill();

		if (_position == "left") tabsContent_mc._x = _tabWidth;
		if (_position == "top") tabsContent_mc._y = _tabHeight;
		
		tabsMask_mc.beginFill(0xFFCC00);
		tabsMask_mc.drawRect(tabsContent_mc._x, tabsContent_mc._y, bg_mc._width, bg_mc._height, _cornerRadius);
		tabsMask_mc.endFill();
		tabsContent_mc.setMask(tabsMask_mc);
		
		if (_global.settings.device != "pda" && _global.settings.showDropShadows) {
			tabsForeground_mc.filters = [_global.settings.dropShadowFilterMedium];
			tabsBackground_mc.filters = [_global.settings.dropShadowFilterMedium];
		}
		
		_contentClips_array = new Array();
		var lastPos = _cornerRadius;
		
		for (var i=0; i<_tabs_array.length; i++) {
			var tabContent_mc:MovieClip = tabsContent_mc.createEmptyMovieClip("tab" + i + "_mc", i + 100);
			tabContent_mc._x = tabContent_mc._y = _contentPadding;
			tabContent_mc.width = __width - (_contentPadding * 2);
			tabContent_mc.height = __height - (_contentPadding * 2);
			if (_position == "left" || _position == "right") tabContent_mc.width -= _tabWidth;
			if (_position == "top" || _position == "bottom") tabContent_mc.height -= _tabHeight;
			tabContent_mc._visible = false;
			_contentClips_array.push(tabContent_mc);
			
			for (var q=0; q<2; q++) {
				if (q == 0) {
					var tab_mc:MovieClip = tabsForeground_mc.createEmptyMovieClip("tab" + i + "_mc", i);
				} else {
					var tab_mc:MovieClip = tabsBackground_mc.createEmptyMovieClip("tab" + i + "_mc", i);
				}
				
				if (_global.settings.tabDisplayAs == "icons" && _displayAs == "icons") {
					var bg_mc = tab_mc.createEmptyMovieClip("bg_mc", 0);
					bg_mc.beginFill(_tabOnColour, _tabOpacity);
					if (_position == "left") bg_mc.drawRect(0, 0, _tabWidth, _tabHeight, {tl:_cornerRadius,tr:0,bl:_cornerRadius,br:0});
					if (_position == "top") bg_mc.drawRect(0, 0, _tabWidth, _tabHeight, {tl:_cornerRadius,tr:_cornerRadius,bl:0,br:0});
					if (_position == "right") bg_mc.drawRect(0, 0, _tabWidth, _tabHeight, {tl:0,tr:_cornerRadius,bl:0,br:_cornerRadius});
					if (_position == "bottom") bg_mc.drawRect(0, 0, _tabWidth, _tabHeight, {tl:0,tr:0,bl:_cornerRadius,br:_cornerRadius});
					bg_mc.endFill();					
					
					var iconSize:Number = (_tabWidth < _tabHeight) ? _tabWidth : _tabHeight;
					iconSize = Math.round(iconSize * .8);
					var icon_mc:MovieClip = tab_mc.attachMovie("bi.ui.Icon", "icon_mc", 10, {settings:{size:iconSize, iconName:_tabs_array[i].iconName}});
					icon_mc._x = Math.round((_tabWidth / 2) - (iconSize / 2));
					icon_mc._y = Math.round((_tabHeight / 2) - (iconSize / 2));
				} else {
					var label_txt = tab_mc.createTextField("label_txt", 200, 0, 0, 1, 1);
					var label_tf = new TextFormat();
					label_tf.color = _fontColour;
					label_tf.size = _fontSize;
					label_tf.bold = true;
					label_tf.align = (_position == "left" || _position == "right") ? _position : "center";
					label_tf.font = "bi.ui.Fonts:" + _font;
					label_txt.autoSize = true;
					label_txt.embedFonts = true;
					label_txt.selectable = false;
					label_txt.setNewTextFormat(label_tf);
					if (_global.settings.device != "pda" && _global.settings.showDropShadows) {
						label_txt.filters = [_global.settings.dropShadowFilterSmall];
					}
					label_txt.text = _tabs_array[i].name;
					
					_tabWidth =  (_position == "left" || _position == "right") ? _tabWidth : label_txt._width + 20;
					var bg_mc = tab_mc.createEmptyMovieClip("bg_mc", 0);
					bg_mc.beginFill(_tabOnColour, _tabOpacity);
					if (_position == "left") bg_mc.drawRect(0, 0, _tabWidth, _tabHeight, {tl:_cornerRadius,tr:0,bl:_cornerRadius,br:0});
					if (_position == "top") bg_mc.drawRect(0, 0, _tabWidth, _tabHeight, {tl:_cornerRadius,tr:_cornerRadius,bl:0,br:0});
					if (_position == "right") bg_mc.drawRect(0, 0, _tabWidth, _tabHeight, {tl:0,tr:_cornerRadius,bl:0,br:_cornerRadius});
					if (_position == "bottom") bg_mc.drawRect(0, 0, _tabWidth, _tabHeight, {tl:0,tr:0,bl:_cornerRadius,br:_cornerRadius});
					bg_mc.endFill();
					
					if (_position == "top" || _position == "bottom") {
						label_txt._x = Math.round((bg_mc._width/2) - (label_txt._width/2));
					} else if (_position == "left") {
						label_txt._x = 2;
					} else if (_position == "right") {
						label_txt._x = bg_mc._width - 2;
					}
					label_txt._y = Math.round((bg_mc._height/2) - (label_txt._height/2));
				}
				
				if (_position == "left" || _position == "right") tab_mc._y = i * (_tabHeight + _tabSpacing) + _cornerRadius;
				if (_position == "top" || _position == "bottom") {
					tab_mc._x = Math.round(lastPos);
					if (q != 0) lastPos += _tabWidth + _tabSpacing;
				}
				if (_position == "right") tab_mc._x = __width - _tabWidth;
				if (_position == "bottom") tab_mc._y = __height - _tabHeight;
					
				if (q == 0) {
					tab_mc._visible = false;
				} else {
					new Color(tab_mc.bg_mc).setRGB(_tabOffColour);
					//tab_mc.icon_mc._alpha = _tabOffAlpha;
					tab_mc.useHandCursor = true;
					
					if (_global.settings.device != "pda" && _global.settings.tabGreyWhenOff) {
						var myColorMatrix_filter = new ColorMatrixFilter([0.3, 0.59, 0.11, 0, 0, 0.3, 0.59, 0.11, 0, 0, 0.3, 0.59, 0.11, 0, 0, 0, 0, 0, 1, 0]);
						tab_mc.icon_mc.filters = [myColorMatrix_filter];
					}
					
					tab_mc.id = i;
					tab_mc.name = _tabs_array[i].name;
					tab_mc.enabled = _tabs_array[i].enabled;
					
					tab_mc.onRelease = function () {
						_parent._parent.activeTab = this.id;
					}
				}
			}
		}
		//activeTab = _activeTabId;
	}
}