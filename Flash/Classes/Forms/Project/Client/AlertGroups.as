import mx.controls.*;
import Controls.MapEditor;
import mx.utils.Delegate;
class Forms.Project.Client.AlertGroups extends Forms.BaseForm {
	private var alertgroups:Array;
	private var poly:String;
	private var roomEditor:MapEditor;
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
		roomEditor.map = map;
		roomEditor.mapMode = "alertGroups";
		roomEditor.poly = poly;
		roomEditor.alerts = DP;
		//roomEditor.alerts = [{name:"test 1", icon:"heater", keys:"a,b,c,d,e,f", x:400, y:300}, {name:"test 2", icon:"fan", keys:"q,t,r,f,y,h", x:300, y:200}];
		
		var editorListener = new Object();
		editorListener.alertSelect = function (eventObj) {
			_global.unSaved = true;	
		}
		editorListener.alertAdd = function (eventObj) {
			_global.unSaved = true;	
		}
		editorListener.alertMove = function (eventObj) {
			_global.unSaved = true;	
		}
		editorListener.alertNew = function (eventObj) {
			_global.unSaved = true;	
		}
		editorListener.alertDelete = function (eventObj) {
			_global.unSaved = true;	
		}
		roomEditor.addEventListener("alertSelect", editorListener);
		roomEditor.addEventListener("alertAdd", editorListener);
		roomEditor.addEventListener("alertMove", editorListener);
		roomEditor.addEventListener("alertNew", editorListener);
		roomEditor.addEventListener("alertDelete", editorListener);
		save_btn.addEventListener("click", Delegate.create(this, save));
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
}
