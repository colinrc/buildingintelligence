class Objects.Server.GC100Toggles extends Objects.BaseElement {
	private var container:String;
	private var toggle_type:String;
	private var toggles:Array;
	private var modules:Object;
	private var treeNode:XMLNode;	
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
	public function isValid():String {
		var flag = "ok";
		clearValidationMsg();
		for (var toggle in toggles) {
			if ((toggles[toggle].active != "Y") && (toggles[toggle].active != "N")) {
				flag = "error";
				appendValidationMsg("Active is invalid");
			}
			else {
				if (toggles[toggle].active =="Y"){
					if ((toggles[toggle].name == undefined) || (toggles[toggle].name == "")) {
						flag = "empty";
						appendValidationMsg("Description is empty");
					}
					if ((toggles[toggle].key == undefined) || (toggles[toggle].key == "")) {
						flag = "error";
						appendValidationMsg("Input/Output no. is empty");
					}
					if ((toggles[toggle].display_name == undefined) || (toggles[toggle].display_name == "")) {
						flag = "error";
						appendValidationMsg("Key is invalid");
					}
					else {
						if (_global.isKeyUsed(toggles[toggle].display_name) == false) {
							flag = "error";
							appendValidationMsg(toggles[toggle].display_name+" key is not used");
						}
					}
					
					var arrayTest:Array = modules.getData().modules;
					if ((arrayTest == undefined) || (arrayTest.length == 0)) {
						flag = "error";
						appendValidationMsg("Add GC100 Modules first");
					}
					else {
						if ((toggles[toggle].module == undefined) || (toggles[toggle].module.length == 0)) {
							flag = "error";
							appendValidationMsg("Select a GC100 Module");
						}
					}
				}
				else {
					if (toggles[toggle].active =="N"){
						flag = "empty";
						appendValidationMsg("GC100 Toggles is not active");
					}
				}
			}
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.device.gc100toggle";
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1,this.getName());
		newNode.object = this;
		treeNode = newNode;		
		return newNode;
	}
	public function getKey():String {
		return "GC100_Toggles";
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
