﻿import mx.controls.Button;
import mx.containers.ScrollPane;
import mx.utils.Delegate;

class Controls.MapEditor extends MovieClip {

	private var zoomOut_btn:Button;
	private var zoom100_btn:Button;
	private var zoomIn_btn:Button;
	private var snap_btn:Button;	
	private var centre_btn:Button;
	private var add_btn:Button;
	private var move_btn:Button;
	private var delete_btn:Button;
	
	private var scrollPane_sp:ScrollPane;
	
	private var _poly:Array;
	private var _mode:String;
	private var _mapMode:String = "roomPoly";
	private var _snapToGrid:Number;
	
	private var _alerts:Array;
	private var _doors:Array;
	
	private var __width:Number;
	private var __height:Number;
	private var dispatchEvent:Function;
	public var addEventListener:Function;

	public var onMapLoad:Function;

	/* Getters and Setters */

	public function set poly(poly_str:String):Void {
		if (poly_str.split(",").length > 1) {
			_poly = poly_str.split(",");
		} else {
			_poly = new Array();
		}
		
		drawPoly();
		
		if (_mapMode == "roomPoly") drawHandles();
	}
	
	public function get poly():String {
		return _poly.join(",");
	}
	
	public function set alerts(alerts:Array):Void {
		_alerts = alerts;
		
		drawAlerts();
	}
	
	public function get alerts():Array {
		return _alerts;
	}
	
	public function set doors(doors:Array):Void {
		_doors = doors;
		
		drawDoors();
	}
	
	public function get doors():Array {
		return _doors;
	}	
	
	public function set map(url:String):Void {
		var myListener = new Object();
		myListener.scrollPane_sp = scrollPane_sp;
		myListener.onLoadInit = function (map) {
			scrollPane_sp.invalidate();
			scrollPane_sp.content.background_mc._width = map._width + 20;
			scrollPane_sp.content.background_mc._height = map._height + 20;
			scrollPane_sp._parent.focusPoly();
		}
		var my_mcl = new MovieClipLoader();
		my_mcl.addListener(myListener);
		
		scrollPane_sp.contentPath = "MapEditor:content";
		var map_mc = scrollPane_sp.content.createEmptyMovieClip("map_mc", 0);
		my_mcl.loadClip(url, map_mc);
		
		var bg_mc = scrollPane_sp.content.background_mc;
		bg_mc.obj = this;
		bg_mc._width = 300;
		bg_mc._height = 300;
		bg_mc.useHandCursor = false;
		bg_mc.onPress = function () {
			if (this.obj.mode == "addPoints") {
				var content = this.obj.scrollPane_sp.content;
				if (this.obj.mapMode == "roomPoly") {
					this.obj.addPoint(content._xmouse, content._ymouse);
				} else if (this.obj.mapMode == "alertGroups") {
					this.obj.addAlert(content._xmouse, content._ymouse);
				} else if (this.obj.mapMode == "doors") {
					this.obj.addDoor(content._xmouse, content._ymouse);
				}
			}
		}
	}
	
	public function set mode(mode:String):Void {
		add_btn.selected = move_btn.selected = delete_btn.selected = false;
		switch (mode) {
			case "addPoints":
				add_btn.selected = true;
				break;
			case "movePoints":
				move_btn.selected = true;
				break;
			case "deletePoints":
				delete_btn.selected = true;
				break;			
		}
		_mode = mode;
	}

	public function get mode():String {
		return _mode;
	}
	
	public function set snap(snap:Boolean):Void {
		if (snap) {
			_snapToGrid = 5;
		} else {
			_snapToGrid = 1;
		}
		snap_btn.selected = snap;
	}
	
	public function set mapMode(mapMode:String):Void {
		_mapMode = mapMode;
	}
	
	public function get mapMode():String {
		return _mapMode;
	}
	
	public function set width(width:Number):Void {
		setSize(width, null);
	}

	public function get width():Number {
		return __width;
	}
  
	public function set height(height:Number):Void {
		setSize(null, height);
	}

	public function get height():Number {
		return __height;
	}
		
	/* Public functions */
	
	public function setSize(width:Number, height:Number):Void {
		_xscale = 100;
		_yscale = 100;
		if (width != null) __width = width;
		if (height != null) __height = height;
		
		scrollPane_sp._width = __width;
		scrollPane_sp._height = __height - scrollPane_sp._y;
	}
	
