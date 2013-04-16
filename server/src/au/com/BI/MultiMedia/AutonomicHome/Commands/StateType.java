package au.com.BI.MultiMedia.AutonomicHome.Commands;

import au.com.BI.Util.Type;

public class StateType extends Type {

	public static final StateType ARTIST_NAME = new StateType("ArtistName","ArtistName");
	public static final StateType CALLING_PARTY_NAME = new StateType("CallingPartyName","CallingPartyName");
	public static final StateType VOLUME = new StateType("Volume","Volume");
	public static final StateType SESSION_START = new StateType("SessionStart","SessionStart");
	public static final StateType RUNNING = new StateType("Running","Running");
	
	private StateType(String value, String desc) {
		super(value, desc);
	}
	
	public static StateType getByValue(String value) {
		return((StateType)StateType.getByValue(StateType.class,value));
	}
	
	public static StateType getByDescription(String description) {
		return((StateType)StateType.getByDescription(StateType.class, description));
	}
}
