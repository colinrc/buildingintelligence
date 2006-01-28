package au.com.BI.M1.Commands;

import au.com.BI.Util.Type;

public class ZoneStatus extends Type {

	public static final ZoneStatus NORMAL_UNCONFIGURED = new ZoneStatus("0","Normal Unconfigured");
	public static final ZoneStatus NORMAL_OPEN = new ZoneStatus("1","Normal Open");
	public static final ZoneStatus NORMAL_EOL = new ZoneStatus("2","Normal EOL");
	public static final ZoneStatus NORMAL_SHORT = new ZoneStatus("3","Normal Short");
	public static final ZoneStatus TROUBLE_OPEN = new ZoneStatus("5","Trouble Open");
	public static final ZoneStatus TROUBLE_EOL = new ZoneStatus("6","Trouble EOL");
	public static final ZoneStatus TROUBLE_SHORT = new ZoneStatus("7","Trouble Short");
	public static final ZoneStatus VIOLATED_OPEN = new ZoneStatus("9","Violated Open");
	public static final ZoneStatus VIOLATED_EOL = new ZoneStatus("A","Violated EOL");
	public static final ZoneStatus VIOLATED_SHORT = new ZoneStatus("B","Violated Short");
	public static final ZoneStatus BYPASSED_OPEN = new ZoneStatus("D","Bypassed Open");
	public static final ZoneStatus BYPASSED_EOL = new ZoneStatus("E","Bypassed EOL");
	public static final ZoneStatus BYPASSED_SHORT = new ZoneStatus("F","Bypassed Short");
	
	private ZoneStatus(String value, String desc) {
		super(value, desc);
		// TODO Auto-generated constructor stub
	}

	public static ZoneStatus getByValue(String value) {
		return((ZoneStatus)ZoneStatus.getByValue(ZoneStatus.class,value));
	}
}
