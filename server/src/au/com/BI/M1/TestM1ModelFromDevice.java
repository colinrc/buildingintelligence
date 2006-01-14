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
import au.com.BI.M1.Commands.Disarm;
import au.com.BI.M1.Commands.M1Command;
import au.com.BI.M1.Commands.M1CommandFactory;
import au.com.BI.M1.Commands.OutputChangeUpdate;
import au.com.BI.M1.Commands.ReplyArmingStatusReportData;
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
	}

}