	/* Constructor */
	
	function MapEditor() {
		mx.events.EventDispatcher.initialize(this);
		init();
	}
	
	/* Private functions */
	
	private function init():Void {
		__width = _width;
		__height = _height;
		_xscale = 100;
		_yscale = 100;
		setSize(__width, __height);
	}

	private function onLoad():Void {		
		zoomOut_btn.addEventListener("click", Delegate.create(this, zoom));
		zoom100_btn.addEventListener("click", Delegate.create(this, zoom));
		zoomIn_btn.addEventListener("click", Delegate.create(this, zoom));
		
		snap_btn.addEventListener("click", Delegate.create(this, toggleSnapping));
		centre_btn.addEventListener("click", Delegate.create(this, focusPoly));
		
		add_btn.addEventListener("click", Delegate.create(this, changeMode));
		move_btn.addEventListener("click", Delegate.create(this, changeMode));
		delete_btn.addEventListener("click", Delegate.create(this, changeMode));

		/*
		var spListener_obj = new Object();
		spListener_obj.scroll = function(eventObject) {
			trace("hPosition: " + eventObject.target.hPosition + "   MaxHPosition: " + eventObject.target.maxHPosition + ":" + eventObject.target.content._x);
		}
		scrollPane_sp.addEventListener("scroll", spListener_obj);
		*/		 
		 
		mode = "movePoints";
		snap = true;
	}
	
	private function changeMode(eventObj:Object):Void {
		switch (eventObj.target._name) {
			case "add_btn":
				mode = "addPoints";
				break;
			case "move_btn":
				mode = "movePoints";
				break;
			case "delete_btn":
				mode = "deletePoints";
				break;			
		}
	}
	
	private function toggleSnapping(eventObj:Object):Void {
		snap = (_snapToGrid != 5);
	}
	
	private function zoom(eventObj:Object):Void {
		switch (eventObj.target._name) {
			case "zoomOut_btn":
				scrollPane_sp.content._xscale = scrollPane_sp.content._yscale -= 10;
				break;
			case "zoom100_btn":
				scrollPane_sp.content._xscale = scrollPane_sp.content._yscale = 100;
				break;
			case "zoomIn_btn":
				scrollPane_sp.content._xscale = scrollPane_sp.content._yscale += 10;
				break;
		}
		scrollPane_sp.invalidate();
	}
	
	private function drawPoly():Void {
		var poly_mc:MovieClip = scrollPane_sp.content.createEmptyMovieClip("poly_mc", 10);
	
		var q = 0;
		var len = _poly.length;
		
		var minX = Number(_poly[0]);
		var minY = Number(_poly[1]);
		var maxX = Number(_poly[0]);
		var maxY = Number(_poly[1]);		
		
		poly_mc.lineStyle(1, 0xFFCC00);
		poly_mc.beginFill(0xFFCC00, (_mapMode == "roomPoly") ? 50 : 20);
		for (q; q<len; q+=2) {
			if (_poly[q] < minX) minX = Number(_poly[q]);
			if (_poly[q+1] < minY) minY = Number(_poly[q+1]);
			if (_poly[q] > maxX) maxX = Number(_poly[q]);
			if (_poly[q+1] > maxY) maxY = Number(_poly[q+1]);			
			if (q > 0) {
				poly_mc.lineTo(_poly[q], _poly[q+1]);
			} else {
				poly_mc.moveTo(_poly[0], _poly[1]);
			}
		}
		poly_mc.minX = minX;
		poly_mc.minY = minY;
		poly_mc.maxX = maxX;
		poly_mc.maxY = maxY;		
		poly_mc.midX = (maxX + minX) / 2;
		poly_mc.midY = (maxY + minY) / 2;

		poly_mc.moveTo(0, 0);
		poly_mc.endFill();
	}
	
