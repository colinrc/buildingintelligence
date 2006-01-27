class Forms.Project.Client.Preview extends Forms.BaseForm {
	private var controls:XMLNode;
	private var windowXML:XMLNode;
	function Preview() {
	}
	public function init():Void {
		var sampleWindow:XML = new XML('<window><tab name="Lights &amp; Fan" icon="light-bulb"><control name="Main Light" key="ENSUITE_LIGHT" type="onOff" icons="light-bulb-off,light-bulb" /></tab></window>');
		var preview_mc:MovieClip = this.createEmptyMovieClip("preview_mc", 100);
		//var preview_mc:MovieClip = this.attachMovie("window-preview.swf","preview_mc", 100);
		preview_mc.loadMovie("window-preview.swf");
		this.onEnterFrame = function() {
			if (this.preview_mc.sampleControlTypes) {
				this.preview_mc.setWindowData(525, 525, new XML(windowXML.toString()));
				this.preview_mc.setControlTypeData(new XML(controls.toString()));
				this.preview_mc.setIconPath("D:/BI/eLife Client/Build/standalone/lib/icons/");
				delete this.onEnterFrame;
			}
		};
	}
}
