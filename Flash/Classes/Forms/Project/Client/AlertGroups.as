import mx.controls.*;
import Controls.MapEditor;
import mx.utils.Delegate;

class Forms.Project.Client.AlertGroups extends Forms.BaseForm {
	private var alertgroups:Array;
	private var poly:String;
	private var roomEditor:MapEditor;
	private var name_lb:Label;
	private var name_ti:TextInput;
	private var map:String;
	private var background:String;
	private var save_btn:Button;
	private var dataObject:Object;
	private var currentAlert:Object;
	public function onLoad() {
		var DP = new Array();
		for (var alertgroup in alertgroups) {
			var newAlertGroup = new Object();
			newAlertGroup.x = alertgroups[alertgroup].x_pos;
			newAlertGroup.y = alertgroups[alertgroup].y_pos;
			newAlertGroup.id = alertgroups[alertgroup].id;			
			newAlertGroup.name = alertgroups[alertgroup].name;
			DP.push(newAlertGroup);
		}
		if(map == undefined){
			map = "";
		}
		roomEditor.map = "lib/maps/"+map;
		if((background != undefined)&&(background != "")){
			roomEditor.background = "lib/backgrounds/"+background;
		}
		roomEditor.mapMode = "alertGroups";
		roomEditor.poly = poly;
		roomEditor.alerts = DP;
		toggleDetails(false);
		currentAlert = undefined;
		var changeListener:Object = new Object();
		changeListener.change = function(eventObject:Object) {
			currentAlert.name = name_ti.text;
			_global.unSaved = true;
		};
		name_ti.addEventListener("change", changeListener);
		roomEditor.addEventListener("alertSelect", Delegate.create(this, alertEvent));
		roomEditor.addEventListener("alertAdd", Delegate.create(this, alertEvent));
		roomEditor.addEventListener("alertMove", Delegate.create(this, alertEvent));
		roomEditor.addEventListener("alertNew", Delegate.create(this, alertEvent));
		roomEditor.addEventListener("alertDelete", Delegate.create(this, alertEvent));
		save_btn.addEventListener("click", Delegate.create(this, save));
	}
	
	private function alertEvent (eventObj) {
		_global.unSaved = true;
		if (eventObj.type == "alertDelete") {
			toggleDetails(false);
		} else {
			toggleDetails(true);
		}
		currentAlert = undefined;
		name_ti.text = eventObj.target.name;
		currentAlert = eventObj.target;
	}
		
	public function save():Void {
		var newAlertGroup = new Array();
		var DP = roomEditor.alerts;
		for (var index = 0; index<DP.length; index++) {
			var AlertGroup = new Object();
			AlertGroup.x_pos = DP[index].x;
			AlertGroup.y_pos = DP[index].y;
			if(DP[index].id != "0"){
				AlertGroup.id = DP[index].id;
			}
			AlertGroup.name = DP[index].name;
			newAlertGroup.push(AlertGroup);
		}
		dataObject.setData({alertgroups:newAlertGroup});
		_global.refreshTheTree();		
		_global.saveFile("Project");	
	}

	private function toggleDetails(show:Boolean):Void {
		if (show) {
			roomEditor.setSize(null, 540);
		} else {
			roomEditor.setSize(null, 565);
		}
		name_lb._visible = name_ti._visible = show;
	}
}
