import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.Control extends Forms.BaseForm {
	private var type:String;
	private var rows:Array;
	private var editor_dg:DataGrid;
	private var editor_ld:Loader;
	private var editor_mc:MovieClip;
	private var type_ti:TextInput;
	private var add_btn:Button;
	private var up_btn:Button;
	private var down_btn:Button;
	private var left_btn:Button;
	private var right_btn:Button;
	private var save_btn:Button;
	private var object:Object;
	private var preview_mc:MovieClip;
	public function init() {
		editor_dg.columnNames = ["0", "1", "2", "3", "4"];
		editor_dg.getColumnAt(0).headerText = "Rows";
		editor_dg.getColumnAt(1).headerText = "Item 1";
		editor_dg.getColumnAt(2).headerText = "Item 2";
		editor_dg.getColumnAt(3).headerText = "Item 3";
		editor_dg.getColumnAt(4).headerText = "Item 4";
		left_btn.enabled = false;
		right_btn.enabled = false;
		for (var row in rows) {
			var newArray = new Array();
			var newObject = {label:"Row", cases:rows[row].attributes["cases"]};
			newObject.toString = function():String  {
				return this.label;
			};
			newArray.push(newObject);
			for (var child = 0; child<rows[row].childNodes.length; child++) {
				var newItem = {label:rows[row].childNodes[child].attributes["type"], object:rows[row].childNodes[child]};
				newItem.toString = function():String  {
					return this.label;
				};
				newArray.push(newItem);
			}
			editor_dg.addItem(newArray);
		}
		type_ti.text = type;
		object = new Object();
		object.itemIndex = undefined;
		object.columnIndex = undefined;
		add_btn.addEventListener("click", Delegate.create(this, addRow));
		up_btn.addEventListener("click", Delegate.create(this, moveUp));
		down_btn.addEventListener("click", Delegate.create(this, moveDown));
		right_btn.addEventListener("click", Delegate.create(this, moveRight));
		left_btn.addEventListener("click", Delegate.create(this, moveLeft));
		save_btn.addEventListener("click", Delegate.create(this, save));
		editor_dg.addEventListener("cellPress", Delegate.create(this, cellClick));
		//preview(_global.left_tree.selectedNode.object.toXML());
	}
	private function cellClick(eventObject) {
		editor_ld.createEmptyMovieClip("editor_mc", 0);
		object.itemIndex = eventObject.itemIndex;
		object.columnIndex = eventObject.columnIndex;
		if (editor_dg.dataProvider[eventObject.itemIndex][eventObject.columnIndex].label == "Row") {
			right_btn.enabled = false;
			left_btn.enabled = false;
			editor_mc = editor_ld.attachMovie("forms.project.client.row", "editor_"+random(999)+"_mc", 0, {cases:editor_dg.dataProvider[eventObject.itemIndex][eventObject.columnIndex].cases});
			editor_mc.deleteRow = Delegate.create(this, deleteRow);
			editor_mc.updateRow = Delegate.create(this, updateRow);
			editor_mc.addItem = Delegate.create(this, addItem);
		} else {
			right_btn.enabled = true;
			left_btn.enabled = true;
			editor_mc = editor_ld.attachMovie("forms.project.client.controltype"+editor_dg.dataProvider[eventObject.itemIndex][eventObject.columnIndex].label, "editor_"+random(999)+"_mc", 0, {object:editor_dg.dataProvider[eventObject.itemIndex][eventObject.columnIndex].object});
			editor_mc.deleteItem = Delegate.create(this, deleteItem);
			editor_mc.updateItem = Delegate.create(this, updateItem);
		}
	}
	private function deleteItem() {
		editor_dg.dataProvider[object.itemIndex].splice(object.columnIndex, 1);
		editor_dg.selectedIndex = undefined;
		object.itemIndex = undefined;
		object.columnIndex = undefined;
		editor_ld.createEmptyMovieClip("editor_mc", 0);
	}
	private function updateItem() {
		editor_dg.dataProvider[object.itemIndex][object.columnIndex].object = editor_mc.getObject();
		editor_dg.selectedIndex = undefined;
		object.itemIndex = undefined;
		object.columnIndex = undefined;
		editor_ld.createEmptyMovieClip("editor_mc", 0);
	}
	private function addItem() {
		var newItemNode = new XMLNode(1, "item");
		newItemNode.attributes["type"] = editor_mc.type_cmb.text;
		var newObject = new Object();
		newObject.label = editor_mc.type_cmb.text;
		newObject.object = newItemNode;
		newObject.toString = function():String  {
			return this.label;
		};
		editor_dg.dataProvider[object.itemIndex].push(newObject);
		editor_dg.selectedIndex = editor_dg.selectedIndex;
	}
	private function addRow() {
		var newArray = new Array();
		var newObject = new Object();
		newObject.label = "Row";
		newObject.cases = undefined;
		newObject.toString = function():String  {
			return this.label;
		};
		newArray.push(newObject);
		editor_dg.dataProvider.addItem(newArray);
		//this is not redrawing, why??
		editor_dg.selectedIndex = editor_dg.selectedIndex;
	}
	private function deleteRow() {
		editor_dg.removeItemAt(object.itemIndex);
		editor_dg.selectedIndex = undefined;
		object.itemIndex = undefined;
		object.columnIndex = undefined;
		editor_ld.createEmptyMovieClip("editor_mc", 0);
	}
	private function updateRow() {
		editor_dg.dataProvider[object.itemIndex][object.columnIndex].cases = editor_mc.cases_ti.text;
		editor_dg.selectedIndex = undefined;
		object.itemIndex = undefined;
		object.columnIndex = undefined;
		editor_ld.createEmptyMovieClip("editor_mc", 0);
	}
	private function moveLeft() {
		if (object != undefined) {
			if (object.columnIndex != 1) {
				var tempObj = editor_dg.dataProvider[object.itemIndex].getItemAt(object.columnIndex-1);
				editor_dg.dataProvider[object.itemIndex].replaceItemAt(object.columnIndex-1, editor_dg.dataProvider[object.itemIndex].getItemAt(object.columnIndex));
				editor_dg.dataProvider[object.itemIndex].replaceItemAt(object.columnIndex, tempObj);
				editor_dg.selectedIndex = undefined;
				editor_dg.selectedIndices = undefined;
				object.itemIndex = undefined;
				object.columnIndex = undefined;
			}
		}
	}
	private function moveRight() {
		if (object != undefined) {
			if (object.columnIndex != editor_dg.dataProvider[object.itemIndex].length-1) {
				var tempObj = editor_dg.dataProvider[object.itemIndex].getItemAt(object.columnIndex+1);
				editor_dg.dataProvider[object.itemIndex].replaceItemAt(object.columnIndex+1, editor_dg.dataProvider[object.itemIndex].getItemAt(object.columnIndex));
				editor_dg.dataProvider[object.itemIndex].replaceItemAt(object.columnIndex, tempObj);
				editor_dg.selectedIndex = undefined;
				editor_dg.selectedIndices = undefined;
				object.itemIndex = undefined;
				object.columnIndex = undefined;
			}
		}
	}
	private function moveUp() {
		if (editor_dg.selectedIndex != undefined) {
			if (editor_dg.selectedIndex != editor_dg.length-1) {
				var tempObj = editor_dg.getItemAt(editor_dg.selectedIndex+1);
				editor_dg.replaceItemAt(editor_dg.selectedIndex+1, editor_dg.selectedItem);
				editor_dg.replaceItemAt(editor_dg.selectedIndex, tempObj);
				//var tempIndex = editor_dg.selectedIndex+1;
				editor_dg.selectedIndex = undefined;
				editor_dg.selectedIndices = undefined;
				//editor_dg.selectedIndex = tempIndex;
			}
		}
	}
	private function moveDown() {
		if (editor_dg.selectedIndex != undefined) {
			if (editor_dg.selectedIndex != 0) {
				var tempObj = editor_dg.getItemAt(editor_dg.selectedIndex-1);
				editor_dg.replaceItemAt(editor_dg.selectedIndex-1, editor_dg.selectedItem);
				editor_dg.replaceItemAt(editor_dg.selectedIndex, tempObj);
				//var tempIndex = editor_dg.selectedIndex-1;
				editor_dg.selectedIndex = undefined;
				editor_dg.selectedIndices = undefined;
				//editor_dg.selectedIndex = tempIndex;
			}
		}
	}
	/*public function preview(controls:XMLNode):Void {
		var preview_mc:MovieClip = this.createEmptyMovieClip("preview_mc", 100);
		preview_mc._x=3;
		preview_mc._y=390;
		var newControlTypes = new XMLNode(1,"controlTypes");
		newControlTypes.appendChild(controls);
		var sampleWindow:XML = new XML('<window><tab name="Preview" ><control name="Main Light" key="ENSUITE_LIGHT" type="'+type_ti.text+'" icons="light-bulb-off,light-bulb" /></tab></window>');				
		preview_mc.attachMovie("window-preview", "preview_mc", 100, {width:400, height:250, controlTypeData:new XML(newControlTypes.toString()), windowData:sampleWindow, iconPath:"../../eLife Client/Build/standalone/lib/icons/"});		
	}*/
	public function save():Void {
		var newRows = new Array();
		for (var index = editor_dg.dataProvider.length-1; index>=0; index--) {
			var tempArray = editor_dg.getItemAt(index);
			var newRow = new XMLNode(1, "row");
			if ((tempArray[0].cases != undefined) && (tempArray[0].cases != "")) {
				newRow.attributes["cases"] = tempArray[0].cases;
			}
			for (var item = 0; item<tempArray.length; item++) {
				newRow.appendChild(tempArray[item].object);
			}
			newRows.push(newRow);
		}
		_global.left_tree.selectedNode.object.setData(new Object({rows:newRows, type:type_ti.text}));
		_global.left_tree.setIsOpen(_global.left_tree.selectedNode, false);
		var newNode:XMLNode = _global.left_tree.selectedNode.object.toTree();
		//preview(_global.left_tree.selectedNode.object.toXML());
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
