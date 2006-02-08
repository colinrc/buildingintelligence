import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.Sounds extends Forms.BaseForm {
	private var sounds:Array;
	private var sounds_dg:DataGrid;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var save_btn:Button;
	private var dataGridHandler:Object;
	public function init() {
		var restrictions = new Object();
		restrictions.maxChars = undefined;
		restrictions.restrict = "";
		var attributes = new Object();
		attributes.label = "Coming Soon!";
		dataGridHandler = new Forms.DataGrid.DynamicDataGrid();
		dataGridHandler.setDataGrid(sounds_dg);
		dataGridHandler.addTextInputColumn("name", "Sound Name", restrictions);
		dataGridHandler.addTextInputColumn("file", "File", restrictions);
		dataGridHandler.addTextInputColumn("volume", "Volume", restrictions);
		dataGridHandler.addButtonColumn("Play", "Play", attributes, previewItem);
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
		//var DP = dataGridHandler.getDataGridDataProvider();
		//var file = DP[itemLocation.itemIndex].file;
		new_btn.label = itemLocation.itemIndex;
		/*var my_sound:Sound = new Sound();
		my_sound.onLoad = function(success:Boolean) {
		if (success) {
		this.setVolume(DP[itemLocation.itemIndex].volume);
		this.start();
		}
		};
		my_sound.loadSound(file, true);*/
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
		for (var index = 0; index<DP.length; index++) {
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
		_global.left_tree.selectedNode.object.setData(new Object({sounds:newSounds}));
		_global.left_tree.selectedNode = _global.left_tree.selectedNode.object.toTree();
		_global.left_tree.selectedIndex = tempIndex;
	}
}
