import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Macro extends Forms.BaseForm {
	private var steps:Array;
	private var steps_dg:DataGrid;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var up_btn:Button;
	private var down_btn:Button;
	private var save_btn:Button;
	private var dataGridHandler:Object;
	private var dataObject:Object;
	private var name_ti:TextInput;
	private var name:String;
	private var edit_chk:CheckBox;
	private var noEdit:Boolean;
	private var delete_chk:CheckBox;
	private var noDelete:Boolean;
	private var secure_chk:CheckBox;
	private var isSecure:Boolean;
	private var visible_chk:CheckBox;
	private var isHidden:Boolean;
	private var integrator_chk:CheckBox;
	private var integrator:Boolean;
	public function onLoad() {
		var tempKeys = _global.serverDesign.getKeys();
		var DPKey = new Array();
		DPKey.push({label:""});
		for (var key in tempKeys) {
			var tempObject = new Object();
			tempObject.label = tempKeys[key];
			DPKey.push(tempObject);
		}
		var DPControl = new Array();
		DPControl.push({label:"channel"});
		DPControl.push({label:"down"});
		DPControl.push({label:"goto"});
		DPControl.push({label:"keyPress"})
		DPControl.push({label:"on"});
		DPControl.push({label:"off"});
		DPControl.push({label:"pan"});
		DPControl.push({label:"pause"});
		DPControl.push({label:"tilt"});
		DPControl.push({label:"volume"});
		DPControl.push({label:"send_audio_command"});
		DPControl.push({label:"src"});
//		DPControl.push({label:"state"});
		DPControl.push({label:"up"});
		if(name != undefined){
			name_ti.text = name;
		} else{
			name_ti.text = "";
		}
		if(noEdit){
			edit_chk.selected = false;
		} else{
			edit_chk.selected = true;
		}
		if(noDelete){
			delete_chk.selected = false;
		} else{
			delete_chk.selected = true;
		}
		if(isSecure){
			secure_chk.selected = true;
		} else{
			secure_chk.selected = false;
		}
		if(isHidden){
			visible_chk.selected = false;
		} else{
			visible_chk.selected = true;
		}
		if(integrator){
			integrator_chk.selected = true;
		} else{
			integrator_chk.selected = false;
		}
		var restrictions = new Object();
		restrictions.maxChars = undefined;
		restrictions.restrict = "";
		dataGridHandler = new Forms.DataGrid.DynamicDataGrid();
		dataGridHandler.setDataGrid(steps_dg);
		dataGridHandler.addComboBoxColumn("key", "Key", DPKey, false, 100);
		dataGridHandler.addEditableComboBoxColumn("command", "Command", DPControl, false, 100);
		dataGridHandler.addTextInputColumn("extra", "Extra", restrictions,false,100);
		dataGridHandler.addTextInputColumn("extra2", "Extra 2", restrictions,false,100);
		dataGridHandler.addTextInputColumn("extra3", "Extra 3", restrictions,false,100);
		dataGridHandler.addTextInputColumn("extra4", "Extra 4", restrictions,false,100);
		dataGridHandler.addTextInputColumn("extra5", "Extra 5", restrictions,false,100);
		dataGridHandler.addHiddenColumn("id");
		var DP = new Array();
		for (var step = 0; step<steps.length;step++){						
			var newStep = new Object();
			newStep.key = steps[step].key;
			newStep.command = steps[step].command;
			newStep.extra = steps[step].extra;
			newStep.extra2 = steps[step].extra2;
			newStep.extra3 = steps[step].extra3;
			newStep.extra4 = steps[step].extra4;
			newStep.extra5 = steps[step].extra5;
			newStep.id = steps[step].id;
			DP.push(newStep);
		}
		dataGridHandler.setDataGridDataProvider(DP);
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		new_btn.addEventListener("click", Delegate.create(this, newItem));
		up_btn.addEventListener("click", Delegate.create(this, moveUp));
		down_btn.addEventListener("click", Delegate.create(this, moveDown));
		save_btn.addEventListener("click", Delegate.create(this, save));
	}
	private function moveUp() {
		_global.unSaved = true;
		if (steps_dg.selectedIndex != undefined) {
			if (steps_dg.selectedIndex != steps_dg.length - 1) {
				var tempObj = steps_dg.getItemAt(steps_dg.selectedIndex + 1);
				steps_dg.replaceItemAt(steps_dg.selectedIndex + 1, steps_dg.selectedItem);
				steps_dg.replaceItemAt(steps_dg.selectedIndex, tempObj);
				var tempIndex = steps_dg.selectedIndex + 1;
				steps_dg.selectedIndex = undefined;
				steps_dg.selectedIndices = undefined;
				steps_dg.selectedIndex = tempIndex;
			}
		}
	}
	private function moveDown() {
		_global.unSaved = true;
		if (steps_dg.selectedIndex != undefined) {
			if (steps_dg.selectedIndex != 0) {
				var tempObj = steps_dg.getItemAt(steps_dg.selectedIndex - 1);
				steps_dg.replaceItemAt(steps_dg.selectedIndex - 1, steps_dg.selectedItem);
				steps_dg.replaceItemAt(steps_dg.selectedIndex, tempObj);
				var tempIndex = steps_dg.selectedIndex - 1;
				steps_dg.selectedIndex = undefined;
				steps_dg.selectedIndices = undefined;
				steps_dg.selectedIndex = tempIndex;
			}
		}
	}
	private function deleteItem() {
		dataGridHandler.removeRow();
	}
	private function newItem() {
		dataGridHandler.addBlankRow();
	}
	public function save():Void {
		var newSteps = new Array();
		var DP = dataGridHandler.getDataGridDataProvider();
		for (var index = 0; index < DP.length; index++) {
			var Step = new Object();
			if(DP[index].key != undefined){
				Step.key = DP[index].key;
			} else{
				Step.key = "";
			}
			Step.command = DP[index].command;
			Step.extra = DP[index].extra;
			Step.extra2 = DP[index].extra2;
			Step.extra3 = DP[index].extra3;
			Step.extra4 = DP[index].extra4;
			Step.extra5 = DP[index].extra5;
			Step.id = DP[index].id;
			newSteps.push(Step);
		}
		if(edit_chk.selected){
			noEdit = false;
		} else{
			noEdit = true;
		}
		if(delete_chk.selected){			
			noDelete = false;
		} else{
			noDelete = true;
		}
		if(secure_chk.selected){
			isSecure = true;
		} else{
			isSecure = false;
		}
		if(visible_chk.selected){
			isHidden = false;
		} else{
			isHidden = true;
		}
		if(integrator_chk.selected){
			integrator = true;
		} else{
			integrator = false;
		}
		dataObject.setData({name:name_ti.text, isHidden:isHidden, noEdit:noEdit, noDelete:noDelete, isSecure:isSecure, integrator:integrator, steps:newSteps});
		_global.refreshTheTree();
		_global.saveFile("Project");
	}
}
