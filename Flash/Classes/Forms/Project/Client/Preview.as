class Forms.Project.Client.Preview extends Forms.BaseForm {
	private var controls:XMLNode;
	private var previewXML:XMLNode;
	private var preview_mc:MovieClip;
	private var dataObject:Object;
	function Preview() {
	}
	public function onLoad():Void {
		//trace(previewXML);
		switch (previewXML.nodeName) {
		case "control" :
			var sampleWindow:XML = new XML('<window><tab name="'+previewXML.attributes.type+'" ><control name="Preview" key="PREVIEW" type="'+previewXML.attributes.type+'"  /></tab></window>');
			var newControlTypes = new XMLNode(1, "controlTypes");
			newControlTypes.appendChild(previewXML);
			attachMovie("window-preview", "preview_mc", 100, {width:735, height:525, controlTypeData:new XML(newControlTypes.toString()), windowData:sampleWindow, iconPath:"lib/icons/"});
			break;
		case "window" :
			attachMovie("window-preview", "preview_mc", 100, {width:735, height:525, controlTypeData:new XML(controls.toString()), windowData:new XML(previewXML.toString()), iconPath:"lib/icons/"});
			break;
		case "tab" :
			var newXML = new XMLNode(1,"window");
			newXML.appendChild(previewXML);
			attachMovie("window-preview", "preview_mc", 100, {width:735, height:525, controlTypeData:new XML(controls.toString()), windowData:new XML(newXML.toString()), iconPath:"lib/icons/"});		
			break;
		case "panel" :
			var newWindow = new XMLNode(1,"window");
			var newTab = new XMLNode(1,"tab");
			newTab.attributes.name = previewXML.attributes.name;
			for(var child in previewXML.childNodes){
				newTab.appendChild(previewXML.childNodes[child]);
			}
			newWindow.appendChild(newTab);
			attachMovie("window-preview", "preview_mc", 100, {width:735, height:525, controlTypeData:new XML(controls.toString()), windowData:new XML(newWindow.toString()), iconPath:"lib/icons/"});		
			break;
		}
	}
}
