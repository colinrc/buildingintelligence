package Objects.Server {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.core.Application;
	import mx.utils.ObjectProxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	
	[Bindable("catalogues")]
	[RemoteClass(alias="elifeAdmin.objects.server.catalogues")]
	public class Catalogues extends BaseElement{
		var catalogues:Array;
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeObject(catalogues);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			catalogues = input.readObject()as Array;
		}
		
		public override function isValid():String {
			var flag = "ok";
			clearValidationMsg();
			for (var catalogue in catalogues) {
				if (catalogues[catalogue].isValid()!="ok") {
					flag = "error";
					appendValidationMsg("Catalogue's are in error");
				}
			}
			return flag;
		}
		
	/*	public function clone():Object {
			var newCat:Catalogues = new Catalogues();
			for each (var val:Catalogue in catalogues) {
				newCat.catalogues.push(val);
			}
			newCat.id = catalogues.id;
			newCat.treeNode = catalogues.id;
			newCat.usedIcons = catalogues.usedIcons;
		}
		*/
		
		public override function getForm():String {
			return "forms.project.device.catalogues";
		}
		public override function toXML():XML {
			var newCatalogues = new XML("<Catalogues />");
			for (var catalogue in catalogues) {
				newCatalogues.appendChild(catalogues[catalogue].toXML());
			}
			return newCatalogues;
		}
		public override function toTree():MyTreeNode {
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			for (var catalogue in catalogues) {
				newNode.appendChild(catalogues[catalogue].toTree());
			}
			
			treeNode = newNode;		
			return newNode;
		}
		public function getKey():String {
			return "Catalogues";
		}
		public override function getName():String {
			return "Catalogs";
		}
		public override function getData():ObjectProxy {
			return {catalogues:catalogues, dataObject:this};
		}
		public override function setData(newData:Object):void {
			//_global.left_tree.setIsOpen(treeNode, false);		
			//Process catalogue changes....
			var newCatalogues = new Array();
			for (var index in newData.catalogues) {
				if (newData.catalogues[index].id == undefined) {
					newCatalogues.push({name:newData.catalogues[index].name});
				}
			}
			for (var catalogue in catalogues) {
				var found = false;
				for (var index in newData.catalogues) {
					if (catalogues[catalogue].id == newData.catalogues[index].id) {
						catalogues[catalogue].name = newData.catalogues[index].name;
						found = true;
					}
				}
				if (found == false) {
					catalogues[catalogue].deleteSelf();
					catalogues.splice(parseInt(catalogue), 1);
				}
			}
			for (var newCatalogue in newCatalogues) {
				var newNode = new XML("<CATALOGUE />");
				newNode.@NAME = newCatalogues[newCatalogue].name;
				var newCatalogue = new Objects.Server.Catalogue();
				newCatalogue.setXML(newNode);
				newCatalogue.id = Application.application.formDepth++;
				treeNode.appendChild(newCatalogue.toTree());			
				catalogues.push(newCatalogue);
			}
			//_global.left_tree.setIsOpen(treeNode, true);		
		}
		public override function setXML(newData:XML):void {
			catalogues = new Array();
			for (var child in newData.childNodes) {
				var newCatalogue:Catalogue = new Objects.Server.Catalogue();
				newCatalogue.setXML(newData.childNodes[child]);
				newCatalogue.id = _global.formDepth++;			
				catalogues.push(newCatalogue);
			}
		}
	}
}