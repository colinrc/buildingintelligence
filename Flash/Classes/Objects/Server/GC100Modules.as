class Objects.Server.GC100Modules extends Objects.BaseElement {
	var modules:Array;
	private var treeNode:XMLNode;	
	public function isValid():Boolean {
		var flag = true;
		/*for (var module in modules) {
			if (!modules[module].isValid()) {
				flag = false;
			}
		}*/
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
