package au.com.BI.Calendar;

import org.quartz.*;

public class CalendarEventEntry {
	public static final int SINGLE_EVENT = 1;
	public static final int REPEATING_EVENT = 2;
	protected Trigger trigger = null;
	protected String title = "";
	protected JobDetail jobDetail = null;
	protected boolean stillActive = true;
	protected String alarm = "";
	protected String category = "";
	protected String id = "";
	int eventType  = this.SINGLE_EVENT;

	public CalendarEventEntry () {
	}
	
	public JobDetail getJobDetail() {
		return jobDetail;
	}

	public void setJobDetail(JobDetail jobDetail) {
		this.jobDetail = jobDetail;
	}

	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	public Trigger getTrigger() {
		return trigger;
	}

	public void setTrigger(Trigger trigger) {
		this.trigger = trigger;
	}

	public int getEventType() {
		return eventType;
	}

	public void setEventType(int eventType) {
		this.eventType = eventType;
	}

	public void setStillActive(boolean stillActive) {
		this.stillActive = stillActive;
	}

	public boolean isStillActive() {
		return stillActive;
	}

	public String getAlarm() {
		return alarm;
	}

	public void setAlarm(String alarm) {
		this.alarm = alarm;
	}

	public String getCategory() {
		return category;
	}

	public void setCategory(String category) {
		this.category = category;
	}

	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}
	
}
