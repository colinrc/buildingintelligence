import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.ArbitraryObject extends Forms.BaseForm {
	private var src_cmb:ComboBox;
	private var key_cmb:ComboBox;
	private var width_ti:TextInput;
	private var height_ti:TextInput;
	private var show_cmb:ComboBox;
	private var hide_cmb:ComboBox;
	private var currentAlert:Object;
	public function onLoad():Void {
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
		var tempKeys = _global.serverDesign.getKeys();
		var DPKey = new Array();
		DPKey.push({label:""});
		for (var key in tempKeys) {
			var tempObject = new Object();
			tempObject.label = tempKeys[key];
			DPKey.push(tempObject);
		}
		key_cmb.dataProvider = DPKey;
		key_cmb.text = currentAlert.key;
		var myBGs = mdm.FileSystem.getFileList(mdm.Application.path+"lib\\object", "*.jpg");
		myBGs = myBGs.concat(mdm.FileSystem.getFileList(mdm.Application.path+"lib\\backgrounds", "*.png"));
		myBGs = myBGs.concat(mdm.FileSystem.getFileList(mdm.Application.path+"lib\\backgrounds", "*.swf"));		
		myBGs.sort();
		src_cmb.addItem({label:""});
		for(var myBG =0; myBG <myBGs.length; myBG++){
			var newBG = new Object();
			newBG.label = myBGs[myBG];
			src_cmb.addItem(newBG);
		}		
		src_cmb.text = currentAlert.src;
		width_ti.restrict = "0-9";
		width_ti.text = currentAlert.width;
		height_ti.restrict = "0-9";
		height_ti.text = currentAlert.height;
		show_cmb.dataProvider = DPControl;
		show_cmb.text = currentAlert.show;
		hide_cmb.dataProvider = DPControl;
		hide_cmb.text = currentAlert.hide;
		src_cmb.addEventListener("change", Delegate.create(this,changeListener));	
		key_cmb.addEventListener("change", Delegate.create(this,changeListener));		
		width_ti.addEventListener("change", Delegate.create(this,changeListener));
		height_ti.addEventListener("change", Delegate.create(this,changeListener));		
		show_cmb.addEventListener("change", Delegate.create(this,changeListener));		
		hide_cmb.addEventListener("change", Delegate.create(this,changeListener));
	}
	function changeListener(){
		_global.unSaved = true;
		currentAlert.src = src_cmb.text;
		currentAlert.key = key_cmb.text;
		currentAlert.width = width_ti.text;
		currentAlert.height = height_ti.text;
		currentAlert.show = show_cmb.text;
		currentAlert.hide = hide_cmb.text;
	}
}
