import flash.display.BitmapData;
import mx.transitions.Tween;

#include "../../elife client/standalone/include/defaults.as"
#include "../../elife client/standalone/include/drawRect.as"

renderControlType = function () {
	var workspace_mc = this.createEmptyMovieClip("workspace_mc", 10);
	var markers_mc = workspace_mc.createEmptyMovieClip("markers_mc", 10);
	var holder_mc = workspace_mc.createEmptyMovieClip("holder_mc", 20);
	workspace_mc._x = 10;
	workspace_mc._y = 70;
	var holderWidth = 460;
	
	var rows = controlTypeData.firstChild.childNodes;
	
	var marker_mc = markers_mc.attachMovie("controlTypeEditor.rowSpacer", "rowSpacers0_mc", markers_mc.getNextHighestDepth(), {_width:holderWidth - 4, _height:4, _x:22, _y:-4, _alpha:0, type:"row"});
	marker_mc.xmlPointer = rows[0];
	
	var currentY = 0;
	for (var row=0; row<rows.length; row++) {
		//trace("new row");
		var currentX = 0;
		var items = rows[row].childNodes;
		var maxHeight = 0;
		for (var item=0; item<items.length; item++) {
			if (items[item].attributes.type == "button" || items[item].attributes.type == "toggle" || items[item].attributes.type == "slider") {
				if (_global.settings.controlButtonHeight > maxHeight) maxHeight = _global.settings.controlButtonHeight;
			} else if (items[item].attributes.type == "label") {
				if (20 > maxHeight) maxHeight = 26;				
			}
		}
		var arrow_mc = holder_mc.attachMovie("controlTypeEditor.rowArrow", "arrow" + row + "_mc", holder_mc.getNextHighestDepth());
		arrow_mc._y = currentY + (maxHeight / 2) - (arrow_mc._height / 2);
		arrow_mc.row = rows[row];
		
		arrow_mc.onRelease = function () {
			showForm("rowForm", this.row)
		}
		
		var marker_mc = markers_mc.attachMovie("controlTypeEditor.rowSpacer", "itemSpacer" + row + "_0_mc", markers_mc.getNextHighestDepth(), {_width:4, _height:maxHeight, _x:18, _y:currentY, _alpha:0, type:"item"});
		marker_mc.xmlPointer = items[0];
		
		for (var item=0; item<items.length; item++) {
			var remainingWidth = holderWidth - currentX;
			if (items[item].attributes.width == undefined) {
				var width = Math.round(remainingWidth / (items.length - item));
			} else {
				var width = Math.round(items[item].attributes.width / 100 * holderWidth);
			}
			if (items[item].attributes.type == "button") {
				var item_mc = holder_mc.attachMovie("bi.ui.Button", "button" + row + "_" + item + "_mc", holder_mc.getNextHighestDepth(), {_x:currentX + 2 + 20, _y:currentY, width:width - 4, height:_global.settings.controlButtonHeight, label:items[item].attributes.label, iconName:items[item].attributes.icon});
				item_mc.formName = "buttonForm";
			} else if (items[item].attributes.type == "toggle") {
				var item_mc = holder_mc.attachMovie("bi.ui.Button", "toggle" + row + "_" + item + "_mc", holder_mc.getNextHighestDepth(), {_x:currentX + 2 + 20, _y:currentY, width:width - 4, height:_global.settings.controlButtonHeight, label:items[item].attributes.label, iconName:items[item].attributes.icons.split(",")[0]});
				item_mc.formName = "toggleForm";
			} else if (items[item].attributes.type == "slider") {
				var item_mc = holder_mc.createEmptyMovieClip("slider" + row + "_" + item + "_mc", holder_mc.getNextHighestDepth());
				createSlider(item_mc, {width:width - 4, height:_global.settings.controlButtonHeight, icons:items[item].attributes.icons.split(",")});
				item_mc._x = currentX + 2 + 20;
				item_mc._y = currentY;
				item_mc.formName = "sliderForm";
			} else if (items[item].attributes.type == "label") {
				var item_mc = holder_mc.attachMovie("bi.ui.Label", "label" + row + "_" + item + "_mc", holder_mc.getNextHighestDepth(), {_x:currentX + 2 + 20, _y:currentY, width:width - 4, text:"label"});
				item_mc.formName = "labelForm";
			}
			
			currentX += width;
			var marker_mc = markers_mc.attachMovie("controlTypeEditor.rowSpacer", "itemSpacer" + row + "_" + (item + 1) + "_mc", markers_mc.getNextHighestDepth(), {_width:4, _height:maxHeight, _x:currentX + 18, _y:currentY, _alpha:0, type:"item"});
			if (items[item].nextSibling != null) {
				marker_mc.xmlPointer = items[item].nextSibling;
			} else {
				marker_mc.xmlPointer = items[item];
				marker_mc.isLast = true;
			}

			item_mc.xmlPointer = items[item];
			
			item_mc.onPress = function () {
				this.swapDepths(9999);
				this.startX = this._x;
				this.startY = this._y;
				this.startDrag();
				this.onMouseMove = function () {
					this._alpha = 60;
					var isOver = false;
					var markers_mc = workspace_mc.markers_mc;
					for (var i in markers_mc) {
						if (markers_mc[i].hitTest(_root._xmouse, _root._ymouse)) {
							lastOver._alpha = 0;
							markers_mc[i]._alpha = 100;
							lastOver = markers_mc[i];
							isOver = true;
							break;
						}
					}
					if (!isOver) {
						lastOver._alpha = 0;
						delete lastOver;
					}
				}
			}
			item_mc.onRelease = item_mc.onReleaseOutside = function () {
				this.stopDrag();
				this._alpha = 100;
			
				if (lastOver) {
					if (lastOver.type == "row") {
						var insertLocation = lastOver.xmlPointer;
						var newRow = new XML('<row/>').firstChild;
						var currentNode = this.xmlPointer;
						var duplicate = currentNode.cloneNode(false);
						newRow.appendChild(duplicate);
						var parent =  insertLocation.parentNode;
						if (lastOver.isLast) {
							parent.appendChild(newRow);
						} else {
							parent.insertBefore(newRow, insertLocation);
						}
						var oldParent = currentNode.parentNode;
						currentNode.removeNode();
						if (oldParent.childNodes.length == 0) {
							oldParent.removeNode();
						}
					} else {
						var insertLocation = lastOver.xmlPointer;
						var currentNode = this.xmlPointer;
						var duplicate = currentNode.cloneNode(false);
						var parent = insertLocation.parentNode;
						if (lastOver.isLast) {
							parent.appendChild(duplicate);
						} else {
							parent.insertBefore(duplicate, insertLocation);
						}
						var oldParent = currentNode.parentNode;
						currentNode.removeNode();
						if (oldParent.childNodes.length == 0) {
							oldParent.removeNode();
						}
					}
					renderControlType();
					lastOver._alpha = 0;
					delete lastOver;
				} else if (this._x != this.startX || this._y != this.startY) {
					this.enabled = false;
					var moveButton = new Tween(this, "_x", mx.transitions.easing.Regular.easeInOut, this._x, this.startX, 3);
					moveButton.target = this;
					new Tween(this, "_y", mx.transitions.easing.Regular.easeInOut, this._y, this.startY, 3);
					moveButton.onMotionFinished = function () {
						this.target.enabled = true;
					}
				}
				showForm(this.formName, this.xmlPointer)
				delete this.onMouseMove;
			}
		}
		var marker_mc = markers_mc.attachMovie("controlTypeEditor.rowSpacer", "rowSpacer" + (row + 1) + "_mc", markers_mc.getNextHighestDepth(), {_width:holderWidth - 4, _height:4, _x:22, _y:currentY + maxHeight, _alpha:0, type:"row"});
		if (rows[row].nextSibling != null) {
			marker_mc.xmlPointer = rows[row].nextSibling;
		} else {
			marker_mc.xmlPointer = rows[row];
			marker_mc.isLast = true;
		}
		
		currentY += maxHeight + 4;
	}
}

