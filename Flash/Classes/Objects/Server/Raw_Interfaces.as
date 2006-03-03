class Objects.Server.Raw_Interfaces extends Objects.BaseElement {
	var raw_interfaces:Array;
	var container:String;
	var catalogues:Objects.Server.Catalogues;
	public function getKeys():Array {
		var tempKeys = new Array();
		for (var raw_interface in raw_interfaces) {
			tempKeys.push(raw_interfaces[raw_interface].display_name);
		}
		return tempKeys;
	}
	public function isValid():Boolean {
		var flag = true;
		/*for (var raw_interface in raw_interfaces) {
		if (!raw_interfaces[raw_interface].isValid()) {
		flag = false;
		}
		}*/
		return flag;
	}
	public function getForm():String {
		return "forms.project.device.raw_interfaces";
	}
	public function toXML():XMLNode {
		var newRaw_Interfaces = new XMLNode(1, container);
		//raw_interfaces.sortOn(["display_name", "name", "catalogue", "code", "command"]);
		for (var index = 0; index < raw_interfaces.length; index++) {
			var foundInterface = false;
			for (var rawInterface in newRaw_Interfaces) {
				if ((newRaw_Interfaces[rawInterface].attributes.NAME == raw_interfaces[index].name) && (newRaw_Interfaces[rawInterface].attributes.DISPLAY_NAME == raw_interfaces[index].display_name)) {
					foundInterface = true;
					var foundItems = false;
					for (var rawItem in newRaw_Interfaces[rawInterface].childNodes) {
						if (newRaw_Interfaces[rawInterface].childNodes[rawItem].attributes.CATALOGUE == raw_interfaces[index].catalogue) {
							foundItems = true;
							var Raw = new XMLNode(1, "RAW");
							if (raw_interfaces[index].code.label.length) {
								Raw.attributes.CODE = raw_interfaces[index].code.label;
							}
							if (raw_interfaces[index].command.length) {
								Raw.attributes.COMMAND = raw_interfaces[index].command;
							}
							if (raw_interfaces[index].extra.length) {
								Raw.attributes.EXTRA = raw_interfaces[index].extra;
							}
							if (raw_interfaces[index].extra2.length) {
								Raw.attributes.EXTRA2 = raw_interfaces[index].extra2;
							}
							if (raw_interfaces[index].extra3.length) {
								Raw.attributes.EXTRA3 = raw_interfaces[index].extra3;
							}
							if (raw_interfaces[index].extra4.length) {
								Raw.attributes.EXTRA4 = raw_interfaces[index].extra4;
							}
							if (raw_interfaces[index].extra5.length) {
								Raw.attributes.EXTRA5 = raw_interfaces[index].extra5;
							}
							for (var variable in raw_interfaces[index].vars) {
								Raw.appendChild(raw_interfaces[index].vars[variable]);
							}
							newRaw_Interfaces[rawInterface].childNodes[rawItem].appendChild(Raw);
						}
					}
					if (!foundItems) {
						var Raw_Items = new XMLNode(1, "RAW_ITEMS");
						if (raw_interfaces[index].catalogue.length) {
							Raw_Items.attributes.CATALOGUE = raw_interfaces[index].catalogue;
						}
						var Raw = new XMLNode(1, "RAW");
						if (raw_interfaces[index].code.label.length) {
							Raw.attributes.CODE = raw_interfaces[index].code.label;
						}
						if (raw_interfaces[index].command.length) {
							Raw.attributes.COMMAND = raw_interfaces[index].command;
						}
						if (raw_interfaces[index].extra.length) {
							Raw.attributes.EXTRA = raw_interfaces[index].extra;
						}
						if (raw_interfaces[index].extra2.length) {
							Raw.attributes.EXTRA2 = raw_interfaces[index].extra2;
						}
						if (raw_interfaces[index].extra3.length) {
							Raw.attributes.EXTRA3 = raw_interfaces[index].extra3;
						}
						if (raw_interfaces[index].extra4.length) {
							Raw.attributes.EXTRA4 = raw_interfaces[index].extra4;
						}
						if (raw_interfaces[index].extra5.length) {
							Raw.attributes.EXTRA5 = raw_interfaces[index].extra5;
						}
						for (var variable in raw_interfaces[index].vars) {
							Raw.appendChild(raw_interfaces[index].vars[variable]);
						}
						Raw_Items.appendChild(Raw);
						newRaw_Interfaces[rawInterface].appendChild(Raw_Items);
					}
				}
			}
			if (!foundInterface) {
				var Raw_Interface = new XMLNode(1, "RAW_INTERFACE");
				if (raw_interfaces[index].name.length) {
					Raw_Interface.attributes.NAME = raw_interfaces[index].name;
				}
				if (raw_interfaces[index].display_name.length) {
					Raw_Interface.attributes.DISPLAY_NAME = raw_interfaces[index].display_name;
				}
				var Raw_Items = new XMLNode(1, "RAW_ITEMS");
				if (raw_interfaces[index].catalogue.length) {
					Raw_Items.attributes.CATALOGUE = raw_interfaces[index].catalogue;
				}
				var Raw = new XMLNode(1, "RAW");
				if (raw_interfaces[index].code.label.length) {
					Raw.attributes.CODE = raw_interfaces[index].code.label;
				}
				if (raw_interfaces[index].command.length) {
					Raw.attributes.COMMAND = raw_interfaces[index].command;
				}
				if (raw_interfaces[index].extra.length) {
					Raw.attributes.EXTRA = raw_interfaces[index].extra;
				}
				if (raw_interfaces[index].extra2.length) {
					Raw.attributes.EXTRA2 = raw_interfaces[index].extra2;
				}
				if (raw_interfaces[index].extra3.length) {
					Raw.attributes.EXTRA3 = raw_interfaces[index].extra3;
				}
				if (raw_interfaces[index].extra4.length) {
					Raw.attributes.EXTRA4 = raw_interfaces[index].extra4;
				}
				if (raw_interfaces[index].extra5.length) {
					Raw.attributes.EXTRA5 = raw_interfaces[index].extra5;
				}
				for (var variable in raw_interfaces[index].vars) {
					Raw.appendChild(raw_interfaces[index].vars[variable]);
				}
				Raw_Items.appendChild(Raw);
				Raw_Interface.appendChild(Raw_Items);
				newRaw_Interfaces.appendChild(Raw_Interface);
			}
		}
		return newRaw_Interfaces;
	}
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, "Raw Interfaces");
		newNode.object = this;
		_global.workflow.addNode("Raw_interfaces", newNode);
		return newNode;
	}
	public function getName():String {
		return "Custom Outputs";
	}
	public function getData():Object {
		return {raw_interfaces:raw_interfaces, cataloguesNode:catalogues.toXML()};
	}
	public function setData(newData:Object) {
		raw_interfaces = newData.raw_interfaces;
	}
	public function setXML(newData:XMLNode):Void {
		raw_interfaces = new Array();
		container = newData.nodeName;
		for (var child in newData.childNodes) {
			var newRaw_interface = new Object();
			newRaw_interface.display_name = "";
			newRaw_interface.name = "";
			if (newData.childNodes[child].attributes.DISPLAY_NAME != undefined) {
				newRaw_interface.display_name = newData.childNodes[child].attributes.DISPLAY_NAME;
			}
			if (newData.childNodes[child].attributes.NAME != undefined) {
				newRaw_interface.name = newData.childNodes[child].attributes.NAME;
			}
			var raw_items = newData.childNodes[child].childNodes;
			for (var raw_item in raw_items) {
				newRaw_interface.catalogue = "";
				if (raw_items[raw_item].attributes.CATALOGUE != undefined) {
					newRaw_interface.catalogue = raw_items[raw_item].attributes.CATALOGUE;
				}
				var raws = raw_items[raw_item].childNodes;
				for (var raw in raws) {
					newRaw_interface.code = new Object();
					newRaw_interface.command = "";
					newRaw_interface.extra = "";
					newRaw_interface.extra2 = "";
					newRaw_interface.extra3 = "";
					newRaw_interface.extra4 = "";
					newRaw_interface.extra5 = "";
					if (raws[raw].attributes.CODE != undefined) {
						newRaw_interface.code.label = raws[raw].attributes.CODE;
					}
					if (raws[raw].attributes.COMMAND != undefined) {
						newRaw_interface.command = raws[raw].attributes.COMMAND;
					}
					if (raws[raw].attributes.EXTRA != undefined) {
						newRaw_interface.extra = raws[raw].attributes.EXTRA;
					}
					if (raws[raw].attributes.EXTRA2 != undefined) {
						newRaw_interface.extra2 = raws[raw].attributes.EXTRA2;
					}
					if (raws[raw].attributes.EXTRA3 != undefined) {
						newRaw_interface.extra3 = raws[raw].attributes.EXTRA3;
					}
					if (raws[raw].attributes.EXTRA4 != undefined) {
						newRaw_interface.extra4 = raws[raw].attributes.EXTRA4;
					}
					if (raws[raw].attributes.EXTRA5 != undefined) {
						newRaw_interface.extra5 = raws[raw].attributes.EXTRA5;
					}
					if (raws[raw].hasChildNodes()) {
						newRaw_interface.vars = new Array();
						for (var variable in raws[raw].childNodes) {
							newRaw_interface.vars.push(raws[raw].childNodes[variable]);
						}
					}
					var actualInterface = new Object();
					for (var attribute in newRaw_interface) {
						actualInterface[attribute] = newRaw_interface[attribute];
					}
					actualInterface.vars = new Array();
					for (var variable in newRaw_interface.vars) {
						actualInterface.vars.push(newRaw_interface.vars[variable]);
					}
					raw_interfaces.addItem(actualInterface);
				}
			}
		}
	}
}
