class Forms.Project.Room.Tab.Preview extends Forms.BaseForm {
	
	private var controls:String;
	
	function Preview() {
	}
	
	public function init():Void {
		var sampleWindow:XML = new XML('<window><tab name="Lights &amp; Fan" icon="light-bulb"><control name="Main Light" key="ENSUITE_LIGHT" type="onOff" icons="light-bulb-off,light-bulb" /></tab></window>');
		
		var preview_mc:MovieClip = this.createEmptyMovieClip("preview_mc", 10);
		preview_mc.loadMovie("window-preview.swf");
		
		this.onEnterFrame = function () {
			if (this.preview_mc.sampleControlTypes) {
				this.preview_mc.setWindowData(525, 525, new XML("<window>" + controls.toString() + "</window>"));
				delete this.onEnterFrame;
			}
		}
	}
}