import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.Sounds extends Forms.BaseForm {
	private var sounds:Array;
	private var sounds_dg:DataGrid;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var save_btn:Button;
	private var dataGridHandler:Object;
	private var dataObject:Object;			
	public function onLoad() {
		var soundDP = new Array();
		var mySounds = mdm.FileSystem.getFileList(mdm.Application.path+"lib\\sounds", "*.mp3");
		for(var mySound =0; mySound <mySounds.length; mySound++){
			var newSound = new Object();
			newSound.label = "sounds\\"+mySounds[mySound];
			soundDP.push(newSound);
		}		
		var restrictions = new Object();
		restrictions.maxChars = undefined;
		restrictions.restrict = "";
		var volRestrictions = new Object();
		volRestrictions.maxChars = 3;
		volRestrictions.restrict = "0-9";		
		var attributes = new Object();
		attributes.label = "Play";
		dataGridHandler = new Forms.DataGrid.DynamicDataGrid();
		dataGridHandler.setDataGrid(sounds_dg);
		dataGridHandler.addTextInputColumn("name", "Sound Name", restrictions,false,100);
		dataGridHandler.addComboBoxColumn("file", "File", soundDP, false, 150);		
		dataGridHandler.addTextInputColumn("volume", "Volume", volRestrictions,false,60);
		dataGridHandler.addButtonColumn("Play", "Play", attributes, Delegate.create(this, previewItem),false,150);
		var DP = new Array();
		for (var sound in sounds) {
			var newSound = new Object();
			newSound.name = "";
			newSound.file = "";
			newSound.volume = "";
			if (sounds[sound].attributes["name"] != undefined) {
				newSound.name = sounds[sound].attributes["name"];
			}
			if (sounds[sound].attributes["file"] != undefined) {
				newSound.file = sounds[sound].attributes["file"];
			}
			if (sounds[sound].attributes["volume"] != undefined) {
				newSound.volume = sounds[sound].attributes["volume"];
			}
			DP.push(newSound);
		}
		dataGridHandler.setDataGridDataProvider(DP);
		delete_btn.addEventListener("click", Delegate.create(this, deleteItem));
		new_btn.addEventListener("click", Delegate.create(this, newItem));
		save_btn.addEventListener("click", Delegate.create(this, save));
	}
	public function previewItem(itemLocation:Object) {
		var DP = dataGridHandler.getDataGridDataProvider();
		var file = DP[itemLocation.itemIndex].file;
		var my_sound:Sound = new Sound();
		my_sound.setVolume(DP[itemLocation.itemIndex].volume);		
		my_sound.onLoad = function(success:Boolean) {
			if (success) {
				this.start();
			}
		};
		my_sound.loadSound("lib\\"+file, true);
	}
	private function deleteItem() {
		dataGridHandler.removeRow();
	}
	private function newItem() {
		dataGridHandler.addBlankRow();
	}
	private function save():Void {
		var newSounds = new Array();
		var DP = dataGridHandler.getDataGridDataProvider();
		for (var index = 0; index < DP.length; index++) {
			var sound = new XMLNode(1, "sound");
			if (DP[index].name != undefined) {
				sound.attributes["name"] = DP[index].name;
			}
			if (DP[index].file != undefined) {
				sound.attributes["file"] = DP[index].file;
			}
			if (DP[index].volume != undefined) {
				sound.attributes["volume"] = DP[index].volume;
			}
			newSounds.push(sound);
		}
		var tempIndex = _global.left_tree.selectedIndex;
		dataObject.setData({sounds:newSounds});
		//if (dataObject.isValid() != null){
			_global.infoflow_ta.text = dataObject.getValidationMsg();
		//}
		_global.refreshTheTree();		
		_global.saveFile("Project");
	}
}
