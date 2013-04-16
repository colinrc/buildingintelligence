﻿package Objects.Client {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.core.Application;
	import mx.utils.ObjectProxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	import mx.collections.ArrayCollection;
	import Forms.Client.Control_Types_frm;
	
	[Bindable("Control_Types")]
	[RemoteClass(alias="elifeAdmin.objects.client.control_Types")]
	public class Control_Types extends BaseElement {
		[Bindable]
		public var controls:ArrayCollection;
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeObject(controls);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			controls = input.readObject()as ArrayCollection;
		}
		
		public override function isValid():String {
			var flag = "ok";
			clearValidationMsg();
			if (controls.length == 0) {
				flag = "empty";
				appendValidationMsg("No Controls are defined");
			}
			return flag;
		}
		public override function getForm():String {
			return "forms.project.client.controltypes";
		}
		public function getClassForm():Class {
			var className:Class = Forms.Client.Control_Types_frm;
			return className;		
		}
		public override function toXML():XML {
			var newNode = new XML("<controlTypes />");
			for (var control in controls) {
				newNode.appendChild(controls[control].toXML());
			}
			return newNode;
		}
		
		public override function toTree():MyTreeNode {
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			
			for (var control in controls) {
				newNode.appendChild(controls[control].toTree());
			}
			treeNode = newNode;				
			return newNode;
		}
		public function getKey():String{
			return "ClientControl_Types";
		}	
		public override function getName():String {
			return "Control Types";
		}
		public  function get Data():ObjectProxy {
			var ob:ObjectProxy = new ObjectProxy({controls:controls, dataObject:this});
			return ob;
		}
		public override function setXML(newData:XML):void {
			controls = new ArrayCollection();
			if (newData.name() == "controlTypes") {
				for (var child:int =0; child<newData.children().length(); child++) {
					var newControl:Control = new Control();
					newControl.setXML(newData.control[child]);
					newControl.id = mx.core.Application.application.formDepth++;
					newControl.myType = newData.control[child].@type;
					controls.addItem(newControl);
				}
			} else {
				trace("Error, found "+newData.name()+", was expecting controlTypes");
			}
		}
		[Bindable]
		public  function set Data(newData:ObjectProxy):void {
			//_global.left_tree.setIsOpen(treeNode, false);
			//Process control changes....
			var newControls = new Array();
			for (var index in newData.controls) {
				if (newData.controls[index].id == undefined) {
					newControls.push({type:newData.controls[index].type});
				}
			}
			for (var control in controls) {
				var found = false;
				for (var index in newData.controls) {
					if (controls[control].id == newData.controls[index].id) {
						controls[control].type = newData.controls[index].type;
						found = true;
					}
				}
				if (found == false) {
					controls[control].deleteSelf();
					controls.splice(parseInt(control), 1);
				}
			}
			for (var newControl in newControls) {
				var newNode:XML = new XML("<control />");
				newNode.@type = newControls[newControl].type;
				var newControl = new Objects.Client.Control();
				newControl.setXML(newNode);
				newControl.id = Application.application.formDepth++;			
				treeNode.appendChild(newControl.toTree());	
				controls.addItem(newControl);
			}
			//_global.left_tree.setIsOpen(treeNode, true);
		}
		public override function getUsedKeys():Array{
			usedKeys = new Array();
			for (var control in controls) {
				usedKeys=usedKeys.concat(controls[control].getUsedKeys());
			}
			return usedKeys;
		}
		public function getIcons():Array{
			usedIcons = new Array();
			for (var control in controls) {
				usedIcons=usedIcons.concat(controls[control].getIcons());
			}
			return usedIcons;
		}
	}
}