	private function drawHandles():Void {
		var points_mc:MovieClip = scrollPane_sp.content.createEmptyMovieClip("points_mc", 5);
		
		for (var q=0; q<_poly.length; q=q+2) {
			var handle_mc = points_mc.attachMovie("handle", "handle_mc", points_mc.getNextHighestDepth());
			handle_mc._x = _poly[q];
			handle_mc._y = _poly[q+1];
			handle_mc.idx = q;
			handle_mc.obj = this;
			
			handle_mc.onPress = function () {
				if (this.obj.mode == "movePoints") {
					var scrollPane_sp = this.obj.scrollPane_sp;
					
					this.onEnterFrame = function () {
						if (this.obj._xmouse < scrollPane_sp._x) {
							scrollPane_sp.hPosition -= 10;
							if (scrollPane_sp.hPosition < 10) scrollPane_sp.hPosition = 1;
						}
						if (this.obj._ymouse < scrollPane_sp._y ) {
							scrollPane_sp.vPosition -= 10;
							if (scrollPane_sp.vPosition < 10) scrollPane_sp.vPosition = 1;
						}
						if (this.obj._xmouse > scrollPane_sp._x + scrollPane_sp.width) {
							scrollPane_sp.hPosition += 10;
							if (scrollPane_sp.hPosition > scrollPane_sp.maxHPosition + 10) scrollPane_sp.hPosition = scrollPane_sp.maxHPosition;
						}
						if (this.obj._ymouse > scrollPane_sp._y + scrollPane_sp.height) {
							scrollPane_sp.vPosition += 10;
							if (scrollPane_sp.vPosition > scrollPane_sp.maxVPosition + 10) scrollPane_sp.vPosition = scrollPane_sp.maxVPosition;
						}
						_x = points_mc._xmouse;
						_y = points_mc._ymouse;
						_x = Math.round(_x / this.obj._snapToGrid) * this.obj._snapToGrid;
						_y = Math.round(_y / this.obj._snapToGrid) * this.obj._snapToGrid;
						this.obj._poly[this.idx] = _x;
						this.obj._poly[this.idx+1] = _y;
						this.obj.drawPoly();
					}
				} else if (this.obj.mode == "deletePoints") {
					this.obj.removePoint(this.idx);
					dispatchEvent({type:"polyChange", target:this});
				}
			}
			handle_mc.onRelease = handle_mc.onReleaseOutside = function () {
				if (this.obj.mode == "movePoints") {
					this.onEnterFrame();
					delete this.onEnterFrame;			
					dispatchEvent({type:"polyChange", target:this});
				}
			}
		}
	}
	
	private function drawAlerts():Void {
		var alerts_mc:MovieClip = scrollPane_sp.content.createEmptyMovieClip("alerts_mc", 20);
		
		for (var i=0; i<_alerts.length; i++) {
			var handle_mc = alerts_mc.attachMovie("handle", "handle_mc", alerts_mc.getNextHighestDepth());
			
			if (_alerts[i].x != undefined && _alerts[i].y != undefined) {
				handle_mc._x = _alerts[i].x;
				handle_mc._y = _alerts[i].y;
			} else {
				handle_mc._x = scrollPane_sp.content.poly_mc.midX;
				handle_mc._y = scrollPane_sp.content.poly_mc.midY;
			}
			handle_mc.id = _alerts[i].id
			handle_mc.idx = i;
			handle_mc.obj = this;
			
			handle_mc.onPress = function () {
				if (this.obj.mode == "movePoints") {
					this.obj.dispatchEvent({type:"alertSelect", target:this.obj.alerts[this.idx]});
					var scrollPane_sp = this.obj.scrollPane_sp;
					
					this.onEnterFrame = function () {
						if (this.obj._xmouse < scrollPane_sp._x) {
							scrollPane_sp.hPosition -= 10;
							if (scrollPane_sp.hPosition < 10) scrollPane_sp.hPosition = 1;
						}
						if (this.obj._ymouse < scrollPane_sp._y ) {
							scrollPane_sp.vPosition -= 10;
							if (scrollPane_sp.vPosition < 10) scrollPane_sp.vPosition = 1;
						}
						if (this.obj._xmouse > scrollPane_sp._x + scrollPane_sp.width) {
							scrollPane_sp.hPosition += 10;
							if (scrollPane_sp.hPosition > scrollPane_sp.maxHPosition + 10) scrollPane_sp.hPosition = scrollPane_sp.maxHPosition;
						}
						if (this.obj._ymouse > scrollPane_sp._y + scrollPane_sp.height) {
							scrollPane_sp.vPosition += 10;
							if (scrollPane_sp.vPosition > scrollPane_sp.maxVPosition + 10) scrollPane_sp.vPosition = scrollPane_sp.maxVPosition;
						}
						_x = alerts_mc._xmouse;
						_y = alerts_mc._ymouse;
						_x = Math.round(_x / this.obj._snapToGrid) * this.obj._snapToGrid;
						_y = Math.round(_y / this.obj._snapToGrid) * this.obj._snapToGrid;
						this.obj._alerts[this.idx].x = _x;
						this.obj._alerts[this.idx].y = _y;
					}
				} else if (this.obj.mode == "deletePoints") {
					this.obj.dispatchEvent({type:"alertDelete", target:this.obj.alerts[this.idx]});
					this.obj.removeAlert(this.idx);
				}
			}
			handle_mc.onRelease = handle_mc.onReleaseOutside = function () {
				if (this.obj.mode == "movePoints") {
					this.onEnterFrame();
					delete this.onEnterFrame;
					this.obj.dispatchEvent({type:"alertMove", target:this.obj.alerts[this.idx]});
				}
			}
		}
	}
	
