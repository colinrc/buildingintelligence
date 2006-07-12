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
				newArbitrary.fontColour = items[item].attributes["fontColour"];
				newArbitrary.defaultState = items[item].attributes["defaultState"];
				newArbitrary.defaultValue = items[item].attributes["defaultValue"];
				break;
			case "button" :
				newArbitrary.bgColour = items[item].attributes["bgColour"];
				newArbitrary.borderColour = items[item].attributes["borderColour"];
				newArbitrary.fontColour = items[item].attributes["fontColour"];
				if (items[item].attributes["labels"] != undefined) {
					var newIcons = items[item].attributes["labels"].split(",");
					if (newIcons[0].length) {
						newArbitrary.label = newIcons[0];
					} else {
						newArbitrary.label = "";
					}
					if (newIcons[1].length) {
						newArbitrary.label2 = newIcons[1];
					} else {
						newArbitrary.label2 = "";
					}
				} else {
					newArbitrary.label = "";
					newArbitrary.label2 = "";
				}
				if (items[item].attributes["commands"] != undefined) {
					var newIcons = items[item].attributes["commands"].split(",");
					if (newIcons[0].length) {
						newArbitrary.command = newIcons[0];
					} else {
						newArbitrary.command = "";
					}
					if (newIcons[1].length) {
						newArbitrary.command2 = newIcons[1];
					} else {
						newArbitrary.command2 = "";
					}
				} else {
					newArbitrary.command = "";
					newArbitrary.command2 = "";
				}
				newArbitrary.width = items[item].attributes["width"];
				newArbitrary.key = items[item].attributes["key"];
				newArbitrary.fontSize = items[item].attributes["fontSize"];
				break;
			case "icon" :
				if (items[item].attributes["icons"] != undefined) {
					var newIcons = items[item].attributes["icons"].split(",");
					if (newIcons[0].length) {
						newArbitrary.icon1 = newIcons[0];
					} else {
						newArbitrary.icon1 = "";
					}
					if (newIcons[1].length) {
						newArbitrary.icon2 = newIcons[1];
					} else {
						newArbitrary.icon2 = "";
					}
				} else {
					newArbitrary.icon1 = "";
					newArbitrary.icon2 = "";
				}
				if (items[item].attributes["commands"] != undefined) {
					var newIcons = items[item].attributes["commands"].split(",");
					if (newIcons[0].length) {
						newArbitrary.command = newIcons[0];
					} else {
						newArbitrary.command = "";
					}
					if (newIcons[1].length) {
						newArbitrary.command2 = newIcons[1];
					} else {
						newArbitrary.command2 = "";
					}
				} else {
					newArbitrary.command = "";
					newArbitrary.command2 = "";
				}
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
			//currentAlert = undefined;
			currentAlert = eventObj.target;
			currentAlert.type = "label";
			currentAlert.label = "";
			currentAlert.key = "";
			currentAlert.fontSize = "";
			currentAlert.defaultState = "";
			currentAlert.defaultValue = "";
			typeChange("label");
		} else if (eventObj.type == "alertSelect") {
			//currentAlert = undefined;
			currentAlert = eventObj.target;
			typeChange(eventObj.target.type);
			toggleDetails(true);
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
		currentAlert.type = type_cmb.selectedItem.label;
		typeChange(type_cmb.selectedItem.label);
	}
	private function typeChange(type) {
		_global.unSaved = true;
		switch (type) {
		case "label" :
			if (!currentAlert.label) {
				currentAlert.label = "";
			}
			if (!currentAlert.key) {
				currentAlert.key = "";
			}
			if (!currentAlert.fontSize) {
				currentAlert.fontSize = "";
			}
			if (!currentAlert.fontColour) {
				currentAlert.fontColour = "";
			}
			if (!currentAlert.defaultState) {
				currentAlert.defaultState = "";
			}
			if (!currentAlert.defaultValue) {
				currentAlert.defaultValue = "";
			}
			break;
		case "button" :
			if (!currentAlert.bgColour) {
				currentAlert.bgColour = "";
			}
			if (!currentAlert.borderColour) {
				currentAlert.borderColour = "";
			}
			if (!currentAlert.fontColour) {
				currentAlert.fontColour = "";
			}
			if (!currentAlert.label) {
				currentAlert.label = "";
			}
			if (!currentAlert.label2) {
				currentAlert.label2 = "";
			}
			if (!currentAlert.command) {
				currentAlert.command = "";
			}
			if (!currentAlert.command2) {
				currentAlert.command2 = "";
			}
			if (!currentAlert.width) {
				currentAlert.width = "";
			}
			if (!currentAlert.key) {
				currentAlert.key = "";
			}
			if (!currentAlert.fontSize) {
				currentAlert.fontSize = "";
			}
			break;
		case "icon" :
			if (!currentAlert.icon1) {
				currentAlert.icon1 = "";
			}
			if (!currentAlert.icon2) {
				currentAlert.icon2 = "";
			}
			if (!currentAlert.command) {
				currentAlert.command = "";
			}
			if (!currentAlert.command2) {
				currentAlert.command2 = "";
			}
			if (!currentAlert.key) {
				currentAlert.key = "";
			}
			break;
		case "object" :
			if (!currentAlert.src) {
				currentAlert.src = "";
			}
			if (!currentAlert.key) {
				currentAlert.key = "";
			}
			if (!currentAlert.width) {
				currentAlert.width = "";
			}
			if (!currentAlert.height) {
				currentAlert.height = "";
			}
			if (!currentAlert.show) {
				currentAlert.show = "";
			}
			if (!currentAlert.hide) {
				currentAlert.hide = "";
			}
			break;
		}
		item_mc = attachMovie("forms.project.client.arbitrary" + type, "item" + (_global.formDepth++) + "_mc", 0, {_x:110, _y:510, currentAlert:currentAlert});
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
				if (roomEditor.alerts[index].label) {
					newArbitraryNode.attributes["label"] = roomEditor.alerts[index].label;
				}
				if (roomEditor.alerts[index].fontSize) {
					newArbitraryNode.attributes["fontSize"] = roomEditor.alerts[index].fontSize;
				}
				if (roomEditor.alerts[index].fontColour) {
					newArbitraryNode.attributes["fontColour"] = roomEditor.alerts[index].fontColour;
				}
				if (roomEditor.alerts[index].key) {
					newArbitraryNode.attributes["key"] = roomEditor.alerts[index].key;
				}
				if (roomEditor.alerts[index].defaultState) {
					newArbitraryNode.attributes["defaultState"] = roomEditor.alerts[index].defaultState;
				}
				if (roomEditor.alerts[index].defaultValue) {
					newArbitraryNode.attributes["defaultValue"] = roomEditor.alerts[index].defaultValue;
				}
				break;
			case "button" :
				if (roomEditor.alerts[index].borderColour) {
					newArbitraryNode.attributes["bgColour"] = roomEditor.alerts[index].bgColour;
				}
				if (roomEditor.alerts[index].borderColour) {
					newArbitraryNode.attributes["borderColour"] = roomEditor.alerts[index].borderColour;
				}
				if (roomEditor.alerts[index].fontColour) {
					newArbitraryNode.attributes["fontColour"] = roomEditor.alerts[index].fontColour;
				}
				if ((roomEditor.alerts[index].label != "") && (roomEditor.alerts[index].label != undefined)) {
					if ((roomEditor.alerts[index].label2 != "") && (roomEditor.alerts[index].label2 != undefined)) {
						var newIcons = new Array();
						newIcons.push(roomEditor.alerts[index].label);
						newIcons.push(roomEditor.alerts[index].label2);
						newArbitraryNode.attributes["labels"] = newIcons.join(",");
					} else {
						newArbitraryNode.attributes["labels"] = roomEditor.alerts[index].label;
					}
				} else {
					if ((roomEditor.alerts[index].label2 != "") && (roomEditor.alerts[index].label2 != undefined)) {
						newArbitraryNode.attributes["labels"] = roomEditor.alerts[index].label2;
					}
				}
				if ((roomEditor.alerts[index].command != "") && (roomEditor.alerts[index].command != undefined)) {
					if ((roomEditor.alerts[index].command2 != "") && (roomEditor.alerts[index].command2 != undefined)) {
						var newIcons = new Array();
						newIcons.push(roomEditor.alerts[index].command);
						newIcons.push(roomEditor.alerts[index].command2);
						newArbitraryNode.attributes["commands"] = newIcons.join(",");
					} else {
						newArbitraryNode.attributes["commands"] = roomEditor.alerts[index].command;
					}
				} else {
					if ((roomEditor.alerts[index].command2 != "") && (roomEditor.alerts[index].command2 != undefined)) {
						newArbitraryNode.attributes["commands"] = roomEditor.alerts[index].command2;
					}
				}
				if (roomEditor.alerts[index].width) {
					newArbitraryNode.attributes["width"] = roomEditor.alerts[index].width;
				}
				if (roomEditor.alerts[index].key) {
					newArbitraryNode.attributes["key"] = roomEditor.alerts[index].key;
				}
				if (roomEditor.alerts[index].fontSize) {
					newArbitraryNode.attributes["fontSize"] = roomEditor.alerts[index].fontSize;
				}
				break;
			case "icon" :
				if ((roomEditor.alerts[index].icon1 != "No Icon") && (roomEditor.alerts[index].icon1 != undefined)) {
					if ((roomEditor.alerts[index].icon2 != "No Icon") && (roomEditor.alerts[index].icon2 != undefined)) {
						var newIcons = new Array();
						newIcons.push(roomEditor.alerts[index].icon1);
						newIcons.push(roomEditor.alerts[index].icon2);
						newArbitraryNode.attributes["icons"] = newIcons.join(",");
					} else {
						newArbitraryNode.attributes["icons"] = roomEditor.alerts[index].icon1;
					}
				} else {
					if ((roomEditor.alerts[index].icon2 != "No Icon") && (roomEditor.alerts[index].icon2 != undefined)) {
						newArbitraryNode.attributes["icons"] = roomEditor.alerts[index].icon2;
					}
				}
				if ((roomEditor.alerts[index].command != "") && (roomEditor.alerts[index].command != undefined)) {
					if ((roomEditor.alerts[index].command2 != "") && (roomEditor.alerts[index].command2 != undefined)) {
						var newIcons = new Array();
						newIcons.push(roomEditor.alerts[index].command);
						newIcons.push(roomEditor.alerts[index].command2);
						newArbitraryNode.attributes["commands"] = newIcons.join(",");
					} else {
						newArbitraryNode.attributes["commands"] = roomEditor.alerts[index].command;
					}
				} else {
					if ((roomEditor.alerts[index].command2 != "") && (roomEditor.alerts[index].command2 != undefined)) {
						newArbitraryNode.attributes["commands"] = roomEditor.alerts[index].command2;
					}
				}
				if (roomEditor.alerts[index].key) {
					newArbitraryNode.attributes["key"] = roomEditor.alerts[index].key;
				}
				break;
			case "object" :
				if (roomEditor.alerts[index].src) {
					newArbitraryNode.attributes["src"] = roomEditor.alerts[index].src;
				}
				if (roomEditor.alerts[index].key) {
					newArbitraryNode.attributes["key"] = roomEditor.alerts[index].key;
				}
				if (roomEditor.alerts[index].width) {
					newArbitraryNode.attributes["width"] = roomEditor.alerts[index].width;
				}
				if (roomEditor.alerts[index].height) {
					newArbitraryNode.attributes["height"] = roomEditor.alerts[index].height;
				}
				if (roomEditor.alerts[index].show) {
					newArbitraryNode.attributes["show"] = roomEditor.alerts[index].show;
				}
				if (roomEditor.alerts[index].hide) {
					newArbitraryNode.attributes["hide"] = roomEditor.alerts[index].hide;
				}
				break;
			}
			newItems.push(newArbitraryNode);
		}
		dataObject.setArbitraryData(newItems);
		_global.refreshTheTree();
		_global.saveFile("Project");
	}
}
