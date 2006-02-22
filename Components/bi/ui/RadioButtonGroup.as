class bi.ui.RadioButtonGroup extends Object {

	private var _clips:Array;
	private var _selectedClip:MovieClip;
	private var dispatchEvent:Function;
	
	/* Getters and Setters */
		
	public function get data() {
		for (var i=0; i<_clips.length; i++) {
			if (_clips[i].selected) {
				return _clips[i].data;
			}
		}
		return null;
	}
	
	public function set data(val):Void {
		for (var i=0; i<_clips.length; i++) {
			if (_clips[i].data == val) {
				_clips[i].selected = true;
				break;
			}
		}
	}
	
	public function set selectedClip(instance:MovieClip):Void {
		_selectedClip.selected = false;
		_selectedClip = instance;
	}
	
	public function get selection():MovieClip {
		return _selectedClip;
	}
	
	/* Constructor */
	
	function RadioButtonGroup() {
		_clips = new Array();
		
		mx.events.EventDispatcher.initialize(this);
	}

	private function init():Void {

	}
	
	public function click(instance:MovieClip):Void {
		dispatchEvent({type:"click", target:this});
	}
	
	public function addClip(instance:MovieClip):Void {
		var found = false;
		for (var i=0; i<_clips.length; i++) {
			if (_clips[i] == instance) found = true;
		}
		if (!found) {
			_clips.push(instance);
		}
	}
}