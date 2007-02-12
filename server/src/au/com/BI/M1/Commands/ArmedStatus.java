package au.com.BI.M1.Commands;

import au.com.BI.Util.Type;

public class ArmedStatus extends Type {

	public static final ArmedStatus DISARMED = new ArmedStatus("0","Disarmed");
	public static final ArmedStatus ARMED_AWAY = new ArmedStatus("1","Armed Away");
	public static final ArmedStatus ARMED_STAY = new ArmedStatus("2","Armed Stay");
	public static final ArmedStatus ARMED_STAY_INSTANT = new ArmedStatus("3","Armed Stay Instant");
	public static final ArmedStatus ARMED_TO_NIGHT = new ArmedStatus("4","Armed To Night");
	public static final ArmedStatus ARMED_TO_NIGHT_INSTANT = new ArmedStatus("5","Armed To Night Instant");
	public static final ArmedStatus ARMED_TO_VACATION = new ArmedStatus("6","Armed To Vacation");
	
	private ArmedStatus(String value, String desc) {
		super(value, desc);

	}
	
	public static ArmedStatus getByValue(String value) {
		return((ArmedStatus)ArmedStatus.getByValue(ArmedStatus.class,value));
	}
}
