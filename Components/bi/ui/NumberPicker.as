class bi.ui.NumberPicker extends bi.ui.ItemPicker {

	private var _minValue:Number;
	private var _maxValue:Number;
	private var _step:Number;

	/* Getters and Setters */

	public function set minValue(min:Number):Void {
		if (min != undefined) {
			_minValue = min;
			generateItems();
		}
	}
	
	public function set maxValue(max:Number):Void {
		if (max != undefined) {
			_maxValue = max;
			generateItems();
		}
	}
	
	public function set step(step:Number):Void {
		if (step != undefined) {
			_step = step;
			generateItems();
		}
	}
	
	
	/* Constructor */
	
	function NumberPicker() {
	}

	/* Private functions */

	private function init():Void {
	}

	private function generateItems():Void {
		if (_minValue == undefined || _maxValue == undefined || _step == undefined) return;
		
		var values = new Array();
		for (var i=_minValue; i<=_maxValue; i+=_step) {
			values.push({label:i.toString(), value:i});
		}
		items = values;
	}
}