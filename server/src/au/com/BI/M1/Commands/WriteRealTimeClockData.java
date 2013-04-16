package au.com.BI.M1.Commands;

import au.com.BI.M1.M1Helper;
import au.com.BI.Util.Utility;

public class WriteRealTimeClockData extends M1Command {

	private String second;
	private String minute;
	private String hour;
	private String dayOfWeek;
	private String dayOfMonth;
	private String month;
	private String year;
	
	public WriteRealTimeClockData() {
		super();
		this.setCommand("rw");
	}

	public WriteRealTimeClockData(String sum, String use) {
		super(sum, use);
		this.setCommand("rw");
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
	
	public String buildM1String() {
		String returnString = "";
		returnString = new M1Helper().buildCompleteM1String("rw"+
				Utility.padString(this.second,2)+
				Utility.padString(this.minute,2)+
				Utility.padString(this.hour,2)+
				Utility.padString(this.dayOfWeek,1)+
				Utility.padString(this.dayOfMonth,2)+
				Utility.padString(this.month,2)+
				Utility.padString(this.year,2)+
				"00");
		return returnString;
	}
}
