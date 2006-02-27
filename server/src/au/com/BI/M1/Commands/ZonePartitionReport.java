package au.com.BI.M1.Commands;

public class ZonePartitionReport extends M1Command {
	
	private ZonePartition[] zonePartitions;

	public ZonePartitionReport() {
		super();
		this.setCommand("ZP");
		// TODO Auto-generated constructor stub
	}

	public ZonePartitionReport(String sum, String use) {
		super(sum, use);
		this.setCommand("ZP");
		// TODO Auto-generated constructor stub
	}

	public ZonePartition[] getZonePartitions() {
		return zonePartitions;
	}

	public void setZonePartitions(ZonePartition[] zonePartitions) {
		this.zonePartitions = zonePartitions;
	}
	
	

}
