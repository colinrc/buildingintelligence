import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.Arbitrary extends Forms.BaseForm {
	private var items:Array;
	private var items_li:List;
	private var save_btn:Button;
	private var add_btn:Button;
	private var delete_btn:Button;
	private var update_btn:Button;
	private var type_cmb:ComboBox;
	private var x_ti:TextInput;
	private var y_ti:TextInput;
	private var item_ld:Loader;
	private var item_mc:MovieClip;
	private var dataObject:Object;
	public function onLoad() {
		var changeListener:Object = new Object();
		changeListener.change = function(eventObject:Object) {
			_global.unSaved = true;
		};
		type_cmb.addEventListener("change", changeListener);	
		x_ti.addEventListener("change", changeListener);	
		y_ti.addEventListener("change", changeListener);
		for (var item in items) {
			items_li.addItem(items[item]);
		}
		items_li.labelFunction = function(item_obj:Object):String  {
			var label_str:String = item_obj.attributes["type"];
			if (item_obj.attributes["label"] != undefined) {
				label_str += " : "+item_obj.attributes["label"];
			} else if (item_obj.attributes["key"] != undefined) {
				label_str += " : "+item_obj.attributes["key"];
			}
			return label_str;
		};
		delete_btn.enabled = false;
		update_btn.addEventListener("click", Delegate.create(this, updateItem));
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		add_btn.addEventListener("click", Delegate.create(this, addItem));
		items_li.addEventListener("change", Delegate.create(this, itemChange));
		save_btn.addEventListener("click", Delegate.create(this, save));
		type_cmb.addEventListener("change", Delegate.create(this, comboChange));
	}
	private function deleteItem() {
		items_li.removeItemAt(items_li.selectedIndex);
		items_li.selectedIndex = undefined;
		delete_btn.enabled = false;
		_global.unSaved = true;		
	}
	private function updateItem() {
		_global.unSaved = true;		
		var newItem = new XMLNode(1, "item");
		newItem.attributes["type"] = type_cmb.selectedItem.label;
		if (x_ti.text != "") {
			newItem.attributes["x"] = x_ti.text;
		}
		if (y_ti.text != "") {
			newItem.attributes["y"] = y_ti.text;
		}
		var newObj = item_mc.getData();
		switch (type_cmb.selectedItem.label) {
		case "label" :
			if (newObj.label != "") {
				newItem.attributes["label"] = newObj.label;
			}
			if (newObj.fontSize != "") {
				newItem.attributes["fontSize"] = newObj.fontSize;
			}
			if (newObj.fontColour != "") {
				newItem.attributes["fontColour"] = newObj.fontColour;
			}
			break;
		case "button" :
			if (newObj.bgColour != "") {
				newItem.attributes["bgColour"] = newObj.bgColour;
			}
			if (newObj.borderColour != "") {
				newItem.attributes["borderColour"] = newObj.borderColour;
			}
			if (newObj.fontColour != "") {
				newItem.attributes["fontColour"] = newObj.fontColour;
			}
			if (newObj.labels != "") {
				newItem.attributes["labels"] = newObj.labels;
			}
			if (newObj.commands != "") {
				newItem.attributes["commands"] = newObj.commands;
			}
			if (newObj.width != "") {
				newItem.attributes["width"] = newObj.width;
			}
			if (newObj.key != "") {
				newItem.attributes["key"] = newObj.key;
			}
			if (newObj.fontSize != "") {
				newItem.attributes["fontSize"] = newObj.fontSize;
			}
			break;
		case "icon" :
			if (newObj.icons != "") {
				newItem.attributes["icons"] = newObj.icons;
			}
			if (newObj.commands != "") {
				newItem.attributes["commands"] = newObj.commands;
			}
			if (newObj.key != "") {
				newItem.attributes["key"] = newObj.key;
			}
			break;
		case "object" :
			if (newObj.src != "") {
				newItem.attributes["src"] = newObj.src;
			}
			if (newObj.key != "") {
				newItem.attributes["key"] = newObj.key;
			}
			if (newObj.width != "") {
				newItem.attributes["width"] = newObj.width;
			}
			if (newObj.height != "") {
				newItem.attributes["height"] = newObj.height;
			}
			if (newObj.show != "") {
				newItem.attributes["show"] = newObj.show;
			}
			if (newObj.hide != "") {
				newItem.attributes["hide"] = newObj.hide;
			}
			break;
		}
		if (items_li.selectedIndex != undefined) {
			items_li.replaceItemAt(items_li.selectedIndex, newItem);
		} else {
			items_li.addItem(newItem);
		}
	}
	private function addItem() {
		_global.unSaved = true;		
		var newItem = new XMLNode(1, "item");
		newItem.attributes["type"] = type_cmb.selectedItem.label;
		newItem.attributes["x"] = x_ti.text;
		newItem.attributes["y"] = y_ti.text;
		var newObj = item_mc.getData();
		switch (type_cmb.selectedItem.label) {
		case "label" :
			newItem.attributes["label"] = newObj.label;
			newItem.attributes["fontSize"] = newObj.fontSize;
			newItem.attributes["fontColour"] = newObj.fontColour;
			break;
		case "button" :
			newItem.attributes["bgColour"] = newObj.bgColour;
			newItem.attributes["borderColour"] = newObj.borderColour;
			newItem.attributes["fontColour"] = newObj.fontColour;
			newItem.attributes["labels"] = newObj.labels;
			newItem.attributes["commands"] = newObj.commands;
			newItem.attributes["width"] = newObj.width;
			newItem.attributes["key"] = newObj.key;
			newItem.attributes["fontSize"] = newObj.fontSize;
			break;
		case "icon" :
			newItem.attributes["icons"] = newObj.icons;
			newItem.attributes["commands"] = newObj.commands;
			newItem.attributes["key"] = newObj.key;
			break;
		case "object" :
			newItem.attributes["src"] = newObj.src;
			newItem.attributes["key"] = newObj.key;
			newItem.attributes["width"] = newObj.width;
			newItem.attributes["height"] = newObj.height;
			newItem.attributes["show"] = newObj.show;
			newItem.attributes["hide"] = newObj.hide;
			break;
		}
		items_li.addItem(newItem);
		items_li.selectedIndex = undefined;
		delete_btn.enabled = false;
	}
	private function itemChange(evtObj) {
		_global.unSaved = true;		
		delete_btn.enabled = true;
		for (var index = 0; index<items_li.length; index++) {
			if (type_cmb.getItemAt(index).label == items_li.selectedItem.attributes["type"]) {
				type_cmb.selectedIndex = index;
			}
		}
		if (items_li.selectedItem.attributes["x"] != undefined) {
			x_ti.text = items_li.selectedItem.attributes["x"];
		} else {
			x_ti.text = "";
		}
		if (items_li.selectedItem.attributes["y"] != undefined) {
			y_ti.text = items_li.selectedItem.attributes["y"];
		} else {
			y_ti.text = "";
		}
		typeChange(items_li.selectedItem.attributes["type"]);
	}
	private function comboChange(evtObj) {
		_global.unSaved = true;		
		typeChange(type_cmb.selectedItem.label);
	}
	private function typeChange(type) {
		_global.unSaved = true;		
		var dataObj = new Object();
		switch (type) {
		case "label" :
			if (items_li.selectedItem.attributes["label"] != undefined) {
				dataObj.label = items_li.selectedItem.attributes["label"];
			} else {
				dataObj.label = "";
			}
			if (items_li.selectedItem.attributes["fontSize"] != undefined) {
				dataObj.fontSize = items_li.selectedItem.attributes["fontSize"];
			} else {
				dataObj.fontSize = "";
			}
			if (items_li.selectedItem.attributes["fontColour"] != undefined) {
				dataObj.fontColour = items_li.selectedItem.attributes["fontColour"];
			} else {
				dataObj.fontColour = "";
			}
			if (items_li.selectedItem.attributes["key"] != undefined) {
				dataObj.key = items_li.selectedItem.attributes["key"];
			} else {
				dataObj.key = "";
			}
			if (items_li.selectedItem.attributes["defaultState"] != undefined) {
				dataObj.defaultState = items_li.selectedItem.attributes["defaultState"];
			} else {
				dataObj.defaultState = "";
			}
			if (items_li.selectedItem.attributes["defaultValue"] != undefined) {
				dataObj.defaultValue = items_li.selectedItem.attributes["defaultValue"];
			} else {
				dataObj.defaultValue = "";
			}
			break;
		case "button" :
			if (items_li.selectedItem.attributes["bgColour"] != undefined) {
				dataObj.bgColour = items_li.selectedItem.attributes["bgColour"];
			} else {
				dataObj.bgColour = "";
			}
			if (items_li.selectedItem.attributes["borderColour"] != undefined) {
				dataObj.borderColour = items_li.selectedItem.attributes["borderColour"];
			} else {
				dataObj.borderColour = "";
			}
			if (items_li.selectedItem.attributes["fontColour"] != undefined) {
				dataObj.fontColour = items_li.selectedItem.attributes["fontColour"];
			} else {
				dataObj.fontColour = "";
			}
			if (items_li.selectedItem.attributes["labels"] != undefined) {
				dataObj.labels = items_li.selectedItem.attributes["labels"];
			} else {
				dataObj.labels = "";
			}
			if (items_li.selectedItem.attributes["commands"] != undefined) {
				dataObj.commands = items_li.selectedItem.attributes["commands"];
			} else {
				dataObj.commands = "";
			}
			if (items_li.selectedItem.attributes["width"] != undefined) {
				dataObj.width = items_li.selectedItem.attributes["width"];
			} else {
				dataObj.width = "";
			}
			if (items_li.selectedItem.attributes["key"] != undefined) {
				dataObj.key = items_li.selectedItem.attributes["key"];
			} else {
				dataObj.key = "";
			}
			if (items_li.selectedItem.attributes["fontSize"] != undefined) {
				dataObj.fontSize = items_li.selectedItem.attributes["fontSize"];
			} else {
				dataObj.fontSize = "";
			}
			break;
		case "icon" :
			if (items_li.selectedItem.attributes["icons"] != undefined) {
				dataObj.icons = items_li.selectedItem.attributes["icons"];
			} else {
				dataObj.icons = "";
			}
			if (items_li.selectedItem.attributes["commands"] != undefined) {
				dataObj.commands = items_li.selectedItem.attributes["commands"];
			} else {
				dataObj.commands = "";
			}
			if (items_li.selectedItem.attributes["key"] != undefined) {
				dataObj.key = items_li.selectedItem.attributes["key"];
			} else {
				dataObj.key = "";
			}
			break;
		case "object" :
			if (items_li.selectedItem.attributes["src"] != undefined) {
				dataObj.src = items_li.selectedItem.attributes["src"];
			} else {
				dataObj.src = "";
			}
			if (items_li.selectedItem.attributes["key"] != undefined) {
				dataObj.key = items_li.selectedItem.attributes["key"];
			} else {
				dataObj.key = "";
			}
			if (items_li.selectedItem.attributes["width"] != undefined) {
				dataObj.width = items_li.selectedItem.attributes["width"];
			} else {
				dataObj.width = "";
			}
			if (items_li.selectedItem.attributes["height"] != undefined) {
				dataObj.height = items_li.selectedItem.attributes["height"];
			} else {
				dataObj.height = "";
			}
			if (items_li.selectedItem.attributes["show"] != undefined) {
				dataObj.show = items_li.selectedItem.attributes["show"];
			} else {
				dataObj.show = "";
			}
			if (items_li.selectedItem.attributes["hide"] != undefined) {
				dataObj.hide = items_li.selectedItem.attributes["hide"];
			} else {
				dataObj.hide = "";
			}
			break;
		}
		item_mc = item_ld.attachMovie("forms.project.client.arbitrary"+type, "item_mc", 0, {dataObj:dataObj});
	}
	public function save():Void {	
		var newItems = new Array();
		for (var index = 0; index<items_li.length; index++) {
			newItems.push(items_li.getItemAt(index));
		}
		dataObject.setData({items:newItems});
		_global.refreshTheTree();		
		_global.saveFile("Project");
	}
}
