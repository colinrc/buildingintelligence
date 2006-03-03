import bi.ui.Icon;
import flash.filters.ColorMatrixFilter;

class bi.ui.Tabs extends bi.ui.CoreUI {
	private var clipParameters:Object = {width:1, height:1, settings:1, tabData:1, tabPosition:1, contentClips:1, activeTab:1};  

	private var tabsContent_mc:MovieClip;
	private var	tabsForeground_mc:MovieClip;
	private var	tabsBackground_mc:MovieClip;
	
	private var _tabOpacity:Number;
	private var _tabOnColour:Number;
	private var _tabOffColour:Number;
	private var _tabOffAlpha:Number;

	private var _tabPosition:String;
	private var _tabWidth:Number;
	private var _tabHeight:Number;
	private var _tabSpacing:Number;
	private var _cornerRadius:Number;
	private var _contentPadding:Number;
	
	private var _activeTabId:Number;
		
	private var _tabs_array:Array = [{name:"Tab", iconName:"atom"}];
	private var _contentClips_array:Array;
	
	/* Getters and Setters */
	
	public function set tabData(tabs_array:Array):Void {
		_tabs_array = tabs_array;
		draw();
	}

	public function get tabData():Array {
		return _tabs_array;
	}

	public function set tabPosition(tabPosition:String):Void {
		_tabPosition = tabPosition;
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
		initFromClipParameters();

		if (_tabOpacity == null) _tabOpacity =_global.settings.tabBgOpacity;
		if (_tabOnColour == null) _tabOnColour =_global.settings.tabOnColour;
		if (_tabOffColour == null) _tabOffColour =_global.settings.tabOffColour;
		if (_tabOffAlpha == null) _tabOffAlpha =_global.settings.tabOffAlpha;
		if (_tabPosition == null) _tabPosition =_global.settings.tabPosition;
		if (_tabWidth == null) _tabWidth =_global.settings.tabWidth;
		if (_tabHeight == null) _tabHeight =_global.settings.tabHeight;
		if (_tabSpacing == null) _tabSpacing =_global.settings.tabSpacing;
		if (_cornerRadius == null) _cornerRadius =_global.settings.tabCornerRadius;
		if (_contentPadding == null) _contentPadding =_global.settings.tabContentPadding;
		
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
		
		var bg_mc:MovieClip = tabsForeground_mc.createEmptyMovieClip("bg_mc", -1);
		if (_tabPosition == "left") bg_mc._x = _tabWidth;
		if (_tabPosition == "top") bg_mc._y = _tabHeight;
		bg_mc.beginFill(_tabOnColour, _tabOpacity);
		if (_tabPosition == "left" || _tabPosition == "right") bg_mc.drawRect(0, 0, __width - _tabWidth, __height, _cornerRadius);
		if (_tabPosition == "top" || _tabPosition == "bottom") bg_mc.drawRect(0, 0, __width, __height - _tabHeight, _cornerRadius);
		bg_mc.endFill();

		if (_global.settings.device != "pda" && _global.settings.showDropShadows) {
			tabsForeground_mc.filters = [_global.settings.dropShadowFilterMedium];
			tabsBackground_mc.filters = [_global.settings.dropShadowFilterMedium];
		}
		
		_contentClips_array = new Array();
		
		for (var i=0; i<_tabs_array.length; i++) {
			var tabContent_mc:MovieClip = tabsContent_mc.createEmptyMovieClip("tab" + i + "_mc", i + 100);
			tabContent_mc._x = tabContent_mc._y = _contentPadding;
			if (_tabPosition == "left") tabContent_mc._x = _tabWidth + _contentPadding;
			if (_tabPosition == "top") tabContent_mc._y = _tabHeight + _contentPadding;
			tabContent_mc.width = __width - (_contentPadding * 2);
			tabContent_mc.height = __height - (_contentPadding * 2);
			if (_tabPosition == "left" || _tabPosition == "right") tabContent_mc.width -= _tabWidth;
			if (_tabPosition == "top" || _tabPosition == "bottom") tabContent_mc.height -= _tabHeight;
			tabContent_mc._visible = false;
			_contentClips_array.push(tabContent_mc);
			
			for (var q=0; q<2; q++) {
				if (q == 0) {
					var tab_mc:MovieClip = tabsForeground_mc.createEmptyMovieClip("tab" + i + "_mc", i);
				} else {
					var tab_mc:MovieClip = tabsBackground_mc.createEmptyMovieClip("tab" + i + "_mc", i);
				}
				
				var bg_mc = tab_mc.createEmptyMovieClip("bg_mc", 0);
				bg_mc.beginFill(_tabOnColour, _tabOpacity);
				if (_tabPosition == "left") bg_mc.drawRect(0, 0, _tabWidth, _tabHeight, {tl:_cornerRadius,tr:0,bl:_cornerRadius,br:0});
				if (_tabPosition == "top") bg_mc.drawRect(0, 0, _tabWidth, _tabHeight, {tl:_cornerRadius,tr:_cornerRadius,bl:0,br:0});
				if (_tabPosition == "right") bg_mc.drawRect(0, 0, _tabWidth, _tabHeight, {tl:0,tr:_cornerRadius,bl:0,br:_cornerRadius});
				if (_tabPosition == "bottom") bg_mc.drawRect(0, 0, _tabWidth, _tabHeight, {tl:0,tr:0,bl:_cornerRadius,br:_cornerRadius});
				bg_mc.endFill();
	
				var iconSize:Number = (_tabWidth < _tabHeight) ? _tabWidth : _tabHeight;
				iconSize = Math.round(iconSize * .8);
				var icon_mc:MovieClip = tab_mc.attachMovie("bi.ui.Icon", "icon_mc", 10, {settings:{size:iconSize, iconName:_tabs_array[i].iconName}});
				icon_mc._x = Math.round((_tabWidth / 2) - (iconSize / 2));
				icon_mc._y = Math.round((_tabHeight / 2) - (iconSize / 2));;
				
				if (_tabPosition == "left" || _tabPosition == "right") tab_mc._y = i * (_tabHeight + _tabSpacing) + _cornerRadius;
				if (_tabPosition == "top" || _tabPosition == "bottom") tab_mc._x = i * (_tabWidth + _tabSpacing) + _cornerRadius;
				if (_tabPosition == "right") tab_mc._x = __width - _tabWidth;
				if (_tabPosition == "bottom") tab_mc._y = __height - _tabHeight;
					
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