showForm = function (formName, xml) {
	var form_mc = this.attachMovie("controlTypeEditor." + formName, "form_mc", 50, {_x:510, _y:10, xml:xml});
}

loadIcons = function () {
	//trace("load icons");
	var st = getTimer();
	var iconLoader_mc = this.createEmptyMovieClip("iconLoader_mc", -9999);
	iconLoader_mc._visible = false;
	loader = new MovieClipLoader();
	loader.addListener(loader);
	loader.onLoadInit = function (mc) {
		_global.icons[mc._name] = new BitmapData(mc._width, mc._height, true, 0x00FFFFFF);
		_global.icons[mc._name].draw(mc);
		mc.removeMovieClip();
		this.loadCounter--;
		if (this.loadCounter == 0) {
			//trace("time to load " + _global.iconNames.length + " icons: " + (getTimer() - st) + "ms");
			iconLoader_mc.removeMovieClip();
			renderControlType();
		}
	}
	loader.loadPointer = 0;
	loader.loadCounter = 0;
	loader.loadNext = function () {
		var name = _global.iconNames[this.loadPointer];
		var loadClip_mc = iconLoader_mc.createEmptyMovieClip(name.split(".")[0], this.loadPointer);
		this.loadClip(iconPath + name, loadClip_mc);
		this.loadPointer++;
		this.loadCounter++;
		if (this.loadPointer < _global.iconNames.length) {
			this.loadNext();
		}
	}
	
	// load the list of icons and store them into the icon objects
	var loadIconList = new LoadVars();
	loadIconList.load(iconPath + "_icons.txt");
	loadIconList.onData = function (src) {
		_global.iconNames = src.split(chr(13) + chr(10));
		loader.loadNext();
	}
}

