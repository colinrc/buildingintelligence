package au.com.BI.MultiMedia.SlimServer.Commands;

import au.com.BI.Util.Type;

public class SortOrder extends Type {

	public static final SortOrder NONE = new SortOrder("none", "none");
	public static final SortOrder ALBUM = new SortOrder("album","album");
	public static final SortOrder NEW = new SortOrder("new","new");
	
	private SortOrder(String value, String desc) {
		super(value, desc);
	}
	
	public static SortOrder getByValue(String value) {
		return((SortOrder)SortOrder.getByValue(SortOrder.class,value));
	}
	
	public static SortOrder getByDescription(String description) {
		return((SortOrder)SortOrder.getByDescription(SortOrder.class, description));
	}
}
