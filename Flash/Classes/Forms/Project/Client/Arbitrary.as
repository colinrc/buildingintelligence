import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.Arbitrary {
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
	public function init() {
		for (var item in items) {
			items_li.addItem(items[item]);
		}
		items_li.labelFunction = function(item_obj:Object):String  {
			var label_str:String = item_obj.attributes["type"];
			if (item_obj.attributes["label"] != undefined) {
				label_str += ": "+item_obj.attributes["label"];
			} else if (item_obj.attributes["key"] != undefined) {
				label_str += ": "+item_obj.attributes["key"];
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
	}
	private function updateItem() {
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
		if (items_li.selectedIndex != undefined) {
			items_li.replaceItemAt(items_li.selectedIndex, newItem);
		} else {
			items_li.addItem(newItem);
		}
	}
	private function addItem() {
		var newItem = new XMLNode(1,"item");
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
		delete_btn.enabled = true;
		for(var index = 0; index < items_li.length; index++){
			if(type_cmb.getItemAt(index).label == items_li.selectedItem.attributes["type"]) {
				type_cmb.selectedIndex = index;
			}
		}
		x_ti.text = items_li.selectedItem.attributes["x"];
		y_ti.text = items_li.selectedItem.attributes["y"];
		typeChange(items_li.selectedItem.attributes["type"]);
	}
	private function comboChange(evtObj) {
		typeChange(type_cmb.selectedItem.label);
	}
	private function typeChange(type) {
		var dataObj = new Object();
		switch (type) {
		case "label" :
			dataObj.label = items_li.selectedItem.attributes["label"];
			dataObj.fontSize = items_li.selectedItem.attributes["fontSize"];
			dataObj.fontColour = items_li.selectedItem.attributes["fontColour"];
			break;
		case "button" :
			dataObj.bgColour = items_li.selectedItem.attributes["bgColour"];
			dataObj.borderColour = items_li.selectedItem.attributes["borderColour"];
			dataObj.fontColour = items_li.selectedItem.attributes["fontColour"];
			dataObj.labels = items_li.selectedItem.attributes["labels"];
			dataObj.commands = items_li.selectedItem.attributes["commands"];
			dataObj.width = items_li.selectedItem.attributes["width"];
			dataObj.key = items_li.selectedItem.attributes["key"];
			dataObj.fontSize = items_li.selectedItem.attributes["fontSize"];
			break;
		case "icon" :
			dataObj.icons = items_li.selectedItem.attributes["icons"];
			dataObj.commands = items_li.selectedItem.attributes["commands"];
			dataObj.key = items_li.selectedItem.attributes["key"];
			break;
		case "object" :
			dataObj.src = items_li.selectedItem.attributes["src"];
			dataObj.key = items_li.selectedItem.attributes["key"];
			dataObj.width = items_li.selectedItem.attributes["width"];
			dataObj.height = items_li.selectedItem.attributes["height"];
			dataObj.show = items_li.selectedItem.attributes["show"];
			dataObj.hide = items_li.selectedItem.attributes["hide"];
			break;
		}
		item_mc = item_ld.attachMovie("forms.project.client.arbitrary"+type, "item_mc", 0, {dataObj:dataObj});
	}
	public function save():Void {
		var newItems = new Array();
		for (var index = 0; index<items_li.length; index++) {
			newItems.push(items_li.getItemAt(index));
		}
		_global.left_tree.selectedNode.object.setData(new Object({items:newItems}));
		_global.left_tree.setIsOpen(_global.left_tree.selectedNode, false);
		var newNode:XMLNode = _global.left_tree.selectedNode.object.toTree();
		for (var child in _global.left_tree.selectedNode.childNodes) {
			_global.left_tree.selectedNode.childNodes[child].removeNode();
		}
		// Nodes are added in reverse order to maintain consistancy
		_global.left_tree.selectedNode.appendChild(new XMLNode(1, "Placeholder"));
		for (var child in newNode.childNodes) {
			_global.left_tree.selectedNode.insertBefore(newNode.childNodes[child], _global.left_tree.selectedNode.firstChild);
		}
		_global.left_tree.selectedNode.lastChild.removeNode();
		_global.left_tree.setIsOpen(_global.left_tree.selectedNode, true);
	}
}
