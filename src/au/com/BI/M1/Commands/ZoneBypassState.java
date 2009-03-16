package au.com.BI.M1.Commands;

import au.com.BI.Util.Type;

public class ZoneBypassState extends Type {
	
	public static ZoneBypassState UNBYPASSED = new ZoneBypassState("0","Unbypassed");
	public static ZoneBypassState BYPASSED = new ZoneBypassState("1","Bypassed");

	private ZoneBypassState(String value, String desc) {
		super(value, desc);

	}

	public static ZoneBypassState getByValue(String value) {
		return((ZoneBypassState)ZoneBypassState.getByValue(ZoneBypassState.class,value));
	}
	
}