	private function drawDoors():Void {
		var doors_mc:MovieClip = scrollPane_sp.content.createEmptyMovieClip("doors_mc", 30);
		
		for (var i=0; i<_doors.length; i++) {
			var door_mc = doors_mc.createEmptyMovieClip("door" + i + "_mc", doors_mc.getNextHighestDepth());
			
			var coords = _doors[i].door.split(",");
			
			var handle1_mc = door_mc.attachMovie("handle", "handle1_mc", 20);
			handle1_mc._x = coords[0];
			handle1_mc._y = coords[1];
			handle1_mc.idx = i;
			handle1_mc.obj = this;
			
			var handle2_mc = door_mc.attachMovie("handle", "handle2_mc", 30);
			handle2_mc._x = coords[2];
			handle2_mc._y = coords[3];
			handle2_mc.idx = i;
			handle2_mc.obj = this;
			
			drawDoor(i, coords);
			
			handle1_mc.onPress = handle2_mc.onPress = function () {
				if (this.obj.mode == "movePoints") {
					this.obj.dispatchEvent({type:"doorSelect", target:this.obj.doors[this.idx]});
					var scrollPane_sp = this.obj.scrollPane_sp;
					
					this.onEnterFrame = function () {
						if (this.obj._xmouse < scrollPane_sp._x) {
							scrollPane_sp.hPosition -= 10;
							if (scrollPane_sp.hPosition < 10) scrollPane_sp.hPosition = 1;
						}
						if (this.obj._ymouse < scrollPane_sp._y ) {
							scrollPane_sp.vPosition -= 10;
							if (scrollPane_sp.vPosition < 10) scrollPane_sp.vPosition = 1;
						}
						if (this.obj._xmouse > scrollPane_sp._x + scrollPane_sp.width) {
							scrollPane_sp.hPosition += 10;
							if (scrollPane_sp.hPosition > scrollPane_sp.maxHPosition + 10) scrollPane_sp.hPosition = scrollPane_sp.maxHPosition;
						}
						if (this.obj._ymouse > scrollPane_sp._y + scrollPane_sp.height) {
							scrollPane_sp.vPosition += 10;
							if (scrollPane_sp.vPosition > scrollPane_sp.maxVPosition + 10) scrollPane_sp.vPosition = scrollPane_sp.maxVPosition;
						}
						_x = doors_mc._xmouse;
						_y = doors_mc._ymouse;
						_x = Math.round(_x / this.obj._snapToGrid) * this.obj._snapToGrid;
						_y = Math.round(_y / this.obj._snapToGrid) * this.obj._snapToGrid;

						var coords = this.obj._doors[this.idx].door.split(",");
											
						if (this._name == "handle1_mc") {
							coords[0] = _x;
							coords[1] = _y;
						} else {
							coords[2] = _x;
							coords[3] = _y;							
						}
						
						this.obj._doors[this.idx].door = coords.join(",");
						
						this.obj.drawDoor(this.idx, coords);
					}
				} else if (this.obj.mode == "deletePoints") {
					this.obj.dispatchEvent({type:"doorDelete", target:this.obj.doors[this.idx]});
					this.obj.removeDoor(this.idx);
				}
			}
			handle1_mc.onRelease = handle1_mc.onReleaseOutside = handle2_mc.onRelease = handle2_mc.onReleaseOutside = function () {
				if (this.obj.mode == "movePoints") {
					this.onEnterFrame();
					delete this.onEnterFrame;
					this.obj.dispatchEvent({type:"doorMove", target:this.obj.doors[this.idx]});
				}
			}
		}
	}
	
