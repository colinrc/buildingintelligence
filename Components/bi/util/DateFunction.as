class bi.util.DateFunction {
	/**
	 dateDiff(datePart:String, date1:Date, date2:Date):Number
	 returns the difference between 2 dates
	 valid dateParts:
	 s: Seconds
	 n: Minutes
	 h: Hours
	 d: Days
	 m: Months
	 y: Years
	 */
	public static function dateAdd(datePart:String, date:Date, num:Number):Date {
		// get date part object;
		var dpo:Object = getDateAddPartHashMap()[datePart.toLowerCase()];
		// create new date as a copy of date passed in
		var newDate:Date = new Date(date.getFullYear(), date.getMonth(), date.getDate(), date.getHours(), date.getMinutes(), date.getSeconds(), date.getMilliseconds());
		// set the appropriate date part of the new date
		newDate[dpo.set](date[dpo.get]()+num);
		// return the new date
		return newDate;
	}
	private static function getDateAddPartHashMap():Object {
		var dpHashMap:Object = new Object();
		dpHashMap["s"] = new Object();
		dpHashMap["s"].get = "getSeconds";
		dpHashMap["s"].set = "setSeconds";
		dpHashMap["n"] = new Object();
		dpHashMap["n"].get = "getMinutes";
		dpHashMap["n"].set = "setMinutes";
		dpHashMap["h"] = new Object();
		dpHashMap["h"].get = "getHours";
		dpHashMap["h"].set = "setHours";
		dpHashMap["d"] = new Object();
		dpHashMap["d"].get = "getDate";
		dpHashMap["d"].set = "setDate";		
		dpHashMap["m"] = new Object();
		dpHashMap["m"].get = "getMonth";
		dpHashMap["m"].set = "setMonth";
		dpHashMap["y"] = new Object();
		dpHashMap["y"].get = "getFullYear";
		dpHashMap["y"].set = "setFullYear";
		return dpHashMap;
	}
	public static function dateDiff(datePart:String, date1:Date, date2:Date):Number {
		return getDatePartHashMap()[datePart.toLowerCase()](date1, date2);
	}
	private static function getDatePartHashMap():Object {
		var dpHashMap:Object = new Object();
		dpHashMap["s"] = getSeconds;
		dpHashMap["n"] = getMinutes;
		dpHashMap["h"] = getHours;
		dpHashMap["d"] = getDays;
		dpHashMap["w"] = getWeeks;
		dpHashMap["m"] = getMonths;	
		dpHashMap["y"] = getYears;
		return dpHashMap;
	}
	private static function compareDates(date1:Date, date2:Date):Number {
		return (date1.getTime() - (date1.getTimezoneOffset() * 1000)) - (date2.getTime() - (date2.getTimezoneOffset() * 1000));
	}
	private static function getSeconds(date1:Date, date2:Date):Number {
		return Math.floor(compareDates(date1, date2)/1000);
	}
	private static function getMinutes(date1:Date, date2:Date):Number {
		return Math.floor(getSeconds(date1, date2)/60);
	}
	private static function getHours(date1:Date, date2:Date):Number {
		return Math.floor(getMinutes(date1, date2)/60);
	}
	private static function getDays(date1:Date, date2:Date):Number {
		return Math.floor(getHours(date1, date2)/24);
	}
	private static function getWeeks(date1:Date, date2:Date):Number {
		return Math.floor(getDays(date1, date2)/7);
	}	
	private static function getMonths(date1:Date, date2:Date):Number {
		var yearDiff = getYears(date1, date2);
		var monthDiff = date1.getMonth()-date2.getMonth();
		if (monthDiff<0) {
			monthDiff += 12;
		}
		if (date1.getDate()<date2.getDate()) {
			monthDiff -= 1;
		}
		return 12 * yearDiff + monthDiff;
	}
	private static function getYears(date1:Date, date2:Date):Number {
		return Math.floor(getDays(date1, date2)/365);
	}
	
	public static function getFloatingDate(day:Number, month:Number, year:Number, nTh:Number):Date {
		if (nTh == 5) {
			var earliestDate = 22;
		} else {
			var earliestDate = 1 + 7 * (nTh - 1);
		}
		var earliestDay = new Date(year, month, earliestDate).getDay();
		
		if (day == earliestDay) {
			var offset = 0;
		} else {
		  if (day < earliestDay) {
			  var offset = day + (7 - earliestDay);
		  } else {
			  var offset = (day + (7 - earliestDay)) - 7;
		  }
		}
		
		var floatingDate = new Date(year, month, earliestDate + offset, 0, 0, 0, 0);
		
		if (nTh == 5 && dateAdd("d", floatingDate, 7).getMonth() == month) {
			floatingDate = dateAdd("d", floatingDate, 7);
		}
		
		return floatingDate;
	}
}
