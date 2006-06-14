class Objects.Server.GC100Modules extends Objects.BaseElement {
	var modules:Array;
	private var treeNode:XMLNode;	
	public function isValid():String {
		var flag = "ok";
		clearValidationMsg();
		for (var module in modules) {
			if ((modules[module].name == undefined) || (modules[module].name == "")) {
				flag = "error";
				appendValidationMsg("Name is empty");
			}
			if ((modules[module].type == undefined) || (modules[module].type == "")) {
				flag = "error";
				appendValidationMsg("Type is invalid");
			}
			if ((modules[module].number == undefined) || (modules[module].number == "")) {
				flag = "error";
				appendValidationMsg("Number is invalid");
			}
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.device.gc100_modules";
	}
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, getName());
		/*for (var module in modules) {
			newNode.appendChild(modules[module].toTree());
		}*/
		newNode.object = this;
		treeNode = newNode;				
		return newNode;
	}
	public function getKey():String {
		return "GC100Modules";
	}
	public function getName():String {
		return "GC100 Modules";
	}
	public function getData():Object {
		return {modules:modules, dataObject:this};
	}
	public function setData(newData:Object){
		modules = newData.modules;
	}
}
