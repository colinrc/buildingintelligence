class Objects.Server.Macros extends Objects.BaseElement {
	private var macros:Array;
	private var treeNode:XMLNode;
	public function Macros(){
		macros = new Array();
	}
	public function getForm():String {
		return "forms.project.macros";
	}
	public function toXML():XMLNode {
		var tempNode = new XMLNode(1, "MACROS");
		for (var macro = 0; macro < macros.length; macro++) {
			tempNode.appendChild(macros[macro].toXML());
		}
		return tempNode;
	}
	public function getName():String {
		return "Macros";
	}
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, "Macros");
		newNode.object = this;
		for(var macro = 0; macro < macros.length; macro++){
			newNode.appendChild(macros[macro].toTree());
		}
		treeNode = newNode;
		return newNode;
	}
	public function getKey():String {
		return "Macros";
	}
	public function getData():Object {
		return {macros:macros, dataObject:this};
	}
	public function setData(newData:Object):Void {
		_global.left_tree.setIsOpen(treeNode, false);
		//Process macro changes....
		var newMacros = new Array();
		for (var index in newData.macros) {
			if (newData.macros[index].id == undefined) {
				newMacros.push({name:newData.macros[index].name});
			}
		}
		for (var macro in macros) {
			var found = false;
			for (var index in newData.macros) {
				if (macros[macro].id == newData.macros[index].id) {
					macros[macro].name = newData.macros[index].name;
					found = true;
				}
			}
			if (found == false) {
				macros[macro].deleteSelf();
				macros.splice(parseInt(macro), 1);
			}
		}
		for (var newMacro in newMacros) {
			var newNode = new XMLNode(1, "CONTROL");
			newNode.attributes["EXTRA"] = newMacros[newMacro].name;
			var newMacro = new Objects.Server.Macro();
			newMacro.setXML(newNode);
			newMacro.id = _global.formDepth++;			
			treeNode.appendChild(newMacro.toTree());	
			macros.push(newMacro);
		}
		_global.left_tree.setIsOpen(treeNode, true);
	}
	public function getMacros():Array{
		return macros;
	}
	public function setXML(newData:XMLNode):Void {
		macros = new Array();
		if (newData.nodeName == "MACROS") {
			for(var child = 0; child<newData.childNodes.length;child++){
				var newMacro = new Objects.Server.Macro();
				newMacro.setXML(newData.childNodes[child]);
				newMacro.id = _global.formDepth++;
				macros.push(newMacro);
			}
		} else {
			//mdm.Dialogs.prompt("ERROR, found node "+newData.nodeName+", expecting MACROS");
		}
	}
}
