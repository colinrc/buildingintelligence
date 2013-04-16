package au.com.BI.M1.Commands;

import java.util.Calendar;
import java.util.Date;
import java.util.GregorianCalendar;

import au.com.BI.M1.M1Helper;
import au.com.BI.Util.Utility;

public class SystemLogDataUpdate extends M1Command {
	
	private String event;
	private String eventNumberData;
	private String area;
	private String hour;
	private String minute;
	private String month;
	private String day;
	private String index;
	private String dayOfWeek;
	private String year;
	
	public SystemLogDataUpdate() {
		super();
		this.setCommand("LD");

	}

	public SystemLogDataUpdate(String sum, String use) {
		super(sum, use);
		this.setCommand("LD");

	}
	
	public String getArea() {
		return area;
	}

	public void setArea(String area) {
		this.area = Utility.padString(area,1);
	}

	public String getDay() {
		return day;
	}

	public void setDay(String day) {
		this.day = Utility.padString(day,2);
	}

	public String getDayOfWeek() {
		return dayOfWeek;
	}

	public void setDayOfWeek(String dayOfWeek) {
		this.dayOfWeek = Utility.padString(dayOfWeek,1);
	}

	public String getEvent() {
		return event;
	}

	public void setEvent(String event) {
		this.event = Utility.padString(event,4);
	}

	public String getEventNumberData() {
		return eventNumberData;
	}

	public void setEventNumberData(String eventNumberData) {
		this.eventNumberData = Utility.padString(eventNumberData,3);
	}

	public String getHour() {
		return hour;
	}

	public void setHour(String hour) {
		this.hour = Utility.padString(hour,2);
	}

	public String getIndex() {
		return index;
	}

	public void setIndex(String index) {
		this.index = Utility.padString(index,3);
	}

	public String getMinute() {
		return minute;
	}

	public void setMinute(String minute) {
		this.minute = Utility.padString(minute,2);
	}

	public String getMonth() {
		return month;
	}

	public void setMonth(String month) {
		this.month = Utility.padString(month,2);
	}

	public String getYear() {
		return year;
	}

	public void setYear(String year) {
		this.year = Utility.padString(year,2);
	}
	
	public void setDate(Calendar date) {
		setHour(Integer.toString(date.get(Calendar.HOUR)));
		setMinute(Integer.toString(date.get(Calendar.MINUTE)));
		setMonth(Integer.toString(date.get(Calendar.MONTH) + 1)); // M1 uses an 1 base to month
		setDay(Integer.toString(date.get(Calendar.DAY_OF_MONTH)));
		setDayOfWeek(Integer.toString(date.get(Calendar.DAY_OF_WEEK)));
		
		String year = Integer.toString(date.get(Calendar.YEAR));
		setYear(year.substring(2,4));
	}
	
	public void now() {
		setDate(Calendar.getInstance());
	}
	
	public void loggingEntry() {
		setIndex("000");
	}

	public String buildM1String() {
		String returnString = "";
		returnString = new M1Helper().buildCompleteM1String("LD" +
				getEvent() + 
				getEventNumberData() + 
				getArea() + 
				getHour() + 
				getMinute() + 
				getMonth() + 
				getDay() + 
				getIndex() + 
				getDayOfWeek() + 
				getYear() + "00");
		return returnString;
	}
}
