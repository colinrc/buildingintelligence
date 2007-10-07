package Objects.Client {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.core.Application;
	import mx.utils.ObjectProxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	
	[Bindable("Window")]
	[RemoteClass(alias="elifeAdmin.objects.client.window")]
	public class Window extends BaseElement {
		private var tabs:Array;
		private var attributes:Array;
		private var attributeGroups:Array = ["window", "tabs"];
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeObject(tabs);
			output.writeObject(attributes);
			output.writeObject(attributeGroups);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			tabs = input.readObject()as Array;
			attributes = input.readObject()as Array;
			attributeGroups = input.readObject()as Array;
		}
		
		public override function isValid():String {
			var flag:String = "ok";
			clearValidationMsg();
			if (tabs.length == 0) {
				flag = "empty";
				appendValidationMsg("No Tabs are defined");
			}
			/*for (var tab in tabs) {
				if (tabs[tab].isValid()!="ok") {
					flag = "warning";
					appendValidationMsg(tabs[tab].attributes["name"] + " is invalid");
				}
			}*/
			return flag;
		}
		public function deleteSelf():void{
			treeNode.removeNode();
		}
		public override function getForm():String {
			return "forms.project.client.window";
		}
		public override function toXML():XML {
			var newNode:XML = new XML("<window />");
			for (var attribute in attributes) {
				newNode.@[attributes[attribute].name] = attributes[attribute].value;
			}
			for (var tab:int = 0; tab < tabs.length; tab++) {			
				newNode.appendChild(tabs[tab].toXML());
			}
			return newNode;
		}
		public override function toTree():MyTreeNode {
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			for (var tab = 0; tab < tabs.length; tab++) {			
				newNode.appendChild(tabs[tab].toTree());
			}
			
			treeNode = newNode;
			return newNode;
		}
		public function getKey():String {
			return "ClientWindow";
		}
		public override function getName():String {
			return "Room Control Panel";
		}
		public  function get Data():ObjectProxy {
			return {tabs:tabs, dataObject:this};
		}
		public function getAttributes():Array {
			return attributes;
		}
		public function setAttributes(newAttributes:Array) {
			attributes = newAttributes;
		}
		public override function setXML(newData:XML):void {
			attributes = new Array();
			if (newData.name() == "window") {
				for (var child:int = 0; child < newData.attributes().length(); child++) {
					attributes.push({name:newData.attributes()[child].name(), value:newData.attributes()[chlid]});
				}
				tabs = new Array();
				for (var child:int =0; child< newData.children().length(); child++) {		
					var newTab:Tab = new Tab();
					newTab.setXML(newData.children()[child]);
					newTab.id = Application.application.formDepth++;
					tabs.push(newTab);
				}
			} else {
				trace("Error, found " + newData.name() + ", was expecting window");
			}
		}
		[Bindable]
		public  function set Data(newData:ObjectProxy):void {
			//_global.left_tree.setIsOpen(treeNode, false);
			//process new tabs
			var newTabs = new Array();
			for (var index in newData.tabs) {
				if (newData.tabs[index].id == undefined) {
					newData.tabs[index].id = _global.formDepth++;
					newTabs.push({name:newData.tabs[index].name, id:newData.tabs[index].id});
				}
			}
			for (var tab in tabs) {
				var found = false;
				for (var index in newData.tabs) {
					if (tabs[tab].id == newData.tabs[index].id) {
						tabs[tab].name = newData.tabs[index].name;
						found = true;
						break;
					}
				}
				if (found == false) {
					tabs[tab].deleteSelf();
					tabs.splice(parseInt(tab), 1);
				}
			}
			for (var newTab in newTabs) {
				var newNode = new XMLNode(1, "tab");
				newNode.attributes["name"] = newTabs[newTab].name;
				var Tab = new Objects.Client.Tab();
				Tab.setXML(newNode);
				Tab.id = newTabs[newTab].id;
				tabs.push(Tab);
			}
			//sort according to desired order
			newTabs = new Array();
			for (var newTab = 0; newTab < newData.tabs.length; newTab++) {			
				for (var tab = 0; tab < tabs.length; tab++) {			
					if (newData.tabs[newTab].id == tabs[tab].id) {
						newTabs.push(tabs[tab]);
						break;
					}
				}
			}
			tabs = newTabs;
			var treeLength = treeNode.childNodes.length;
			for(var child = treeLength-1; child > -1;child--){
				treeNode.childNodes[child].removeNode();
			}
			for(var tab = 0; tab<tabs.length;tab++){
				treeNode.appendChild(tabs[tab].toTree());
			}		
			_global.left_tree.setIsOpen(treeNode, true);
		}
		public override function getUsedKeys():Array{
			usedKeys = new Array();
			for (var tab in tabs) {
				usedKeys=usedKeys.concat(tabs[tab].getUsedKeys());
			}
			return usedKeys;
		}
		public function getIcons():Array{
			usedIcons = new Array();
			for (var tab in tabs) {
				usedIcons = usedIcons.concat(tabs[tab].getIcons());
			}
			return usedIcons;
		}
	}
}