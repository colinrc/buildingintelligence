class Objects.Server.GC100Modules extends Objects.BaseElement {
	var modules:Array;
	public function getKeys():Array{
		var tempKeys = new Array();
		for(var module in modules){
			tempKeys = tempKeys.concat(modules[module].getKeys());
		}
		return tempKeys;
	}
	public function isValid():Boolean {
		var flag = true;
		for (var module in modules) {
			if (!modules[module].isValid()) {
				flag = false;
			}
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.device.gc100_modules";
	}
	public function toXML():XMLNode {
		var newModules = new XMLNode(1, "Modules");
		for (var module in modules) {
			newModules.appendChild(modules[module].toXML());
		}
		return newModules;
	}
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, getName());
		for (var module in modules) {
			newNode.appendChild(modules[module].toTree());
		}
		newNode.object = this;
		return newNode;
	}
	public function getName():String {
		return "GC100 Modules";
	}
	public function getData():Object {
		return new Object({modules:modules});
	}
	public function setData(newData:Object){
		//Process module changes....
		var newModules = new Array();
		for (var index in newData.modules) {
			var found = false;
			for (var module in modules) {
				if ((modules[module].name == newData.modules[index].name) && (modules[module].type == newData.modules[index].type)) {
					found = true;
				}
			}
			if (found == false) {
				newModules.push({name:newData.modules[index].name, type:newData.modules[index].type});
			}
		}
		var deletedModules = new Array();
		for (var module in modules) {
			var found = false;
			for (var index in newData.modules) {
				if ((modules[module].name == newData.modules[index].name) && (modules[module].type == newData.modules[index].type)) {
					found = true;
				}
			}
			if (found == false) {
				modules.splice(parseInt(module), 1);
			}
		}
		for (var newModule in newModules) {
			switch (newModules[newModule].type) {
			case "GC100_Relay" :
				var newNode = new XMLNode(1, "GC100_Relay");
				newNode.attributes["NAME"] = newModules[newModule].name;
				var newModule = new Objects.Server.GC100_Relay();
				newModule.setXML(newNode);
				modules.push(newModule);
				break;
			case "GC100_IR" :
				var newNode = new XMLNode(1, "GC100_IR");
				newNode.attributes["NAME"] = newModules[newModule].name;
				var newModule = new Objects.Server.GC100_IR();
				newModule.setXML(newNode);
				modules.push(newModule);
				break;
			}
		}

	}
	public function setXML(newData:XMLNode):Void {
		modules = new Array();
		for (var child in newData.childNodes) {
			switch(newData.childNodes[child].nodeName){
				case"GC100_Relay":
				var newModule = new Objects.Server.GC100_Relay();
				newModule.setXML(newData.childNodes[child]);
				modules.push(newModule);
				break;
				case"GC100_IR":
				var newModule = new Objects.Server.GC100_IR();
				newModule.setXML(newData.childNodes[child]);
				modules.push(newModule);
				break;
			}
		}
	}
}
