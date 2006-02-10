class Forms.Project.Client.Preview extends Forms.BaseForm {
	private var controls:XMLNode;
	private var windowXML:XMLNode;
	private var preview_mc:MovieClip;
	function Preview() {
	}
	public function init():Void {
		if (windowXML.nodeName == "control") {
			var sampleWindow:XML = new XML('<window><tab name="'+windowXML.attributes.type+'" ><control name="Main Light" key="ENSUITE_LIGHT" type="'+windowXML.attributes.type+'" icons="light-bulb-off,light-bulb" /></tab></window>');
			var newControlTypes = new XMLNode(1,"controlTypes");
			newControlTypes.appendChild(windowXML);
			attachMovie("window-preview", "preview_mc", 100, {width:525, height:525, controlTypeData:new XML(newControlTypes.toString()), windowData:sampleWindow, iconPath:"lib/icons/"});
		} else {
			attachMovie("window-preview", "preview_mc", 100, {width:525, height:525, controlTypeData:new XML(controls.toString()), windowData:new XML(windowXML.toString()), iconPath:"lib/icons/"});
		}
	}
}
