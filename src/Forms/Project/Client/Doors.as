import mx.controls.*;
import Controls.MMapEditorNew
import mx.utils.Delegate;

class Forms.Project.Client.Doors extends Forms.BaseForm {
	private var doors:Array;
	private var poly:String;
	private var roomEditor:MMapEditorNew
	private var map:String;
	private var background:String;
	private var save_btn:Button;
	private var colour1_lb:Label;
	private var colour2_lb:Label;
	private var thickness_lb:Label;
	private var key_lb:Label;
	private var name_lb:Label;
	private var colour1_mc:MovieClip;
	private var colour2_mc:MovieClip;
	private var thickness_ti:TextInput;
	private var key_cmb:ComboBox;
	private var name_ti:TextInput;
	private var dataObject:Object;	
	private var currentDoor:Object;
	
	public function onLoad() {
		var tempKeys = _global.serverDesign.getKeys();
		var DPKey = new Array();
		for (var key in tempKeys) {
			var tempObject = new Object();
			tempObject.label = tempKeys[key];
			DPKey.push(tempObject);
		}
		var DP = new Array();
		for (var door in doors) {
			var newDoor = new Object();
			if (doors[door].attributes["name"] != undefined) {
				newDoor.name = doors[door].attributes["name"];
			} else {
				newDoor.name = "";
			}
			if (doors[door].attributes["key"] != undefined) {
				newDoor.key = doors[door].attributes["key"];
			} else {
				newDoor.key = "";
			}
			if (doors[door].attributes["pos"] != undefined) {
				newDoor.pos = doors[door].attributes["pos"];
			} else {
				newDoor.pos = "";
			}
			if (doors[door].attributes["thickness"] != undefined) {
				newDoor.thickness = doors[door].attributes["thickness"];
			} else {
				newDoor.thickness = "";
			}			
			if (doors[door].attributes["colour1"] != undefined) {
				newDoor.colour1 = doors[door].attributes["colour1"];
			} else {
				newDoor.colour1 = "";
			}
			if (doors[door].attributes["colour2"] != undefined) {
				newDoor.colour2 = doors[door].attributes["colour2"];
			} else {
				newDoor.colour2 = "";
			}
			DP.push(newDoor);
		}
		if(map == undefined){
			map != "";
		}
		roomEditor.map = "lib/maps/"+map;
		if((background != undefined)&&(background != "")){
			roomEditor.background = "lib/backgrounds/"+background;
		}
		roomEditor.mapMode = "doors";
		roomEditor.poly = poly;
		roomEditor.doors = DP;			
		var editorListener = new Object();
		colour1_mc.setColour("0xFFFFFF");
		colour2_mc.setColour("0xFFFFFF");
		thickness_ti.text = "";
		thickness_ti.restrict = "0-9";
		key_cmb.dataProvider = DPKey;
		name_ti.text = "";
		currentDoor = undefined;
		toggleDetails(false);
		roomEditor.addEventListener("doorSelect", Delegate.create(this,doorSelect));
		roomEditor.addEventListener("doorAdd", Delegate.create(this,doorAdd));
		roomEditor.addEventListener("doorMove", Delegate.create(this,doorMove));
		roomEditor.addEventListener("doorDelete", Delegate.create(this,doorDelete));
		save_btn.addEventListener("click", Delegate.create(this, save));
		var colourObjectListener = new Object();
		colourObjectListener.base = this;
		colourObjectListener.onColourChange = function (newColour:Number){
			this.base.currentDoor.colour1 = "0x" + newColour.toString(16).toUpperCase();
			this.base.roomEditor.refresh();
			_global.unSaved = true;
		}	
		colour1_mc.setCallbackObject(colourObjectListener);
		var colourObjectListener2 = new Object();
		colourObjectListener2.base = this;
		colourObjectListener2.onColourChange = function (newColour:Number){
			this.base.currentDoor.colour2 = "0x" + newColour.toString(16).toUpperCase();
			this.base.roomEditor.refresh();
			_global.unSaved = true;
		}	
		colour2_mc.setCallbackObject(colourObjectListener2);
		key_cmb.addEventListener("change", Delegate.create(this, cmbChange));
		name_ti.addEventListener("change", Delegate.create(this, nameChange));
		thickness_ti.addEventListener("change", Delegate.create(this, thicknessChange));
	}
	public function cmbChange(eventObj){
		currentDoor.key = key_cmb.selectedItem.label;
	}
	public function nameChange(eventObj){
		currentDoor.name = name_ti.text;
	}
	public function thicknessChange(eventObj){
		currentDoor.thickness = thickness_ti.text;
		roomEditor.refresh();
	}
	public function save():Void {
		var newDoors = new Array();
		var DP = roomEditor.doors;
		for (var index = 0; index<DP.length; index++) {
			var item = new XMLNode(1, "door");
			if (DP[index].name != "") {
				item.attributes["name"] = DP[index].name;
			}
			if (DP[index].key != "") {
				item.attributes["key"] = DP[index].key;
			}
			if (DP[index].pos != "") {
				item.attributes["pos"] = DP[index].pos;
			}
			if (DP[index].colour1 != "") {
				item.attributes["colour1"] = DP[index].colour1;
			}
			if (DP[index].colour2 != "") {
				item.attributes["colour2"] = DP[index].colour2;
			}
			if (DP[index].thickness != "") {
				item.attributes["thickness"] = DP[index].thickness;
			}			
			newDoors.push(item);
		}
		dataObject.setData({doors:newDoors});
		_global.refreshTheTree();		
		_global.saveFile("Project");
	}
	public function doorSelect(eventObj) {
		currentDoor = eventObj.target;
		toggleDetails(true);
		colour1_mc.setColour(currentDoor.colour1);
		colour2_mc.setColour(currentDoor.colour2);
		thickness_ti.text = currentDoor.thickness;
		for (var i=0; i<key_cmb.length; i++) {
			if (key_cmb.getItemAt(i).label == currentDoor.key) {
				key_cmb.selectedIndex = i;
				break;
			}
		}
		cmbChange();
		name_ti.text = currentDoor.name;
		_global.unSaved = true;					
	}
	public function doorAdd(eventObj) {
		currentDoor = eventObj.target;
		toggleDetails(true);
		currentDoor.colour1 = "0xFFFFFF";
		currentDoor.colour2 = "0xFFFFFF";
		currentDoor.thickness = "5";
		currentDoor.key = key_cmb.getItemAt(0).label;
		currentDoor.name = "";
		colour1_mc.setColour("0xFFFFFF");
		colour2_mc.setColour("0xFFFFFF");
		thickness_ti.text = "5";
		key_cmb.selectedIndex = 0;
		name_ti.text = "";
		_global.unSaved = true;
	}
	public function doorMove (eventObj) {
		currentDoor = eventObj.target;
		toggleDetails(true);
		colour1_mc.setColour(currentDoor.colour1);
		colour2_mc.setColour(currentDoor.colour2);
		thickness_ti.text = currentDoor.thickness;
		for (var i=0; i<key_cmb.length; i++) {
			if (key_cmb.getItemAt(i).label == currentDoor.key) {
				key_cmb.selectedIndex = i;
				break;
			}
		}
		name_ti.text = currentDoor.name;
		_global.unSaved = true;					
	}
	public function doorDelete(eventObj) {
		colour1_mc.setColour("0xFFFFFF");
		colour2_mc.setColour("0xFFFFFF");
		thickness_ti.text = "";
		key_cmb.selectedIndex = 1;
		name_ti.text = "";
		currentDoor = undefined;
		toggleDetails(false);
		_global.unSaved = true;		
	}	
	private function toggleDetails(show:Boolean):Void {
		if (show) {
			roomEditor.setSize(null, 515);
		} else {
			roomEditor.setSize(null, 565);
		}
		colour1_lb._visible = colour1_mc._visible = show;
		colour2_lb._visible = colour2_mc._visible = show;
		thickness_lb._visible = thickness_ti._visible = show;
		key_lb._visible = key_cmb._visible = show;
		name_lb._visible = name_ti._visible = show;
	}
}