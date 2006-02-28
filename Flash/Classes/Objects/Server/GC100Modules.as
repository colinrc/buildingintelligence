class Objects.Server.GC100Modules extends Objects.BaseElement {
	var modules:Array;
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
		_global.workflow.addNode("GC100Modules",newNode);
		return newNode;
	}
	public function getName():String {
		return "GC100 Modules";
	}
	public function getData():Object {
		return {modules:modules};
	}
	public function setData(newData:Object){
		modules = newData.modules;
	}
}
