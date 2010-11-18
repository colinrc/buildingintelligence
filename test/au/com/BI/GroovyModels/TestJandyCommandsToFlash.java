package au.com.BI.GroovyModels;

import java.util.HashMap;
import java.util.Vector;

import static org.junit.Assert.*;
import org.junit.Before;
import org.junit.Test;

import au.com.BI.Command.CommsProcessException;
import au.com.BI.Command.ReturnWrapper;
import au.com.BI.Sensors.*;
import au.com.BI.Pump.*;
import au.com.BI.Util.GroovyModelTestCase;
import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.MessageDirection;
import junitx.framework.ListAssert;
import au.com.BI.Command.*;
import au.com.BI.Device.DeviceType;

public class TestJandyCommandsToFlash extends GroovyModelTestCase {

	Sensor airTemp = null;
	Pump poolPump = null;
	
	public  String getModelToTest() {
		return "JANDY";
	}

	@Before
	public void setUp() throws Exception {
		super.setUp();

		// Below this line is the setting up the devices that will be used for testing. 
		// In the real running system these are set up from the config file.

		airTemp = new Sensor ("Air Temperature","","",DeviceType.SENSOR);
		airTemp.setKey("AIRTMP");
		airTemp.setOutputKey("AIR_TEMP");

		poolPump = new Pump ("Pool Pump",DeviceType.PUMP);
		poolPump.setKey("PUMP");
		poolPump.setOutputKey("POOL_PUMP");

		model.addControlledItem(airTemp.getKey(),airTemp,MessageDirection.FROM_HARDWARE);
		model.addControlledItem(poolPump.getKey(),poolPump,MessageDirection.FROM_HARDWARE);
		
		model.addControlledItem("AIRTMP",airTemp,MessageDirection.FROM_FLASH);
		model.addControlledItem("PUMP",poolPump,MessageDirection.FROM_FLASH);

		model.setParameter("UNITS", "C", DeviceModel.MAIN_DEVICE_GROUP);

		model.setPadding (2); // device requires 2 character keys that are 0 padded.
	}

	@Test
	public void testInterpretAir() {

		String testString = "!00 AIRTMP 0 25";
		
		Vector <CommandInterface>expectedOut = new Vector<CommandInterface>();
		
		SensorCommand testCommand = new SensorCommand("CLIENT_SEND","on",null,"25");
		testCommand.setDisplayName("AIR_TEMP");
		expectedOut.add(testCommand);

		ReturnWrapper val = new ReturnWrapper();
		try {
			model.processStringFromComms(testString,val);
		} catch (CommsProcessException e) {
			fail(e.getMessage());
		}
		ListAssert.assertEquals ("Return value for interpret failed",val.getOutputFlash(),expectedOut);
	}
	
	@Test
	public void testInterpretPump () {

		String testString = "!00 PUMP 0 1";
		
		Vector <CommandInterface>expectedOut = new Vector<CommandInterface>();

		SensorCommand testCommand = new SensorCommand("CLIENT_SEND","on",null,"");
		testCommand.setDisplayName("POOL_PUMP");
		expectedOut.add(testCommand);

		ReturnWrapper val = new ReturnWrapper();
		try {
			model.processStringFromComms(testString,val);
		} catch (CommsProcessException e) {
			fail(e.getMessage());
		}
		ListAssert.assertEquals ("Return value for interpret failed",val.getOutputFlash(),expectedOut);
	}
}
