package au.com.BI.M1.Commands;

import au.com.BI.Util.Type;

public class ZonePartition extends Type {
	
	public static ZonePartition PARTITION_1 = new ZonePartition("1","Partition 1");
	public static ZonePartition PARTITION_2 = new ZonePartition("2","Partition 2");
	public static ZonePartition PARTITION_3 = new ZonePartition("3","Partition 3");
	public static ZonePartition PARTITION_4 = new ZonePartition("4","Partition 4");
	public static ZonePartition PARTITION_5 = new ZonePartition("5","Partition 5");
	public static ZonePartition PARTITION_6 = new ZonePartition("6","Partition 6");
	public static ZonePartition PARTITION_7 = new ZonePartition("7","Partition 7");
	public static ZonePartition PARTITION_8 = new ZonePartition("8","Partition 8");

	private ZonePartition(String value, String desc) {
		super(value, desc);

	}

	public static ZonePartition getByValue(String value) {
		return((ZonePartition)ZonePartition.getByValue(ZonePartition.class,value));
	}

}
