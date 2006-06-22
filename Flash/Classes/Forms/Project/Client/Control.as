import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.Control extends Forms.BaseForm {
	private var type:String;
	private var type_ti:TextInput;
	private var save_btn:Button;
	private var editor:MovieClip;
	private var controlTypeData:XMLNode;
	private var dataObject:Object;	
	public function onLoad() {
		type_ti.text = type;
		editor= attachMovie("controlTypeEditor", "controlTypeEditor_mc", 0, {_y:30,controlTypeData:new XML(controlTypeData.toString()), iconPath:mdm.Application.path+"lib/icons/"});
		save_btn.addEventListener("click", Delegate.create(this, save));
	}
	public function save():Void {
/*		var newRows = new Array();
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
		}*/
		dataObject.setData({controlTypeData:editor.controlTypeData.firstChild, type:type_ti.text});
		editor.controlTypeData = new XML(dataObject.getData().controlTypeData.toString());
		_global.refreshTheTree();		
		_global.saveFile("Project");	
	}
}
