class Objects.Server.GC100IRs extends Objects.BaseElement {
	private var container:String;
	private var irs:Array;
	private var modules:Object;
	private var treeNode:XMLNode;	
	public function setModules(inModules:Object){
		modules = inModules;
	}
	public function getKeys():Array{
		var tempKeys = new Array();
		for(var ir in irs){
			tempKeys.push(irs[ir].av_name);
		}
		return tempKeys;
	}
	public function isValid():String {
		var flag = "ok";
		clearValidationMsg();
		for (var ir in irs) {
			if ((irs[ir].key == undefined) || (irs[ir].key == "")) {
				flag = "error";
				appendValidationMsg("Key is invalid");
			}
			if ((irs[ir].name == undefined) || (irs[ir].name == "")) {
				flag = "error";
				appendValidationMsg("Name is invalid");
			}
			if ((irs[ir].avname == undefined) || (irs[ir].avname == "")) {
				flag = "error";
				appendValidationMsg("AV Name is invalid");
			}
			if ((modules.modules == undefined) || (modules.modules.length == 0)) {
				flag = "error";
				appendValidationMsg("Add GC100 Modules");
			}
			else {
				if ((irs[ir].module == undefined) || (irs[ir].module == "")) {
					flag = "error";
					appendValidationMsg("Select a GC100 Module");
				}
			}
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.device.gc100ir";
	}
	public function getName():String {
		return "IR Inputs";
	}
	public function toTree():XMLNode{
		var newNode = new XMLNode(1,this.getName());
		newNode.object = this;
		treeNode = newNode;				
		return newNode;
	}
	public function getKey():String {
		return "GC100_IRs";
	}
	public function setData(newData:Object){
		irs = newData.irs;
	}
	public function getData():Object {
		return {irs:irs,modules:modules.getData().modules, dataObject:this};
	}
}