	private function drawDoor(idx, coords):Void {
		var doors_mc:MovieClip = scrollPane_sp.content.doors_mc;
		var door_mc:MovieClip = doors_mc["door" + idx + "_mc"];
		
		var thickness = (_doors[idx].thickness > 0) ? _doors[idx].thickness : 5;

		var line_mc = door_mc.createEmptyMovieClip("line_mc", 50);
		line_mc.lineStyle(thickness, 0xFF0000, 90, true, "normal", "none");
		line_mc.moveTo(coords[0], coords[1]);
		line_mc.lineTo(coords[2], coords[3]);
	}
	
	private function focusPoly():Void {
		var poly_mc = scrollPane_sp.content.poly_mc;
		
		if (poly_mc._width == 0) return;
		
		var ratioX:Number = scrollPane_sp.width / poly_mc._width;
		var ratioY:Number = scrollPane_sp.height / poly_mc._height;
		
		if (ratioX < ratioY) {
			// zoom to fit horizontally
			var scaleFactor:Number = ratioX;
		} else {
			// zoom to fit vertically
			var scaleFactor:Number = ratioY;
		}
			
		scrollPane_sp.content._xscale = scrollPane_sp.content._yscale = (scaleFactor * 50);
		scrollPane_sp.invalidate();
		
		onEnterFrame = function () {
			var background_mc = scrollPane_sp.content.background_mc;
			var poly_mc = scrollPane_sp.content.poly_mc;
						
			var ratioX = poly_mc.maxX / background_mc._width;
			var ratioY = poly_mc.maxY / background_mc._height;
	
			scrollPane_sp.hPosition = scrollPane_sp.maxHPosition * ratioX;
			scrollPane_sp.vPosition = scrollPane_sp.maxVPosition * ratioY;
			delete onEnterFrame;
		}
	}
	
	private function addPoint(x:Number, y:Number):Void {
		x = Math.round(x / _snapToGrid) * _snapToGrid;
		y = Math.round(y / _snapToGrid) * _snapToGrid;
		if (_poly == undefined || _poly.length == 0) {
			_poly = [x, y];
		} else if (_poly.length == 2) {
			_poly = _poly.concat([x, y]);
		} else {
			var i = 0;
			var len = _poly.length;
			var p1, p2, dist1, dist2, vertDist;
			var smallestDist = Number.POSITIVE_INFINITY;
			var idx = 0;
			for (i; i<len; i+=2) {
				p1 = {x:_poly[i], y:_poly[i+1]};
				if (i < len - 2) {
					p2 = {x:_poly[i+2], y:_poly[i+3]};
				} else {
					p2 = {x:_poly[0], y:_poly[1]};
				}
				dist1 = Math.sqrt(Math.pow(p1.x - x, 2) + Math.pow(p1.y - y, 2));
				dist2 = Math.sqrt(Math.pow(p2.x - x, 2) + Math.pow(p2.y - y, 2));
				
				if (dist1 + dist2 < smallestDist) {
					smallestDist = dist1 + dist2;
					idx = i+2;
				}
			}
			_poly.splice(idx, 0, x, y);
		}
		dispatchEvent({type:"polyChange", target:this});
		drawHandles();
		drawPoly();
	}
	
	private function removePoint(idx):Void {
		_poly.splice(idx, 2);
		drawHandles();
		drawPoly();
	}
	
	private function addAlert(x:Number, y:Number):Void {
		x = Math.round(x / _snapToGrid) * _snapToGrid;
		y = Math.round(y / _snapToGrid) * _snapToGrid;
		_alerts.push({id:0, x:x, y:y});
		dispatchEvent({type:"alertAdd", target:alerts[alerts.length - 1]});
		drawAlerts();
	}
	
	private function addDoor(x:Number, y:Number):Void {
		x = Math.round(x / _snapToGrid) * _snapToGrid;
		y = Math.round(y / _snapToGrid) * _snapToGrid;
		_doors.push({door:x + "," + y + "," + (x + 50) + "," + y, thickness:5});
		dispatchEvent({type:"doorAdd", target:doors[doors.length - 1]});
		drawDoors();
	}
	
	private function removeAlert(idx):Void {
		_alerts.splice(idx, 1);
		drawAlerts();
	}
	
	private function removeDoor(idx):Void {
		_doors.splice(idx, 1);
		drawDoors();
	}
	
	private function draw():Void {}
}