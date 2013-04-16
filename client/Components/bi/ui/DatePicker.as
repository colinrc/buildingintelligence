import bi.ui.TextInput;
import bi.ui.Label;
import bi.ui.Button;
import mx.utils.Delegate;

class bi.ui.DatePicker extends bi.ui.CoreUI {

	private var day_ti:TextInput;
	private var colon1_lb:Label;
	private var month_ti:TextInput;
	private var colon2_lb:Label;
	private var year_ti:TextInput;
	
	private var up_btn:Button;
	private var down_btn:Button;
	
	private var _date:Date;
	private var _currentField:TextInput;
	
	private var _repeatInterval;

	/* Getters and Setters */
	
	public function get dateAsString():String {
		return day.toString() + "/" + month.toString() + "/" + year.toString();
	}

	public function get date():Date {
		return _date;
	}
	
	public function set date(date:Date):Void {
		if (date != undefined) {
			_date = date;
			day = _date.getDate();
			month = _date.getMonth();
			year = _date.getFullYear();
		}
	}
	
	public function get day():Number {
		return _date.getDate();
	}
	
	public function set day(day:Number):Void {
		_date = new Date(_date.getFullYear(), _date.getMonth(), day);
		day_ti.text = day.toString();
	}
	
	public function get month():Number {
		return _date.getMonth();
	}
	
	public function set month(month:Number):Void {
		_date = new Date(_date.getFullYear(), month, _date.getDate());
		month_ti.text = (month + 1).toString();
	}
	
	public function get year():Number {
		return _date.getFullYear();
	}
	
	public function set year(year:Number):Void {
		_date = new Date(year, _date.getMonth(), _date.getDate());
		year_ti.text = year.toString();
	}
	
	/* Constructor */
	
	function DatePicker() {
		createChildren();
		draw();
	}

	/* Private functions */

	private function init():Void {
	}

	private function createChildren():Void {
		attachMovie("bi.ui.TextInput", "day_ti", 10, {settings:{width:30, _x:0, readOnly:true}});
		attachMovie("bi.ui.Label", "colon1_lb", 20, {settings:{width:15, _x:30, text:"/", align:"center"}});
		attachMovie("bi.ui.TextInput", "month_ti", 30, {settings:{width:30, _x:45, readOnly:true}});
		attachMovie("bi.ui.Label", "colon2_lb", 40, {settings:{width:15, _x:75, text:"/", align:"center"}});
		attachMovie("bi.ui.TextInput", "year_ti", 50, {settings:{width:60, _x:90, readOnly:true}});

		attachMovie("bi.ui.Button", "up_btn", 60, {settings:{width:45, _x:155, iconName:"up-arrow"}});
		attachMovie("bi.ui.Button", "down_btn", 70, {settings:{width:45, _x:205, iconName:"down-arrow"}});
		
		day_ti.addEventListener("focus", Delegate.create(this, changeFocus));
		month_ti.addEventListener("focus", Delegate.create(this, changeFocus));
		year_ti.addEventListener("focus", Delegate.create(this, changeFocus));
		
		up_btn.addEventListener("press", Delegate.create(this, buttonPress));
		down_btn.addEventListener("press", Delegate.create(this, buttonPress));
		up_btn.addEventListener("release", Delegate.create(this, buttonRelease));
		down_btn.addEventListener("release", Delegate.create(this, buttonRelease));
		
		date = _date;
		_currentField = day_ti;
		_currentField.highlight = true;
	}
  
	private function draw():Void {
	}
	
	private function changeFocus(eventObj):Void {
		_currentField.highlight = false;
		_currentField = eventObj.target;
		_currentField.highlight = true;
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
		if (_currentField._name == "day_ti") {
			var unit = day + amt;
			if (unit > 31) unit = 1;
			if (unit < 1) unit = 31;
			day = unit;
		} else if (_currentField._name == "month_ti") {
			var unit = month + amt;
			if (unit > 11) unit = 0;
			if (unit < 0) unit = 11;
			month = unit;
		} else {
			var unit = year + amt;
			if (unit > 2050) unit = 2000;
			if (unit < 2000) unit = 2050;
			year = unit;
		}
	}
}