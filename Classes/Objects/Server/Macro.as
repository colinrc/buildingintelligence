class Objects.Server.Macro extends Objects.BaseElement {
	private var name:String;
	private var steps:Array;
	private var noEdit:Boolean;
	private var noDelete:Boolean;
	private var isSecure:Boolean;
	private var isHidden:Boolean;
	private var integrator:Boolean;
	private var treeNode:XMLNode;
	public function deleteSelf(){
		treeNode.removeNode();
	}
	public function Macro() {
		name = "";
		steps = new Array();
		noEdit = false;
		noDelete = false;
		isSecure = false;
		isHidden = false;
		integrator = false;
	}
	public function getForm():String {
		return "forms.project.macro";
	}
	public function publish():XMLNode {
		var newMacro = new XMLNode(1, "CONTROL");
		newMacro.attributes.KEY = "MACRO";
		newMacro.attributes.COMMAND = "getList";
		if(integrator){
			newMacro.attributes.EXTRA = "_"+name;
		} else{
			newMacro.attributes.EXTRA = name;
		}
		newMacro.attributes.TYPE = "";
		newMacro.attributes.RUNNING = "0";
		var status = new Array();
		if (noEdit) {
			status.push("noEdit");
		}
		if (noDelete) {
			status.push("noDelete");
		}
		if (isSecure) {
			status.push("isSecure");
		}
		if (isHidden) {
			status.push("isHidden");
		}
		newMacro.attributes.STATUS = status.join(",");
		for (var step = 0; step < steps.length; step++) {
			var newStep = new XMLNode(1, "CONTROL");
			if (steps[step].key != undefined) {
				newStep.attributes.KEY = steps[step].key;
			} else {
				newStep.attributes.KEY = "";
			}
			if (steps[step].command != undefined) {
				newStep.attributes.COMMAND = steps[step].command;
			} else {
				newStep.attributes.COMMAND = "";
			}
			if (steps[step].extra != undefined) {
				newStep.attributes.EXTRA = steps[step].extra;
			} else {
				newStep.attributes.EXTRA = "";
			}
			if (steps[step].extra2 != undefined) {
				newStep.attributes.EXTRA2 = steps[step].extra2;
			} else {
				newStep.attributes.EXTRA2 = "";
			}
			if (steps[step].extra3 != undefined) {
				newStep.attributes.EXTRA3 = steps[step].extra3;
			} else {
				newStep.attributes.EXTRA3 = "";
			}
			if (steps[step].extra4 != undefined) {
				newStep.attributes.EXTRA4 = steps[step].extra4;
			} else {
				newStep.attributes.EXTRA4 = "";
			}
			if (steps[step].extra5 != undefined) {
				newStep.attributes.EXTRA5 = steps[step].extra5;
			} else {
				newStep.attributes.EXTRA5 = "";
			}
			if (steps[step].target != undefined) {
				newStep.attributes.TARGET = steps[step].target;
			} else {
				newStep.attributes.TARGET = "All";
			}
			if (steps[step].target_user != undefined) {
				newStep.attributes.TARGET_USER = steps[step].target_user;
			} else {
				newStep.attributes.TARGET_USER = "";
			}
			newMacro.appendChild(newStep);
		}
		return newMacro;
	}
	public function toXML():XMLNode {
		var newMacro = new XMLNode(1, "CONTROL");
		newMacro.attributes.KEY = "MACRO";
		newMacro.attributes.COMMAND = "getList";
		newMacro.attributes.EXTRA = name;
		newMacro.attributes.TYPE = "";
		newMacro.attributes.RUNNING = "0";
		newMacro.attributes.integrator = integrator;
		var status = new Array();
		if (noEdit) {
			status.push("noEdit");
		}
		if (noDelete) {
			status.push("noDelete");
		}
		if (isSecure) {
			status.push("isSecure");
		}
		if (isHidden) {
			status.push("isHidden");
		}
		newMacro.attributes.STATUS = status.join(",");
		for (var step = 0; step < steps.length; step++) {
			var newStep = new XMLNode(1, "CONTROL");
			if (steps[step].key != undefined) {
				newStep.attributes.KEY = steps[step].key;
			} else {
				newStep.attributes.KEY = "";
			}
			if (steps[step].command != undefined) {
				newStep.attributes.COMMAND = steps[step].command;
			} else {
				newStep.attributes.COMMAND = "";
			}
			if (steps[step].extra != undefined) {
				newStep.attributes.EXTRA = steps[step].extra;
			} else {
				newStep.attributes.EXTRA = "";
			}
			if (steps[step].extra2 != undefined) {
				newStep.attributes.EXTRA2 = steps[step].extra2;
			} else {
				newStep.attributes.EXTRA2 = "";
			}
			if (steps[step].extra3 != undefined) {
				newStep.attributes.EXTRA3 = steps[step].extra3;
			} else {
				newStep.attributes.EXTRA3 = "";
			}
			if (steps[step].extra4 != undefined) {
				newStep.attributes.EXTRA4 = steps[step].extra4;
			} else {
				newStep.attributes.EXTRA4 = "";
			}
			if (steps[step].extra5 != undefined) {
				newStep.attributes.EXTRA5 = steps[step].extra5;
			} else {
				newStep.attributes.EXTRA5 = "";
			}
			if (steps[step].target != undefined) {
				newStep.attributes.TARGET = steps[step].target;
			} else {
				newStep.attributes.TARGET = "All";
			}
			if (steps[step].target_user != undefined) {
				newStep.attributes.TARGET_USER = steps[step].target_user;
			} else {
				newStep.attributes.TARGET_USER = "";
			}
			newMacro.appendChild(newStep);
		}
		return newMacro;
	}
	public function getName():String {
		return name;
	}
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, "Macro");
		newNode.object = this;
		treeNode = newNode;
		return newNode;
	}
	public function getKey():String {
		return "Macro";
	}
	public function getData():Object {
		return {steps:steps, name:name, noEdit:noEdit, noDelete:noDelete, isSecure:isSecure, isHidden:isHidden, integrator:integrator, dataObject:this};
	}
	public function setData(newData:Object):Void {
		steps = newData.steps;
		name = newData.name;
		noEdit = newData.noEdit;
		noDelete = newData.noDelete;
		isSecure = newData.isSecure;
		isHidden = newData.isHidden;
		integrator = newData.integrator;
	}
	public function setXML(newData:XMLNode):Void {
		steps = new Array();
		noEdit = false;
		noDelete = false;
		isSecure = false;
		isHidden = false;
		integrator = false;
		if (newData.nodeName == "CONTROL") {
			name = newData.attributes.EXTRA;
			var tempStatus = newData.attributes.STATUS.split(",");
			for (var status in tempStatus) {
				switch (tempStatus[status]) {
				case "noEdit" :
					noEdit = true;
					break;
				case "noDelete" :
					noDelete = true;
					break;
				case "isSecure" :
					isSecure = true;
					break;
				case "isHidden" :
					isHidden = true;
					break;
				}
			}
			if(newData.attributes.integrator == "true"){
				integrator = true;
			}
			for (var child = 0; child < newData.childNodes.length; child++) {
				var newStep = new Object();
				if (newData.childNodes[child].attributes.KEY != undefined) {
					newStep.key = newData.childNodes[child].attributes.KEY;
				} else {
					newStep.key = "";
				}
				if (newData.childNodes[child].attributes.COMMAND != undefined) {
					newStep.command = newData.childNodes[child].attributes.COMMAND;
				} else {
					newStep.command = "";
				}
				if (newData.childNodes[child].attributes.EXTRA != undefined) {
					newStep.extra = newData.childNodes[child].attributes.EXTRA;
				} else {
					newStep.extra = "";
				}
				if (newData.childNodes[child].attributes.EXTRA2 != undefined) {
					newStep.extra2 = newData.childNodes[child].attributes.EXTRA2;
				} else {
					newStep.extra2 = "";
				}
				if (newData.childNodes[child].attributes.EXTRA3 != undefined) {
					newStep.extra3 = newData.childNodes[child].attributes.EXTRA3;
				} else {
					newStep.extra3 = "";
				}
				if (newData.childNodes[child].attributes.EXTRA4 != undefined) {
					newStep.extra4 = newData.childNodes[child].attributes.EXTRA4;
				} else {
					newStep.extra4 = "";
				}
				if (newData.childNodes[child].attributes.EXTRA5 != undefined) {
					newStep.extra5 = newData.childNodes[child].attributes.EXTRA5;
				} else {
					newStep.extra5 = "";
				}
				if (newData.childNodes[child].attributes.TARGET != undefined) {
					newStep.target = newData.childNodes[child].attributes.TARGET;
				} else {
					newStep.target = "All";
				}
				if (newData.childNodes[child].attributes.TARGET_USER != undefined) {
					newStep.target_user = newData.childNodes[child].attributes.TARGET_USER;
				} else {
					newStep.target_user = "";
				}
				steps.push(newStep);
			}
		} else {
			trace("ERROR, found node " + newData.nodeName + ", expecting CONTROL");
		}
	}
}
