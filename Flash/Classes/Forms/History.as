import mx.utils.Delegate;
import mx.controls.*;
class Forms.History extends Forms.BaseForm {
	private var history_ta:TextArea;
	function History() {
	}
	
	public function init():Void {
		history_ta.text = _global.history.viewHistory();
	}
}