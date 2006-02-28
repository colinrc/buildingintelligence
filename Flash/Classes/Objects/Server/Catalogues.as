class Objects.Server.Catalogues extends Objects.BaseElement {
	var catalogues:Array;
	public function isValid():Boolean {
		var flag = true;
		for (var catalogue in catalogues) {
			if (!catalogues[catalogue].isValid()) {
				flag = false;
			}
		}
		return flag;
	}
	public function getForm():String {
		return "forms.project.device.catalogues";
	}
	public function toXML():XMLNode {
		var newCatalogues = new XMLNode(1, "Catalogues");
		for (var catalogue in catalogues) {
			newCatalogues.appendChild(catalogues[catalogue].toXML());
		}
		return newCatalogues;
	}
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, "Catalogues");
		for (var catalogue in catalogues) {
			newNode.appendChild(catalogues[catalogue].toTree());
		}
		newNode.object = this;
		_global.workflow.addNode("Catalogues",newNode);
		return newNode;
	}
	public function getName():String {
		return "Catalogs";
	}
	public function getData():Object {
		return {catalogues:catalogues};
	}
	public function setData(newData:Object) {
		//Process catalogue changes....
		var newCatalogues = new Array();
		for (var index in newData.catalogues) {
			var found = false;
			for (var catalogue in catalogues) {
				if (catalogues[catalogue].name == newData.catalogues[index].name) {
					found = true;
				}
			}
			if (found == false) {
				newCatalogues.push({name:newData.catalogues[index].name});
			}
		}
		var deletedCatalogues = new Array();
		for (var catalogue in catalogues) {
			var found = false;
			for (var index in newData.catalogues) {
				if (catalogues[catalogue].name == newData.catalogues[index].name) {
					found = true;
				}
			}
			if (found == false) {
				catalogues.splice(parseInt(catalogue), 1);
			}
		}
		for (var newCatalogue in newCatalogues) {
			var newNode = new XMLNode(1, "CATALOGUE");
			newNode.attributes["NAME"] = newCatalogues[newCatalogue].name;
			var newCatalogue = new Objects.Server.Catalogue();
			newCatalogue.setXML(newNode);
			catalogues.push(newCatalogue);
		}
	}
	public function setXML(newData:XMLNode):Void {
		catalogues = new Array();
		for (var child in newData.childNodes) {
			var newCatalogue = new Objects.Server.Catalogue();
			newCatalogue.setXML(newData.childNodes[child]);
			catalogues.push(newCatalogue);
		}
	}
}
