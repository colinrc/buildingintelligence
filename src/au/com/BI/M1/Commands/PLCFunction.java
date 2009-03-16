package au.com.BI.M1.Commands;

import au.com.BI.Util.Type;

public class PLCFunction extends Type {
	public static final PLCFunction X10_ALL_UNITS_OFF = new PLCFunction("01","X10_ALL_UNITS_OFF");
	public static final PLCFunction X10_ALL_LIGHTS_ON = new PLCFunction("02","X10_ALL_LIGHTS_ON");
	public static final PLCFunction X10_UNIT_ON = new PLCFunction("03","X10_UNIT_ON");
	public static final PLCFunction X10_UNIT_OFF = new PLCFunction("04","X10_UNIT_OFF");
	public static final PLCFunction X10_DIM = new PLCFunction("05","X10_DIM");
	public static final PLCFunction X10_BRIGHT = new PLCFunction("06","X10_BRIGHT");
	public static final PLCFunction X10_ALL_LIGHTS_OFF = new PLCFunction("07","X10_ALL_LIGHTS_OFF");
	public static final PLCFunction X10_EXTENDED_CODE = new PLCFunction("08","X10_EXTENDED_CODE");
	public static final PLCFunction X10_PRESET_DIM = new PLCFunction("09","X10_PRESET_DIM");
	public static final PLCFunction X10_EXTENDED_DATA = new PLCFunction("10","X10_EXTENDED_DATA");
	public static final PLCFunction X10_STATUS_REQ = new PLCFunction("11","X10_STATUS_REQ");
	public static final PLCFunction X10_HAIL_REQUEST = new PLCFunction("12","X10_HAIL_REQUEST");
	public static final PLCFunction X10_HAIL_ACK = new PLCFunction("13","X10_HAIL_ACK");
	public static final PLCFunction X10_STATUS_ON = new PLCFunction("14","X10_STATUS_ON");
	public static final PLCFunction X10_STATUS_OFF = new PLCFunction("15","X10_STATUS_OFF");
	
	private PLCFunction(String value, String desc) {
		super(value, desc);
	}
	
	public static PLCFunction getByValue(String value) {
		return((PLCFunction)PLCFunction.getByValue(PLCFunction.class,value));
	}
	
	public static PLCFunction getByDescription(String description) {
		return((PLCFunction)PLCFunction.getByDescription(PLCFunction.class,description));
	}
}
