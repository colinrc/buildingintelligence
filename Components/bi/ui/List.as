import bi.ui.Icon;

class bi.ui.List extends  bi.ui.CoreUI {
	private var clipParameters:Object = {settings:1, width:1, height:1, label:1}; 

	private var bg_mc:MovieClip;
	private var mask_mc:MovieClip;
	private var listItems_mc:MovieClip;
	
	private var _data_array:Array;

	private var _enabled:Boolean = true;
	private var _selectedIndex:Number;
	
	private var _bgColour:Number;
	private var _bgOpacity:Number;
	private var _cornerRadius:Number;
	private var _padding:Number;
	private var _itemFont:String;
	private var _itemFontSize:Number;
	private var _itemFontColour:Number;
	private var _itemBgOpacity:Number;
	private var _itemBgColour1:Number;
	private var _itemBgColour2:Number;
	private var _itemHeight:Number;
	private var _itemSpacing:Number;
	private var _itemCornerRadius:Number;
	
	/* Getters and Setters */
	
	public function get selectedItem():Object {
		return _data_array[_selectedIndex];
	}
	
	public function set selectedIndex(index:Number):Number {
		var oldIndex = _selectedIndex;
		listItems_mc["row" + oldIndex + "_mc"].label_txt.textColor = _global.settings.listItemFontColour;
		if (index != oldIndex) {
			_selectedIndex = index;
		} else {
			_selectedIndex = null;
		}
		
		if (_selectedIndex != null) {
			listItems_mc["row" + index + "_mc"].label_txt.textColor = 0xFFCC00;
			dispatchEvent({type:"change", target:this});
		}
	}
	
	public function get selectedIndex():Number {
		return _selectedIndex;
	}

	public function set selectedValue(val):Void {
		for (var i=0; i<_data_array.length; i++) {
			if (_data_array[i].value == val) {
				selectedIndex = i;
				break;
			}
		}
	}
	
	public function set selectedLabel(label:String):Void {
		for (var i=0; i<_data_array.length; i++) {
			if (_data_array[i].label == label) {
				selectedIndex = i;
				break;
			}
		}
	}
	
	public function set dataProvider(provider:Array):Void {
		_data_array = provider;
		draw();
	}

	public function set enabled(enabled:Boolean):Void {
		_enabled = enabled;
	}

	public function get enabled():Boolean {
		return _enabled;
	}

	public function set font(font:String):Void {
		if (font != undefined) {
			_itemFont = font;
		}
	}
	
	/* Constructor */
	
	function List() {
		initFromClipParameters();

		_data_array = new Array();
		
		if (_bgColour == null) _bgColour = _global.settings.listBgColour;
		if (_bgOpacity == null) _bgOpacity = _global.settings.listBgOpacity;
		if (_cornerRadius == null) _cornerRadius = _global.settings.listCornerRadius;
		if (_padding == null) _padding = _global.settings.listPadding;
		if (_itemFont == null) _itemFont = _global.settings.listItemFont;
		if (_itemFontColour == null) _itemFontColour = _global.settings.listItemFontColour;
		if (_itemFontSize == null) _itemFontSize = _global.settings.listItemFontSize;
		if (_itemBgOpacity == null) _itemBgOpacity = _global.settings.listItemBgOpacity;
		if (_itemBgColour1 == null) _itemBgColour1 = _global.settings.listItemBgColour1;
		if (_itemBgColour2 == null) _itemBgColour2 = _global.settings.listItemBgColour2;
		if (_itemHeight == null) _itemHeight = _global.settings.listItemHeight;
		if (_itemSpacing == null) _itemSpacing = _global.settings.listItemSpacing;
		if (_itemCornerRadius == null) _itemCornerRadius = _global.settings.listItemCornerRadius;
		
		createChildren();
		draw();
	}

	/* Public functions */
	public function addItem(item:Object):Void {
		_data_array.push(item);
		draw();
	}

	public function removeItemAt(index:Number):Void {
	}

	public function removeAll():Void {
		_data_array = new Array();
		draw();
	}

	
	/* Private functions */
	
	private function init():Void {	
	}

	private function createChildren():Void {
	}
  
	private function draw():Void {
		if (!__width) return;
		
		createEmptyMovieClip("bg_mc", 10);
		
		bg_mc.beginFill(_bgColour, _bgOpacity);
		bg_mc.drawRect(0, 0, __width, __height, _cornerRadius);
		bg_mc.endFill();
		
		if (_global.settings.device != "pda" && _global.settings.showDropShadows) {
			bg_mc.filters = [_global.settings.dropShadowFilterSmall];
		}
		
		createEmptyMovieClip("listItems_mc", 20);
		listItems_mc._x = listItems_mc._y = 0;
		
		createEmptyMovieClip("mask_mc", 30);
		mask_mc.beginFill(0xFFFFFF);
		mask_mc.drawRect(0, 0, __width, __height, _cornerRadius);
		mask_mc.endFill();
		mask_mc._visible = false;
		
		listItems_mc.setMask(mask_mc);
			
		for (var i=0; i<_data_array.length; i++) {
			var row_mc:MovieClip = listItems_mc.createEmptyMovieClip("row" + i + "_mc", i);
			
			var listBg_mc:MovieClip = row_mc.createEmptyMovieClip("bg_mc", 0);
			if (i % 2) {
				listBg_mc.beginFill(_itemBgColour2, _itemBgOpacity);
			} else {
				listBg_mc.beginFill(_itemBgColour1, _itemBgOpacity);
			}
			listBg_mc.drawRect(0, 0, __width, _itemHeight);
			listBg_mc.endFill();
	
			if (_data_array[i].iconName != undefined) {
				row_mc.attachMovie("bi.ui.Icon", "icon_mc", 10, {settings:{iconName:_data_array[i].iconName, size:_itemHeight, _x:__width - _itemHeight - 2}});
			} else {
				row_mc.createTextField("label_txt", 20, 2, 0, bg_mc._width - 2, 0);
			}
			
			row_mc.createTextField("label_txt", 20, 2, 0, bg_mc._width - 2, 0);
			
			var label_txt:TextField = row_mc.label_txt;
			var label_tf:TextFormat = new TextFormat();
			label_tf.color = _itemFontColour;
			label_tf.size = _itemFontSize;
			label_tf.font = "bi.ui.Fonts:" + _itemFont;
			label_txt.embedFonts = true;
			label_txt.selectable = false;
			label_txt.setNewTextFormat(label_tf);
			label_txt.autoSize = true;
			label_txt.text = _data_array[i].label;
			label_txt._y = Math.round((listBg_mc._height / 2) - (label_txt._height / 2));
		
			row_mc._y = i * (_itemHeight + _itemSpacing);
			
			row_mc.base = this;
			row_mc.index = i;
		    row_mc.onPress2 = function():Void {
				if (this.base.enabled) {
					this.base.selectedIndex = this.index;
				}
			}
			
			if (_global.settings.device != "pda" && _global.settings.showDropShadows) {
				label_txt.filters = [_global.settings.dropShadowFilterSmall];
			}
		}
	}
}