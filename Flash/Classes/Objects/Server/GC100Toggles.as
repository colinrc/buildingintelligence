class Objects.Server.GC100Toggles extends Objects.BaseElement {
	private var container:String;
	private var toggle_type:String;
	private var toggles:Array;
	private var modules:Object;
	public function getKeys():Array{
		var tempKeys = new Array();
		for(var toggle in toggles){
			tempKeys.push(toggles[toggle].display_name);
		}
		return tempKeys;
	}
	public function GC100Toggles(inToggle_type:String) {
		toggle_type = inToggle_type;
	}
	public function setModules(inModules:Object){
		modules = inModules;
	}
	public function isValid():Boolean {
		var flag = true;
		/*for (var toggle in toggles) {
			if ((toggles[toggle].attributes["ACTIVE"] != "Y") && (toggles[toggle].attributes["ACTIVE"] != "N")) {
				flag = false;
			}
			if ((toggles[toggle].attributes["KEY"] == undefined) || (toggles[toggle].attributes["KEY"] == "")) {
				flag = false;
			}
			if ((toggles[toggle].attributes["NAME"] == undefined) || (toggles[toggle].attributes["NAME"] == "")) {
				flag = false;
			}
			if ((toggles[toggle].attributes["DISPLAY_NAME"] == undefined) || (toggles[toggle].attributes["DISPLAY_NAME"] == "")) {
				flag = false;
			}
		}*/
		return flag;
	}
	public function getForm():String {
		return "forms.project.device.gc100toggle";
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1,this.getName());
		newNode.object = this;
		return newNode;
	}
	public function getKey():String {
		return "Toggles";
	}
	public function getName():String {
		switch(toggle_type){
			case"TOGGLE_INPUT":
			return "Toggle Inputs";
			break;
			case"TOGGLE_OUTPUT":
			return "Toggle Outputs";
			break;
		}
	}
	public function getData():Object {
		return {toggles:toggles,toggle_type:toggle_type,modules:modules.getData().modules, dataObject:this};
	}
	public function setData(newData:Object):Void{
		toggles = newData.toggles;
	}
}