setIconPath = function (path) {
	iconPath = path;	
	if (_global.iconNames.length) {
		renderControlType();
	} else {
		_global.icons = new Object();
		loadIcons();
	}
}

createToolbar = function () {
	var toolbar_mc = this.createEmptyMovieClip("toolbar_mc", 30);
	toolbar_mc._x = toolbar_mc._y = 10;
	
	var items = [{type:"Button", label:"button", width:80, xml:'<item type="button" label="button" command="" extra="" />'}, {type:"Button", label:"toggle", width:80, xml:'<item type="button" label="toggle" command="" extra="" />'}];
	var xPos = 0;
	for (var i=0; i<items.length; i++) {
		var item_mc = toolbar_mc.attachMovie("bi.ui." + items[i].type, "item" + i + "_mc", toolbar_mc.getNextHighestDepth(), {_x:xPos, width:items[i].width, height:30, label:items[i].label, xml:new XML(items[i].xml).firstChild});
		item_mc.formName = items[i].type.toLowerCase() + "Form";
		
		xPos += items[i].width + 8;
		item_mc.onPress = function () {			
			this._alpha = 60;
			this.startX = this._x;
			this.startY = this._y;
			this.startDrag();
			this.onMouseMove = function () {
				var isOver = false;
				var markers_mc = workspace_mc.markers_mc;
				for (var i in markers_mc) {
					if (markers_mc[i].hitTest(_root._xmouse, _root._ymouse)) {
						lastOver._alpha = 0;
						markers_mc[i]._alpha = 100;
						lastOver = markers_mc[i];
						isOver = true;
						break;
					}
				}
				if (!isOver) {
					lastOver._alpha = 0;
					delete lastOver;
				}
			}
		}
		item_mc.onRelease = item_mc.onReleaseOutside = function () {
			this.stopDrag();
			this._alpha = 100;
			this._x = this.startX;
			this._y = this.startY;

			if (lastOver) {
				if (lastOver.type == "row") {
					var insertLocation = lastOver.xmlPointer;
					var newRow = new XML('<row/>').firstChild;
					var newNode = this.xml.cloneNode(false);
					newRow.appendChild(newNode);
					var parent =  insertLocation.parentNode;
					if (lastOver.isLast) {
						parent.appendChild(newRow);
					} else {
						parent.insertBefore(newRow, insertLocation);
					}
				} else {
					var insertLocation = lastOver.xmlPointer;
					var newNode = this.xml.cloneNode(false);
					var parent = insertLocation.parentNode;
					if (lastOver.isLast) {
						parent.appendChild(newNode);
					} else {
						parent.insertBefore(newNode, insertLocation);
					}
				}
				lastOver._alpha = 0;
				delete lastOver;
				showForm(this.formName, newNode)
				renderControlType();
			}
			
			delete this.onMouseMove;
		}
	}
}

createSlider = function (item_mc, settings) {
	var bg_mc = item_mc.createEmptyMovieClip("bg_mc",0);
	bg_mc.beginFill(0x829ECB);
	bg_mc.drawRect(0, 0, settings.width, settings.height, 4);
	bg_mc.endFill();
	
	var slider_mc = item_mc.createEmptyMovieClip("slider_mc", 50);
	slider_mc.width = settings.width - 4;
	var padding = 2;
	slider_mc._x = slider_mc._y = padding;
		
	var handle_mc = slider_mc.createEmptyMovieClip("handle_mc",10);
	var iconOn_mc = handle_mc.attachMovie("bi.ui.Icon", "iconOn_mc", 10, {iconName:settings.icons[1], size:settings.height - (padding * 2)});
	var iconOff_mc = handle_mc.attachMovie("bi.ui.Icon", "iconOff_mc", 0, {iconName:settings.icons[0], size:settings.height - (padding * 2)});
}

var windowObj = new Object()
windowObj.width = 500;
windowObj.height = 600;
windowObj.title = "";
windowObj.hideClose = true;
this.attachMovie("bi.ui.Window", "window_mc", 0, {settings:windowObj});
createToolbar();

setIconPath(iconPath);