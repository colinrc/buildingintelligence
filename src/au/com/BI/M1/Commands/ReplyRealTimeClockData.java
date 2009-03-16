package au.com.BI.M1.Commands;

import au.com.BI.M1.M1Helper;
import au.com.BI.Util.Utility;

public class ReplyRealTimeClockData extends M1Command {
	
	private String second;
	private String minute;
	private String hour;
	private String dayOfWeek;
	private String dayOfMonth;
	private String month;
	private String year;
	private String daylightSavingsTimeString;
	private boolean daylightSavingsTime;
	private String twentyFourHourClockString;
	private boolean twentyFourHourClock;
	private String dateDisplayMode;

	public ReplyRealTimeClockData() {
		super();
		this.setCommand("RR");
	}

	public ReplyRealTimeClockData(String sum, String use) {
		super(sum, use);
		this.setCommand("RR");
	}

	public boolean isDaylightSavingsTime() {
		return daylightSavingsTime;
	}

	public void setDaylightSavingsTime(boolean daylightSavingsTime) {
		this.daylightSavingsTime = daylightSavingsTime;
		if (daylightSavingsTime) {
			daylightSavingsTimeString = "1";
		} else {
			daylightSavingsTimeString = "0";
		}
	}

	public String getDaylightSavingsTimeString() {
		return daylightSavingsTimeString;
	}

	public void setDaylightSavingsTimeString(String daylightSavingsTimeString) {
		this.daylightSavingsTimeString = daylightSavingsTimeString;
		if (daylightSavingsTimeString.equals("1")) {
			daylightSavingsTime = true;
		} else {
			daylightSavingsTime = false;
		}
	}

	public String getDayOfMonth() {
		return dayOfMonth;
	}

	public void setDayOfMonth(String dayOfMonth) {
		this.dayOfMonth = dayOfMonth;
	}

	public String getDayOfWeek() {
		return dayOfWeek;
	}

	public void setDayOfWeek(String dayOfWeek) {
		this.dayOfWeek = dayOfWeek;
	}

	public String getHour() {
		return hour;
	}

	public void setHour(String hour) {
		this.hour = hour;
	}

	public String getMinute() {
		return minute;
	}

	public void setMinute(String minute) {
		this.minute = minute;
	}

	public String getSecond() {
		return second;
	}

	public void setSecond(String second) {
		this.second = second;
	}

	public boolean isTwentyFourHourClock() {
		return twentyFourHourClock;
	}

	public void setTwentyFourHourClock(boolean twentyFourHourClock) {
		this.twentyFourHourClock = twentyFourHourClock;
		if (twentyFourHourClock) {
			twentyFourHourClockString = "0";
		} else {
			twentyFourHourClockString = "1";
		}
	}

	public String getTwentyFourHourClockString() {
		return twentyFourHourClockString;
	}

	public void setTwentyFourHourClockString(String twentyFourHourClockString) {
		this.twentyFourHourClockString = twentyFourHourClockString;
		if (twentyFourHourClockString.equals("1")) {
			twentyFourHourClock = false;
		} else {
			twentyFourHourClock = true;
		}
	}

	public String getMonth() {
		return month;
	}

	public void setMonth(String month) {
		this.month = month;
	}

	public String getYear() {
		return year;
	}

	public void setYear(String year) {
		this.year = year;
	}

	public String getDateDisplayMode() {
		return dateDisplayMode;
	}

	public void setDateDisplayMode(String dateDisplayMode) {
		this.dateDisplayMode = dateDisplayMode;
	}

	public String buildM1String() {
		String returnString = "";
		returnString = new M1Helper().buildCompleteM1String("RR"+
				Utility.padString(this.second,2)+
				Utility.padString(this.minute,2)+
				Utility.padString(this.hour,2)+
				Utility.padString(this.dayOfWeek,1)+
				Utility.padString(this.dayOfMonth,2)+
				Utility.padString(this.month,2)+
				Utility.padString(this.year,2)+
				Utility.padString(this.daylightSavingsTimeString,1)+
				Utility.padString(this.twentyFourHourClockString,1)+
				Utility.padString(this.dateDisplayMode,1)+
				"00");
		return returnString;
	}
}
