class Objects.Server.GC100IRs extends Objects.BaseElement {
	private var container:String;
	private var irs:Array;
	private var modules:Object;
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
	public function isValid():Boolean {
		var flag = true;
		/*for (var ir in irs) {
			if ((irs[ir].attributes["KEY"] == undefined) || (irs[ir].attributes["KEY"] == "")) {
				flag = false;
			}
			if ((irs[ir].attributes["NAME"] == undefined) || (irs[ir].attributes["NAME"] == "")) {
				flag = false;
			}
			if ((irs[ir].attributes["AV_NAME"] == undefined) || (irs[ir].attributes["AV_NAME"] == "")) {
				flag = false;
			}
		}*/
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
		return newNode;
	}
	public function getKey():String {
		return "IRs";
	}
	public function setData(newData:Object){
		irs = newData.irs;
	}
	public function getData():Object {
		return {irs:irs,modules:modules.getData().modules, dataObject:this};
	}
}
