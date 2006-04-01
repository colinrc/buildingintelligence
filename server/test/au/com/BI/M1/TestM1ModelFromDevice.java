package au.com.BI.M1;

import junit.framework.TestCase;
import au.com.BI.M1.Commands.ArmStepToNextAwayMode;
import au.com.BI.M1.Commands.ArmStepToNextStayMode;
import au.com.BI.M1.Commands.ArmToAway;
import au.com.BI.M1.Commands.ArmToNight;
import au.com.BI.M1.Commands.ArmToNightInstant;
import au.com.BI.M1.Commands.ArmToStayHome;
import au.com.BI.M1.Commands.ArmToStayInstant;
import au.com.BI.M1.Commands.ArmToVacation;
import au.com.BI.M1.Commands.ArmedStatus;
import au.com.BI.M1.Commands.ArmingStatusRequest;
import au.com.BI.M1.Commands.ControlOutputOff;
import au.com.BI.M1.Commands.ControlOutputOn;
import au.com.BI.M1.Commands.ControlOutputStatusRequest;
import au.com.BI.M1.Commands.ControlOutputToggle;
import au.com.BI.M1.Commands.Disarm;
import au.com.BI.M1.Commands.M1Command;
import au.com.BI.M1.Commands.M1CommandFactory;
import au.com.BI.M1.Commands.OutputChangeUpdate;
import au.com.BI.M1.Commands.ReplyArmingStatusReportData;
import au.com.BI.M1.Commands.ReplyWithBypassedZoneState;
import au.com.BI.M1.Commands.ZoneBypassRequest;
import au.com.BI.M1.Commands.ZoneBypassState;
import au.com.BI.M1.Commands.ZoneChangeUpdate;
import au.com.BI.M1.Commands.ZonePartition;
import au.com.BI.M1.Commands.ZonePartitionReport;
import au.com.BI.M1.Commands.ZonePartitionRequest;
import au.com.BI.M1.Commands.ZoneStatus;
import au.com.BI.M1.Commands.ZoneStatusReport;
import au.com.BI.M1.Commands.ZoneStatusRequest;
import au.com.BI.ToggleSwitch.ToggleSwitch;
import au.com.BI.Util.DeviceType;
import au.com.BI.Util.Utility;

public class TestM1ModelFromDevice extends TestCase {
	
	private Model model = null;
	private ToggleSwitch testSwitch1 = null;
	private M1Helper m1Helper = null;

	protected void setUp() throws Exception {
		super.setUp();
		
		model = new Model();
		testSwitch1 = new ToggleSwitch("testM1Switch",DeviceType.TOGGLE_OUTPUT);
		testSwitch1.setKey("001");
		testSwitch1.setGroupName("M1PIR");
		
		m1Helper = model.getM1Helper();
		
		model.addControlledItem("M1PIR",testSwitch1,DeviceType.TOGGLE_OUTPUT);
	}
	
	protected void tearDown() throws Exception {
		super.tearDown();
	}
	
