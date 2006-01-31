import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.Sounds extends Forms.BaseForm {
	private var sounds:Array;
	private var sounds_dg:DataGrid;
	private var update_btn:Button;
	private var new_btn:Button;
	private var delete_btn:Button;
	private var save_btn:Button;
	private var play_btn:Button;
	private var name_ti:TextInput;
	private var file_ti:TextInput;
	private var volume_ti:TextInput;
	public function init() {
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
			sounds_dg.addItem(newSound);
		}
		delete_btn.enabled = false;
		play_btn.enabled = false;
		update_btn.enabled = true;
		delete_btn.addEventListener("click", Delegate.create(this, deleteSound));
		play_btn.addEventListener("click", Delegate.create(this, previewItem));
		update_btn.addEventListener("click", Delegate.create(this, updateSound));
		new_btn.addEventListener("click", Delegate.create(this, newItem));
		save_btn.addEventListener("click", Delegate.create(this, save));
		sounds_dg.addEventListener("change", Delegate.create(this, soundChange));
	}
	private function previewItem() {
		/*var file = sounds_dg.selectedItem.file;
		var my_sound:Sound = new Sound();
		my_sound.setVolume(50);
		my_sound.onLoad = function(success:Boolean) {
			if (success) {
				my_sound.start();
			}
		};
		my_sound.loadSound(file, true);*/
	}
	private function deleteSound() {
		sounds_dg.removeItemAt(sounds_dg.selectedIndex);
		sounds_dg.selectedIndex = undefined;
		delete_btn.enabled = false;
		play_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function updateSound() {
		if (sounds_dg.selectedIndex != undefined) {
			sounds_dg.getItemAt(sounds_dg.selectedIndex).name = name_ti.text;
			sounds_dg.getItemAt(sounds_dg.selectedIndex).file = file_ti.text;
			sounds_dg.getItemAt(sounds_dg.selectedIndex).volume = volume_ti.text;
		} else {
			sounds_dg.addItem({name:name_ti.text, file:file_ti.text, volume:volume_ti.text});
		}
		sounds_dg.selectedIndex = undefined;
		delete_btn.enabled = false;
		play_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function newItem() {
		sounds_dg.selectedIndex = undefined;
		name_ti.text = "";
		file_ti.text = "";
		volume_ti.text = "";
		delete_btn.enabled = false;
		play_btn.enabled = false;
		update_btn.enabled = true;
	}
	private function soundChange(evtObj) {
		name_ti.text = sounds_dg.selectedItem.name;
		file_ti.text = sounds_dg.selectedItem.file;
		volume_ti.text = sounds_dg.selectedItem.volume;
		update_btn.enabled = true;
		delete_btn.enabled = true;
		play_btn.enabled = true;
	}
	private function save():Void {
		var newSounds = new Array();
		for (var index = 0; index<sounds_dg.length; index++) {
			var sound = new XMLNode(1, "sound");
			if (sounds_dg.getItemAt(index).name != undefined) {
				sound.attributes["name"] = sounds_dg.getItemAt(index).name;
			}
			if (sounds_dg.getItemAt(index).file != undefined) {
				sound.attributes["file"] = sounds_dg.getItemAt(index).file;
			}
			if (sounds_dg.getItemAt(index).volume != undefined) {
				sound.attributes["volume"] = sounds_dg.getItemAt(index).volume;
			}
			newSounds.push(sound);
		}
		var tempIndex = _global.left_tree.selectedIndex;
		_global.left_tree.selectedNode.object.setData(new Object({sounds:newSounds}));
		_global.left_tree.selectedNode = _global.left_tree.selectedNode.object.toTree();
		_global.left_tree.selectedIndex = tempIndex;
	}
}
