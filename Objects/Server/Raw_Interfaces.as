package Objects.Server {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.core.Application;
	import mx.utils.ObjectProxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	
	[Bindable("Raw_Interfaces")]
	[RemoteClass(alias="elifeAdmin.objects.server.raw_Interfaces")]
	public class Raw_Interfaces extends BaseElement {
		public var raw_interfaces:Array = new Array();
		public var container:String = new String();
		public var catalogues:Catalogues = new Catalogues();
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeObject(raw_interfaces);
			output.writeUTF(container);
			output.writeObject(catalogues);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			raw_interfaces = input.readObject() as Array;
			container = input.readUTF() as String;
			catalogues = input.readObject() as Catalogues;
		}
		
		public function getKeys():Array {
			var tempKeys = new Array();
			for (var raw_interface in raw_interfaces) {
				tempKeys.push(raw_interfaces[raw_interface].display_name);
			}
			return tempKeys;
		}
		public override function isValid():String {
			var flag = "ok";
			clearValidationMsg();
			for (var raw_interface in raw_interfaces) {
				if (Application.application.advanced == true) {
					if ((raw_interfaces[raw_interface].extra2 == undefined) || (raw_interfaces[raw_interface].extra2 == "")) {
						flag = "empty";
						appendValidationMsg("Extra2 is invalid");
					}
					if ((raw_interfaces[raw_interface].extra3 == undefined) || (raw_interfaces[raw_interface].extra3 == "")) {
						flag = "empty";
						appendValidationMsg("Extra3 is invalid");
					}
					if ((raw_interfaces[raw_interface].extra4 == undefined) || (raw_interfaces[raw_interface].extra4 == "")) {
						flag = "empty";
						appendValidationMsg("Extra4 is invalid");
					}
					if ((raw_interfaces[raw_interface].extra5 == undefined) || (raw_interfaces[raw_interface].extra5 == "")) {
						flag = "empty";
						appendValidationMsg("Extra5 is invalid");
					}
				}
				if ((raw_interfaces[raw_interface].extra == undefined) || (raw_interfaces[raw_interface].extra == "")) {
					flag = "empty";
					appendValidationMsg("Extra is empty");
				}
				if ((raw_interfaces[raw_interface].name == undefined) || (raw_interfaces[raw_interface].name == "")) {
					flag = "empty";
					appendValidationMsg("Description is empty");
				}
				if ((raw_interfaces[raw_interface].display_name == undefined) || (raw_interfaces[raw_interface].display_name == "")) {
					flag = "error";
					appendValidationMsg("Key is invalid");
				}else {
					if (Application.application.isKeyUsed(raw_interfaces[raw_interface].display_name) == false) {
						flag = "error";
						appendValidationMsg(raw_interfaces[raw_interface].display_name+" key is not being used");
					}
				}
				
				if ((raw_interfaces[raw_interface].code == undefined) || (raw_interfaces[raw_interface].code == "")) {
					flag = "error";
					appendValidationMsg("Code is empty");
				}
				if ((raw_interfaces[raw_interface].catalog == undefined) || (raw_interfaces[raw_interface].catalog == "")) {
					flag = "error";
					appendValidationMsg("Catalog has not been created");
				}
				if ((raw_interfaces[raw_interface].command == undefined) || (raw_interfaces[raw_interface].command == "")) {
					flag = "error";
					appendValidationMsg("Command is empty");
				}
				
				
			}
			return flag;
		}
		public override function getForm():String {
			return "forms.project.device.raw_interfaces";
		}
		public override function toXML():XML {
			var newRaw_Interfaces:XML = new XML(container);
			//raw_interfaces.sortOn(["display_name", "name", "catalogue", "code", "command"]);
			for (var index:int = 0; index < raw_interfaces.length; index++) {
				var foundInterface:Boolean = false;
				for (var rawInterface in newRaw_Interfaces) {
					if ((newRaw_Interfaces[rawInterface].@NAME == raw_interfaces[index].name) && (newRaw_Interfaces[rawInterface].@DISPLAY_NAME == raw_interfaces[index].display_name)) {
						foundInterface = true;
						var foundItems:Boolean = false;
						for (var rawItem:int = 0; rawItem<newRaw_Interfaces[rawInterface].children().length;rawItem++){
							if (newRaw_Interfaces[rawInterface].children()[rawItem].@CATALOGUE == raw_interfaces[index].catalogue) {
								foundItems = true;
								var Raw:XML = new XML("<RAW />");
								if (raw_interfaces[index].code.label.length) {
									Raw.@CODE = raw_interfaces[index].code.label;
								}
								if (raw_interfaces[index].command.length) {
									Raw.@COMMAND = raw_interfaces[index].command;
								}
								if (raw_interfaces[index].extra.length) {
									Raw.@EXTRA = raw_interfaces[index].extra;
								}
								if (raw_interfaces[index].extra2.length) {
									Raw.@EXTRA2 = raw_interfaces[index].extra2;
								}
								if (raw_interfaces[index].extra3.length) {
									Raw.@EXTRA3 = raw_interfaces[index].extra3;
								}
								if (raw_interfaces[index].extra4.length) {
									Raw.@EXTRA4 = raw_interfaces[index].extra4;
								}
								if (raw_interfaces[index].extra5.length) {
									Raw.@EXTRA5 = raw_interfaces[index].extra5;
								}
								for (var variable in raw_interfaces[index].vars) {
									Raw.appendChild(raw_interfaces[index].vars[variable]);
								}
								newRaw_Interfaces[rawInterface].children()[rawItem].appendChild(Raw);
							}
						}
						if (!foundItems) {
							var Raw_Items:XML = new XML("<RAW_ITEMS />");
							if (raw_interfaces[index].catalogue.length) {
								Raw_Items.@CATALOGUE = raw_interfaces[index].catalogue;
							}
							var Raw:XML = new XML("<RAW />");
							if (raw_interfaces[index].code.label.length) {
								Raw.@CODE = raw_interfaces[index].code.label;
							}
							if (raw_interfaces[index].command.length) {
								Raw.@COMMAND = raw_interfaces[index].command;
							}
							if (raw_interfaces[index].extra.length) {
								Raw.@EXTRA = raw_interfaces[index].extra;
							}
							if (raw_interfaces[index].extra2.length) {
								Raw.@EXTRA2 = raw_interfaces[index].extra2;
							}
							if (raw_interfaces[index].extra3.length) {
								Raw.@EXTRA3 = raw_interfaces[index].extra3;
							}
							if (raw_interfaces[index].extra4.length) {
								Raw.@EXTRA4 = raw_interfaces[index].extra4;
							}
							if (raw_interfaces[index].extra5.length) {
								Raw.@EXTRA5 = raw_interfaces[index].extra5;
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
					var Raw_Interface:XML = new XML("<RAW_INTERFACE />");
					if (raw_interfaces[index].name.length) {
						Raw_Interface.@NAME = raw_interfaces[index].name;
					}
					if (raw_interfaces[index].display_name.length) {
						Raw_Interface.@DISPLAY_NAME = raw_interfaces[index].display_name;
					}
					var Raw_Items:XML = new XML("<RAW_ITEMS />");
					if (raw_interfaces[index].catalogue.length) {
						Raw_Items.@CATALOGUE = raw_interfaces[index].catalogue;
					}
					var Raw:XML = new XML("<RAW />");
					if (raw_interfaces[index].code.label.length) {
						Raw.@CODE = raw_interfaces[index].code.label;
					}
					if (raw_interfaces[index].command.length) {
						Raw.@COMMAND = raw_interfaces[index].command;
					}
					if (raw_interfaces[index].extra.length) {
						Raw.@EXTRA = raw_interfaces[index].extra;
					}
					if (raw_interfaces[index].extra2.length) {
						Raw.@EXTRA2 = raw_interfaces[index].extra2;
					}
					if (raw_interfaces[index].extra3.length) {
						Raw.@EXTRA3 = raw_interfaces[index].extra3;
					}
					if (raw_interfaces[index].extra4.length) {
						Raw.@EXTRA4 = raw_interfaces[index].extra4;
					}
					if (raw_interfaces[index].extra5.length) {
						Raw.@EXTRA5 = raw_interfaces[index].extra5;
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
		public override function toTree():MyTreeNode {
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			
			treeNode = newNode;				
			return newNode;
		}
		public function getKey():String {
			return "Raw_interfaces";
		}
		public override function getName():String {
			return "Custom Outputs";
		}
		public override function getData():ObjectProxy {
			return {raw_interfaces:raw_interfaces, cataloguesNode:catalogues.toXML(), dataObject:this};
		}
		public override function setData(newData:Object):void {
			raw_interfaces = newData.raw_interfaces;
		}
		public override function setXML(newData:XML):void {
			raw_interfaces = new Array();
			container = newData.name();
			for (var child:int = 0; child<newData.children().length;child++){	
				var newRaw_interface:Object = new Object();
				newRaw_interface.display_name = "";
				newRaw_interface.name = "";
				if (newData.children()[child].@DISPLAY_NAME != undefined) {
					newRaw_interface.display_name = newData.children()[child].@DISPLAY_NAME;
				}
				if (newData.children()[child].@NAME != undefined) {
					newRaw_interface.name = newData.children()[child].@NAME;
				}
				var raw_items:XML = newData.children()[child].children();
				for (var raw_item:int = 0; raw_item<raw_items.children().length;raw_item++){
					newRaw_interface.catalogue = "";
					if (raw_items[raw_item].@CATALOGUE != undefined) {
						newRaw_interface.catalogue = raw_items[raw_item].@CATALOGUE;
					}
					var raws:XML = raw_items[raw_item].children();
					for (var raw:int = 0; raw<raws.children().length;raw++){
						newRaw_interface.code = new Object();
						newRaw_interface.command = "";
						newRaw_interface.extra = "";
						newRaw_interface.extra2 = "";
						newRaw_interface.extra3 = "";
						newRaw_interface.extra4 = "";
						newRaw_interface.extra5 = "";
						if (raws[raw].@CODE != undefined) {
							newRaw_interface.code.label = raws[raw].@CODE;
						}
						if (raws[raw].@COMMAND != undefined) {
							newRaw_interface.command = raws[raw].@COMMAND;
						}
						if (raws[raw].@EXTRA != undefined) {
							newRaw_interface.extra = raws[raw].@EXTRA;
						}
						if (raws[raw].@EXTRA2 != undefined) {
							newRaw_interface.extra2 = raws[raw].@EXTRA2;
						}
						if (raws[raw].@EXTRA3 != undefined) {
							newRaw_interface.extra3 = raws[raw].@EXTRA3;
						}
						if (raws[raw].@EXTRA4 != undefined) {
							newRaw_interface.extra4 = raws[raw].@EXTRA4;
						}
						if (raws[raw].@EXTRA5 != undefined) {
							newRaw_interface.extra5 = raws[raw].@EXTRA5;
						}
						
						if (raws[raw].children().length() > 0) {
							newRaw_interface.vars = new Array();
							
							for (var variable:int=0 ; variable<raws[raw].children().length();variable++) {
								newRaw_interface.vars.push(raws[raw].children()[variable]);
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
}