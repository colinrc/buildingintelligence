class Forms.Project.Client.Preview extends Forms.BaseForm {
	private var controls:XMLNode;
	private var windowXML:XMLNode;
	private var preview_mc:MovieClip;

	function Preview() {
	}

	public function init():Void {
		attachMovie("window-preview", "preview_mc", 100, {width:525, height:525, controlTypeData:new XML(controls.toString()), windowData:new XML(windowXML.toString()), iconPath:"../../eLife Client/Build/standalone/lib/icons/"});
	}
}
