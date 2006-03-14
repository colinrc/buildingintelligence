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
	private var dataObject:Object;	
	public function onLoad() {
		var changeListener:Object = new Object();
		changeListener.change = function(eventObject:Object) {
			_global.unSaved = true;
		};
		type_ti.addEventListener("change", changeListener);	
		editor_dg.columnNames = ["0", "1", "2", "3", "4"];
		editor_dg.getColumnAt(0).headerText = "Rows";
		editor_dg.getColumnAt(1).headerText = "Item 1";
		editor_dg.getColumnAt(2).headerText = "Item 2";
		editor_dg.getColumnAt(3).headerText = "Item 3";
		editor_dg.getColumnAt(4).headerText = "Item 4";
		editor_dg.getColumnAt(0).sortable = false;
		editor_dg.getColumnAt(1).sortable = false;
		editor_dg.getColumnAt(2).sortable = false;
		editor_dg.getColumnAt(3).sortable = false;
		editor_dg.getColumnAt(4).sortable = false;		
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
	}
	private function cellClick(eventObject) {
		_global.unSaved = true;		
		editor_ld.createEmptyMovieClip("editor_mc", 0);
		object.itemIndex = eventObject.itemIndex;
		object.columnIndex = eventObject.columnIndex;
		if (editor_dg.dataProvider[eventObject.itemIndex][eventObject.columnIndex].label == "Row") {
			right_btn.enabled = false;
			left_btn.enabled = false;
			editor_mc = editor_ld.attachMovie("forms.project.client.row", "editor_"+random(999)+"_mc", 0, {object:editor_dg.dataProvider[eventObject.itemIndex][eventObject.columnIndex]});
			editor_mc.deleteRow = Delegate.create(this, deleteRow);
			editor_mc.addItem = Delegate.create(this, addItem);
		} else {
			right_btn.enabled = true;
			left_btn.enabled = true;
			editor_mc = editor_ld.attachMovie("forms.project.client.controltype"+editor_dg.dataProvider[eventObject.itemIndex][eventObject.columnIndex].label, "editor_"+random(999)+"_mc", 0, {object:editor_dg.dataProvider[eventObject.itemIndex][eventObject.columnIndex].object});
			editor_mc.deleteItem = Delegate.create(this, deleteItem);
		}
	}
	private function deleteItem() {
		_global.unSaved = true;		
		editor_dg.dataProvider[object.itemIndex].splice(object.columnIndex, 1);
		editor_dg.selectedIndex = undefined;
		object.itemIndex = undefined;
		object.columnIndex = undefined;
		editor_ld.createEmptyMovieClip("editor_mc", 0);
	}
	private function addItem() {
		_global.unSaved = true;		
		var newItemNode = new XMLNode(1, "item");
		newItemNode.attributes["type"] = editor_mc.type_cmb.text;
		var newObject = new Object();
		newObject.label = editor_mc.type_cmb.text;
		newObject.object = newItemNode;
		newObject.toString = function():String  {
			return this.label;
		};
		editor_dg.dataProvider[object.itemIndex].push(newObject);
		editor_dg.dataProvider.updateViews("change");
	}
	private function addRow() {
		_global.unSaved = true;		
		var newArray = new Array();
		var newObject = new Object();
		newObject.label = "Row";
		newObject.cases = undefined;
		newObject.toString = function():String  {
			return this.label;
		};
		newArray.push(newObject);
		editor_dg.dataProvider.addItem(newArray);
		editor_dg.dataProvider.updateViews("change");
	}
	private function deleteRow() {
		_global.unSaved = true;		
		editor_dg.removeItemAt(object.itemIndex);
		editor_dg.selectedIndex = undefined;
		object.itemIndex = undefined;
		object.columnIndex = undefined;
		editor_ld.createEmptyMovieClip("editor_mc", 0);
	}
	private function moveLeft() {
		_global.unSaved = true;		
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
		_global.unSaved = true;		
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
		_global.unSaved = true;		
		if (editor_dg.selectedIndex != undefined) {
			if (editor_dg.selectedIndex != editor_dg.length-1) {
				var tempObj = editor_dg.getItemAt(editor_dg.selectedIndex+1);
				editor_dg.replaceItemAt(editor_dg.selectedIndex+1, editor_dg.selectedItem);
				editor_dg.replaceItemAt(editor_dg.selectedIndex, tempObj);
				editor_dg.selectedIndex = undefined;
				editor_dg.selectedIndices = undefined;
			}
		}
	}
	private function moveDown() {
		_global.unSaved = true;		
		if (editor_dg.selectedIndex != undefined) {
			if (editor_dg.selectedIndex != 0) {
				var tempObj = editor_dg.getItemAt(editor_dg.selectedIndex-1);
				editor_dg.replaceItemAt(editor_dg.selectedIndex-1, editor_dg.selectedItem);
				editor_dg.replaceItemAt(editor_dg.selectedIndex, tempObj);
				editor_dg.selectedIndex = undefined;
				editor_dg.selectedIndices = undefined;
			}
		}
	}

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
		dataObject.setData({rows:newRows, type:type_ti.text});
		_global.saveFile("Project");
	}
}
