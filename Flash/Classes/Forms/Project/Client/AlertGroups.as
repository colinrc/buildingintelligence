﻿import mx.controls.*;
import Controls.MapEditor;
import mx.utils.Delegate;

class Forms.Project.Client.AlertGroups extends Forms.BaseForm {
	private var alertgroups:Array;
	private var poly:String;
	private var roomEditor:MapEditor;
	private var name_lb:Label;
	private var name_ti:TextInput;
	private var map:String;
	private var save_btn:Button;
	private var dataObject:Object;
	
	public function onLoad() {
		var DP = new Array();
		for (var alertgroup in alertgroups) {
			var newAlertGroup = new Object();
			newAlertGroup.x = alertgroups[alertgroup].x_pos;
			newAlertGroup.y = alertgroups[alertgroup].y_pos;
			newAlertGroup.id = alertgroups[alertgroup].id;			
			DP.push(newAlertGroup);
		}
		roomEditor.map = "lib/maps/"+map;
		roomEditor.mapMode = "alertGroups";
		roomEditor.poly = poly;
		roomEditor.alerts = DP;
		toggleDetails(false);
		
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