	public void testM1CommandFactory() {
		String str = m1Helper.buildCompleteM1String("CC" + Utility.padString(testSwitch1.getKey(),3) + "0" + "00"); // off command for the output change control
		M1Command m1Command = M1CommandFactory.getInstance().getM1Command(str);
		assertEquals(m1Command.getClass(),OutputChangeUpdate.class);
		
		str = "a01123456";
		m1Command = M1CommandFactory.getInstance().getM1Command(str);
		assertEquals(m1Command.getClass(),Disarm.class);
		
		str = "a11123456";
		m1Command = M1CommandFactory.getInstance().getM1Command(str);
		assertEquals(m1Command.getClass(),ArmToAway.class);
		
		str = "a21123456";
		m1Command = M1CommandFactory.getInstance().getM1Command(str);
		assertEquals(m1Command.getClass(),ArmToStayHome.class);
		
		str = "a31123456";
		m1Command = M1CommandFactory.getInstance().getM1Command(str);
		assertEquals(m1Command.getClass(),ArmToStayInstant.class);
		
		str = "a41123456";
		m1Command = M1CommandFactory.getInstance().getM1Command(str);
		assertEquals(m1Command.getClass(),ArmToNight.class);
		
		str = "a51123456";
		m1Command = M1CommandFactory.getInstance().getM1Command(str);
		assertEquals(m1Command.getClass(),ArmToNightInstant.class);
		
		str = "a61123456";
		m1Command = M1CommandFactory.getInstance().getM1Command(str);
		assertEquals(m1Command.getClass(),ArmToVacation.class);
		
		str = "a71123456";
		m1Command = M1CommandFactory.getInstance().getM1Command(str);
		assertEquals(m1Command.getClass(),ArmStepToNextAwayMode.class);
		
		str = "a81123456";
		m1Command = M1CommandFactory.getInstance().getM1Command(str);
		assertEquals(m1Command.getClass(),ArmStepToNextStayMode.class);
		
		str = "06as0066";
		m1Command = M1CommandFactory.getInstance().getM1Command(str);
		assertEquals(m1Command.getClass(),ArmingStatusRequest.class);
		
		str = "1EAS100000004000000030000000000E";
		m1Command = M1CommandFactory.getInstance().getM1Command(str);
		assertEquals(m1Command.getClass(),ReplyArmingStatusReportData.class);
		ReplyArmingStatusReportData data = (ReplyArmingStatusReportData)m1Command;
		assertEquals(data.getArmedStatus()[0],ArmedStatus.ARMED_AWAY);
		
		str = "06zs004D";
		m1Command = M1CommandFactory.getInstance().getM1Command(str);
		assertEquals(m1Command.getClass(),ZoneStatusRequest.class);
		
		str = "D6ZS01235679ABDEF00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
		String checksum = new M1Helper().calcM1Checksum(str);
		str = str + checksum;
		m1Command = M1CommandFactory.getInstance().getM1Command(str);
		assertEquals(m1Command.getClass(),ZoneStatusReport.class);
		ZoneStatusReport zoneStatus = (ZoneStatusReport)m1Command;
		assertEquals(zoneStatus.getZoneStatus()[0],ZoneStatus.NORMAL_UNCONFIGURED);
		assertEquals(zoneStatus.getZoneStatus()[1],ZoneStatus.NORMAL_OPEN);
		assertEquals(zoneStatus.getZoneStatus()[2],ZoneStatus.NORMAL_EOL);
		assertEquals(zoneStatus.getZoneStatus()[3],ZoneStatus.NORMAL_SHORT);
		assertEquals(zoneStatus.getZoneStatus()[4],ZoneStatus.TROUBLE_OPEN);
		assertEquals(zoneStatus.getZoneStatus()[5],ZoneStatus.TROUBLE_EOL);
		assertEquals(zoneStatus.getZoneStatus()[6],ZoneStatus.TROUBLE_SHORT);
		assertEquals(zoneStatus.getZoneStatus()[7],ZoneStatus.VIOLATED_OPEN);
		assertEquals(zoneStatus.getZoneStatus()[8],ZoneStatus.VIOLATED_EOL);
		assertEquals(zoneStatus.getZoneStatus()[9],ZoneStatus.VIOLATED_SHORT);
		assertEquals(zoneStatus.getZoneStatus()[10],ZoneStatus.BYPASSED_OPEN);
		assertEquals(zoneStatus.getZoneStatus()[11],ZoneStatus.BYPASSED_EOL);
		assertEquals(zoneStatus.getZoneStatus()[12],ZoneStatus.BYPASSED_SHORT);
		
		str = "06zp0050";
		m1Command = M1CommandFactory.getInstance().getM1Command(str);
		assertEquals(m1Command.getClass(),ZonePartitionRequest.class);
		
		str = "D6ZP112345678123400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000";
		checksum = new M1Helper().calcM1Checksum(str);
		str = str + checksum;
		m1Command = M1CommandFactory.getInstance().getM1Command(str);
		assertEquals(m1Command.getClass(),ZonePartitionReport.class);
		ZonePartitionReport zonePartitions = (ZonePartitionReport)m1Command;
		assertEquals(zonePartitions.getZonePartitions()[0],ZonePartition.PARTITION_1);
		assertEquals(zonePartitions.getZonePartitions()[1],ZonePartition.PARTITION_1);
		assertEquals(zonePartitions.getZonePartitions()[2],ZonePartition.PARTITION_2);
		assertEquals(zonePartitions.getZonePartitions()[3],ZonePartition.PARTITION_3);
		assertEquals(zonePartitions.getZonePartitions()[4],ZonePartition.PARTITION_4);
		assertEquals(zonePartitions.getZonePartitions()[5],ZonePartition.PARTITION_5);
		assertEquals(zonePartitions.getZonePartitions()[6],ZonePartition.PARTITION_6);
		assertEquals(zonePartitions.getZonePartitions()[7],ZonePartition.PARTITION_7);
		assertEquals(zonePartitions.getZonePartitions()[8],ZonePartition.PARTITION_8);
		assertEquals(zonePartitions.getZonePartitions()[9],ZonePartition.PARTITION_1);
		assertEquals(zonePartitions.getZonePartitions()[10],ZonePartition.PARTITION_2);
		assertEquals(zonePartitions.getZonePartitions()[11],ZonePartition.PARTITION_3);
		assertEquals(zonePartitions.getZonePartitions()[12],ZonePartition.PARTITION_4);
		
		str = "10zb0051003456006B";
		m1Command = M1CommandFactory.getInstance().getM1Command(str);
		assertEquals(m1Command.getClass(),ZoneBypassRequest.class);
		ZoneBypassRequest bypassRequest = (ZoneBypassRequest)m1Command;
		assertEquals(bypassRequest.getArea(),"1");
		assertEquals(bypassRequest.getZone(),"005");
		assertEquals(bypassRequest.getPinCode(),"003456");
		
		str = "0AZB123100CC";
		m1Command = M1CommandFactory.getInstance().getM1Command(str);
		assertEquals(m1Command.getClass(),ReplyWithBypassedZoneState.class);
		ReplyWithBypassedZoneState replyWithState = (ReplyWithBypassedZoneState)m1Command;
		assertEquals(replyWithState.getZone(),"123");
		assertEquals(replyWithState.getBypassState(),ZoneBypassState.BYPASSED);
		
		str = "0BZC00220009D";
		m1Command = M1CommandFactory.getInstance().getM1Command(str);
		assertEquals(m1Command.getClass(),ZoneChangeUpdate.class);
		ZoneChangeUpdate zoneChangeUpdate = (ZoneChangeUpdate)m1Command;
		assertEquals(zoneChangeUpdate.getZone(),"002");
		assertEquals(zoneChangeUpdate.getZoneStatus(),ZoneStatus.NORMAL_EOL);
		assertEquals(zoneChangeUpdate.getFutureUse(),"00");
		
		ControlOutputOn controlOutputOn = new ControlOutputOn();
		controlOutputOn.setOutputNumber("001");
		controlOutputOn.setSeconds(10);
		assertEquals(controlOutputOn.buildM1String(),"0Ecn0010001000D8");
		m1Command = M1CommandFactory.getInstance().getM1Command(controlOutputOn.buildM1String());
		assertEquals(m1Command.getClass(),controlOutputOn.getClass());
		
		ControlOutputOff controlOutputOff = new ControlOutputOff();
		controlOutputOff.setOutputNumber("002");
		assertEquals(controlOutputOff.buildM1String(),"09cf00200DC");
		m1Command = M1CommandFactory.getInstance().getM1Command(controlOutputOff.buildM1String());
		assertEquals(m1Command.getClass(),controlOutputOff.getClass());
		
		ControlOutputToggle controlOutputToggle = new ControlOutputToggle();
		controlOutputToggle.setOutputNumber("002");
		assertEquals(controlOutputToggle.buildM1String(),"09ct00200CE");
		m1Command = M1CommandFactory.getInstance().getM1Command(controlOutputToggle.buildM1String());
		assertEquals(m1Command.getClass(),controlOutputToggle.getClass());
		
		ControlOutputStatusRequest controlOutputStatusRequest = new ControlOutputStatusRequest();
		assertEquals(controlOutputStatusRequest.buildM1String(),"06cs0064");
		m1Command = M1CommandFactory.getInstance().getM1Command(controlOutputStatusRequest.buildM1String());
		assertEquals(m1Command.getClass(),controlOutputStatusRequest.getClass());
	}

}
