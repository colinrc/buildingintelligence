package Objects.Client {
	import Objects.BaseElement;
	import flash.xml.XMLNode;
	import Objects.MyTreeNode;
	import mx.core.Application;
	import mx.utils.ObjectProxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	
	[Bindable("Calendar")]
	[RemoteClass(alias="elifeAdmin.objects.client.calendar")]
	public class Calendar extends BaseElement {
		private var attributes:Array;
		private var tabs:Array;
		private var attributeGroups:Array = ["tabs"];
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeObject(attributes);
			output.writeObject(tabs);
			output.writeObject(attributeGroups);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			attributes = input.readObject() as Array;
			tabs = input.readObject() as Array;
			attributeGroups = input.readObject()as Array;
		}
				
		public function deleteSelf() {
			treeNode.removeNode();
		}
		public override function isValid():String {
			var flag = "ok";
			clearValidationMsg();
			if (tabs.length == 0) {
				flag = "empty";
				appendValidationMsg("No Calendar Tabs are defined");
			}
			return flag;
		}
		public override function getForm():String {
			return "forms.project.client.calendar";
		}
		public override function toXML():XML {
			var newNode:XML = new XML("<calendar />");
			for (var attrib:int=0 ; attrib < attributes.length ; attrib++) {
				newNode.@[attributes[attrib].name] = attributes[attrib].value;
			}
			/*Categories are hard coded for time being*/
			var newCategories = new XML("<categories />");
			var newCategory = new XML("<category />");
			newCategory.@name = "Birthday";
			newCategory.@icon = "light-bulb";
			newCategories.appendChild(newCategory);
			newCategory = new XML("<category />");
			newCategory.@name = "Appointment";
			newCategory.@icon = "videocamera";
			newCategories.appendChild(newCategory);
			newCategory = new XML("<category />");
			newCategory.@name = "Reminder";
			newCategory.@icon = "fireplace";
			newCategories.appendChild(newCategory);
			newNode.appendChild(newCategories);
			var newWindowNode = new XML("<window />");
			for (var tab = 0; tab < tabs.length; tab++) {
				newWindowNode.appendChild(tabs[tab].toXML());
			}
			newNode.appendChild(newWindowNode);
			return newNode;
		}
		public override function toTree():MyTreeNode {
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			
			for (var tab:int = 0; tab < tabs.length; tab++) {
				newNode.appendChild(tabs[tab].toTree());
			}
			treeNode = newNode;
			return newNode;
		}
		public function getKey():String {
			return "Calendar";
		}
		public override function getName():String {
			return "Calendar";
		}
		public override function getData():ObjectProxy {
			return {tabs:tabs, dataObject:this};
		}
		public override function setData(newData:Object):void {
			_global.left_tree.setIsOpen(treeNode, false);
			//process new tabs
			var newTabs = new Array();
			for (var index in newData.tabs) {
				if (newData.tabs[index].id == undefined) {
					newData.tabs[index].id = _global.formDepth++;
					newTabs.push({label:newData.tabs[index].label, id:newData.tabs[index].id});
				}
			}
			for (var tab in tabs) {
				var found = false;
				for (var index in newData.tabs) {
					if (tabs[tab].id == newData.tabs[index].id) {
						tabs[tab].label = newData.tabs[index].label;
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
				newNode.attributes["label"] = newTabs[newTab].label;
				var Tab = new Objects.Client.CalendarTab();
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
		public function getAttributes():Array {
			return attributes;
		}
		public function setAttributes(newAttributes:Array) {
			attributes = newAttributes;
		}
		public override function setXML(newData:XML):void {
			tabs = new Array();
			attributes = new Array();
			if (newData.name() == "calendar") {
				for (var child:int=0; child< newData.attributes().length();child++) {
					
					attributes.push({name:newData.attributes()[child].name(), value:newData.attributes()[child]});
				}
				for (var child:int = 0; child < newData.childNodes.length(); child++) {
					if(newData.children()[child].name() == "window"){
						for(var child2:int = 0; child2<newData.children()[child].length();child2++){
							var newTab:CalendarTab = new CalendarTab();
							newTab.setXML(newData.children()[child].children()[child2]);
							newTab.id = Application.application.formDepth++;
							tabs.push(newTab);
						}
					}
				}
			} else {
				trace("Error, received " + newData.name() + ", was expecting calendar");
			}
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
				usedIcons=usedIcons.concat(tabs[tab].getIcons());
			}
			return usedIcons;
		}
	}
}