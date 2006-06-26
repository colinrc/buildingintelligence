import mx.controls.*;
import mx.utils.Delegate;
import Controls.MapEditor;
class Forms.Project.Client.Arbitrary extends Forms.BaseForm {
	private var items:Array;
	private var save_btn:Button;
	private var type_cmb:ComboBox;
	private var roomEditor:MapEditor;
	private var map:String;
	private var background:String;
	private var item_mc:MovieClip;
	private var dataObject:Object;
	private var currentAlert:Object;
	public function onLoad() {
		var changeListener:Object = new Object();
		changeListener.change = function(eventObject:Object) {
			_global.unSaved = true;
		};
		type_cmb.addEventListener("change", changeListener);
		var alerts = new Array();
		for (var item in items) {
			var newArbitrary = new Object();
			newArbitrary.type = items[item].attributes["type"];
			newArbitrary.x = items[item].attributes["x"];
			newArbitrary.y = items[item].attributes["y"];
			switch (items[item].attributes["type"]) {
			case "label" :
				newArbitrary.label = items[item].attributes["label"];
				newArbitrary.key = items[item].attributes["key"];
				newArbitrary.fontSize = items[item].attributes["fontSize"];
				newArbitrary.defaultState = items[item].attributes["defaultState"];
				newArbitrary.defaultValue = items[item].attributes["defaultValue"];
				break;
			case "button" :
				newArbitrary.bgColour = items[item].attributes["bgColour"];
				newArbitrary.borderColour = items[item].attributes["borderColour"];
				newArbitrary.fontColour = items[item].attributes["fontColour"];
				newArbitrary.labels = items[item].attributes["labels"];
				newArbitrary.commands = items[item].attributes["commands"];
				newArbitrary.width = items[item].attributes["width"];
				newArbitrary.key = items[item].attributes["key"];
				newArbitrary.fontSize = items[item].attributes["fontSize"];
				break;
			case "icon" :
				newArbitrary.icons = items[item].attributes["icons"];
				newArbitrary.commands = items[item].attributes["commands"];
				newArbitrary.key = items[item].attributes["key"];
				break;
			case "object" :
				newArbitrary.src = items[item].attributes["src"];
				newArbitrary.key = items[item].attributes["key"];
				newArbitrary.width = items[item].attributes["width"];
				newArbitrary.height = items[item].attributes["height"];
				newArbitrary.show = items[item].attributes["show"];
				newArbitrary.hide = items[item].attributes["hide"];
				break;
			}
			alerts.addItem(newArbitrary);
		}
		save_btn.addEventListener("click", Delegate.create(this, save));
		roomEditor.map = "lib/maps/" + map;
		if ((background != undefined) && (background != "")) {
			roomEditor.background = "lib/backgrounds/" + background;
		}
		roomEditor.mapMode = "alertGroups";
		roomEditor.alerts = alerts;
		type_cmb.addEventListener("change", Delegate.create(this, comboChange));
		roomEditor.addEventListener("alertSelect", Delegate.create(this, alertEvent));
		roomEditor.addEventListener("alertAdd", Delegate.create(this, alertEvent));
		roomEditor.addEventListener("alertMove", Delegate.create(this, alertEvent));
		roomEditor.addEventListener("alertNew", Delegate.create(this, alertEvent));
		roomEditor.addEventListener("alertDelete", Delegate.create(this, alertEvent));
		toggleDetails(false);
	}
	private function alertEvent(eventObj) {
		_global.unSaved = true;
		if (eventObj.type == "alertDelete") {
			item_mc.removeMovieClip();
			toggleDetails(false);
			currentAlert = undefined;
		} else if (eventObj.type == "alertAdd") {
			toggleDetails(true);
			currentAlert = undefined;
			currentAlert = eventObj.target;
			currentAlert.type = "";
			currentAlert.label = "";
			currentAlert.key = "";
			currentAlert.fontSize = "";
			currentAlert.defaultState = "";
			currentAlert.defaultValue = "";
			typeChange("label");
		} else if (eventObj.type == "alertSelect") {
			toggleDetails(true);
			currentAlert = undefined;
			currentAlert = eventObj.target;
			typeChange(eventObj.target.type);
		}
	}
	private function toggleDetails(show:Boolean):Void {
		if (show) {
			roomEditor.setSize(null, 485);
			type_cmb._visible = true;
		} else {
			roomEditor.setSize(null, 565);
			type_cmb._visible = false;
		}
	}
	private function comboChange(evtObj) {
		_global.unSaved = true;		
		typeChange(type_cmb.selectedItem.label);
	}
	private function typeChange(type) {
		_global.unSaved = true;
		switch(type){
			case "label" :
				if(!currentAlert.label)currentAlert.label = "";
				if(!currentAlert.key)currentAlert.key = "";
				if(!currentAlert.fontSize)currentAlert.fontSize = "";
				if(!currentAlert.defaultState)currentAlert.defaultState = "";
				if(!currentAlert.defaultValue)currentAlert.defaultValue = "";
				break;
			case "button" :
				if(!currentAlert.bgColour)currentAlert.bgColour = "";
				if(!currentAlert.borderColour)currentAlert.borderColour = "";
				if(!currentAlert.fontColour)currentAlert.fontColour = "";
				if(!currentAlert.labels)currentAlert.labels = "";
				if(!currentAlert.commands)currentAlert.commands = "";
				if(!currentAlert.width)currentAlert.width = "";
				if(!currentAlert.key)currentAlert.key = "";
				if(!currentAlert.fontSize)currentAlert.fontSize = "";
				break;
			case "icon" :
				if(!currentAlert.icons)currentAlert.icons = "";
				if(!currentAlert.commands)currentAlert.commands = "";
				if(!currentAlert.key)currentAlert.key = "";
				break;
			case "object" :
				if(!currentAlert.src)currentAlert.src = "";
				if(!currentAlert.key)currentAlert.key = "";
				if(!currentAlert.width)currentAlert.width = "";
				if(!currentAlert.height)currentAlert.height = "";
				if(!currentAlert.show)currentAlert.show = "";
				if(!currentAlert.hide)currentAlert.hide = "";
				break;
		}
		item_mc = attachMovie("forms.project.client.arbitrary"+type, "item_mc", 0, {_x:110,_y:510, dataObj:currentAlert});
	}
	public function save():Void {
		var newItems = new Array();
		for (var index = 0; index < roomEditor.alerts.length; index++) {
			var newArbitraryNode = new XMLNode(1, "item");
			newArbitraryNode.attributes["type"] = roomEditor.alerts[index].type;
			newArbitraryNode.attributes["x"] = roomEditor.alerts[index].x;
			newArbitraryNode.attributes["y"] = roomEditor.alerts[index].y;
			switch (newArbitraryNode.attributes["type"]) {
			case "label" :
				newArbitraryNode.attributes["label"] = roomEditor.alerts[index].label;
				newArbitraryNode.attributes["fontSize"] = roomEditor.alerts[index].fontSize;
				newArbitraryNode.attributes["fontColour"] = roomEditor.alerts[index].fontColour;
				break;
			case "button" :
				newArbitraryNode.attributes["bgColour"] = roomEditor.alerts[index].bgColour;
				newArbitraryNode.attributes["borderColour"] = roomEditor.alerts[index].borderColour;
				newArbitraryNode.attributes["fontColour"] = roomEditor.alerts[index].fontColour;
				newArbitraryNode.attributes["labels"] = roomEditor.alerts[index].labels;
				newArbitraryNode.attributes["commands"] = roomEditor.alerts[index].commands;
				newArbitraryNode.attributes["width"] = roomEditor.alerts[index].width;
				newArbitraryNode.attributes["key"] = roomEditor.alerts[index].key;
				newArbitraryNode.attributes["fontSize"] = roomEditor.alerts[index].fontSize;
				break;
			case "icon" :
				newArbitraryNode.attributes["icons"] = roomEditor.alerts[index].icons;
				newArbitraryNode.attributes["commands"] = roomEditor.alerts[index].commands;
				newArbitraryNode.attributes["key"] = roomEditor.alerts[index].key;
				break;
			case "object" :
				newArbitraryNode.attributes["src"] = roomEditor.alerts[index].src;
				newArbitraryNode.attributes["key"] = roomEditor.alerts[index].key;
				newArbitraryNode.attributes["width"] = roomEditor.alerts[index].width;
				newArbitraryNode.attributes["height"] = roomEditor.alerts[index].height;
				newArbitraryNode.attributes["show"] = roomEditor.alerts[index].show;
				newArbitraryNode.attributes["hide"] = roomEditor.alerts[index].hide;
				break;
			}
			newItems.push(newArbitraryNode);
		}
		dataObject.setArbitraryData(newItems);
		_global.refreshTheTree();
		_global.saveFile("Project");
	}
}
