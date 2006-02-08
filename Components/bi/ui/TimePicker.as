import bi.ui.TextInput;
import bi.ui.Label;
import bi.ui.Button;
import mx.utils.Delegate;

class bi.ui.TimePicker extends bi.ui.CoreUI {

	private var hours_ti:TextInput;
	private var colon_lb:Label;
	private var minutes_ti:TextInput;
	private var up_btn:Button;
	private var down_btn:Button;
	
	private var _time:Date;
	private var _currentField:TextInput;
	
	private var _repeatInterval;

	/* Getters and Setters */
	
	public function get timeAsString():String {
		return hours.toString() + ":" + minutes.toString() + ":00";
	}

	public function get time():Date {
		return _time;
	}
	
	public function set time(time:Date):Void {
		if (time != undefined) {
			_time = time;
			hours = _time.getHours();
			minutes = _time.getMinutes();
		}
	}
	
	public function get hours():Number {
		return _time.getHours();
	}
	
	public function set hours(hour:Number):Void {
		_time = new Date(_time.getFullYear(), _time.getMonth(), _time.getDate(), hour, _time.getMinutes());
		if (hour < 10) {
			hours_ti.text = "0" + hour.toString();
		} else {
			hours_ti.text = hour.toString();
		}
	}
	
	public function get minutes():Number {
		return _time.getMinutes();
	}
	
	public function set minutes(minute:Number):Void {
		_time = new Date(_time.getFullYear(), _time.getMonth(), _time.getDate(), _time.getHours(), minute);
		if (minute < 10) {
			minutes_ti.text = "0" + minute.toString();
		} else {
			minutes_ti.text = minute.toString();
		}
	}
	
	/* Constructor */
	
	function TimePicker() {
		initFromClipParameters();
		super.init();
		init();
		createChildren();
		draw();
	}

	/* Private functions */

	private function init():Void {
	}

	private function createChildren():Void {
		attachMovie("bi.ui.TextInput", "hours_ti", 10, {settings:{width:30, _x:0, readOnly:true}});
		attachMovie("bi.ui.Label", "colon_lb", 20, {settings:{width:15, _x:30, text:":", align:"center"}});
		attachMovie("bi.ui.TextInput", "minutes_ti", 30, {settings:{width:30, _x:45, readOnly:true}});
		attachMovie("bi.ui.Button", "up_btn", 40, {settings:{width:45, _x:85, iconName:"up-arrow"}});
		attachMovie("bi.ui.Button", "down_btn", 50, {settings:{width:45, _x:135, iconName:"down-arrow"}});
		
		hours_ti.addEventListener("focus", Delegate.create(this, changeFocus));
		minutes_ti.addEventListener("focus", Delegate.create(this, changeFocus));
		
		up_btn.addEventListener("press", Delegate.create(this, buttonPress));
		down_btn.addEventListener("press", Delegate.create(this, buttonPress));
		up_btn.addEventListener("release", Delegate.create(this, buttonRelease));
		down_btn.addEventListener("release", Delegate.create(this, buttonRelease));
		
		time = _time;
		_currentField = hours_ti;
	}
  
	private function arrange():Void {
	}
	
	private function changeFocus(eventObj):Void {
		_currentField = eventObj.target;
	}
	
	private function buttonPress(eventObj):Void {
		if (eventObj.target == up_btn) {
			_repeatInterval = setInterval(this, "buttonAction", 100, "up");
			buttonAction("up");
		} else {
			_repeatInterval = setInterval(this, "buttonAction", 100, "down");
			buttonAction("down");
		}
	}
	
	private function buttonRelease(eventObj):Void {
		clearInterval(_repeatInterval);
	}
	
	private function buttonAction(direction):Void {
		if (direction == "up") {
			var amt = 1;
		} else {
			var amt = - 1;
		}
		if (_currentField._name == "hours_ti") {
			var unit = hours + amt;
			if (unit > 23) unit = 0;
			if (unit < 0) unit = 23;
			hours = unit;
		} else {
			var unit = minutes + amt;
			if (unit > 59) unit = 0;
			if (unit < 0) unit = 59;
			minutes = unit;
		}
	}
}