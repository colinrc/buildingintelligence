package au.com.BI.SignVideo;

import java.util.HashMap;
import java.util.Map;
import java.util.Vector;
import au.com.BI.Comms.CommsCommand;
import au.com.BI.AV.*;
import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.DeviceType;
import junitx.framework.ListAssert;
import au.com.BI.Command.*;
import junit.framework.*;

public class TestCommandsToFlash extends TestCase {
	private Model model = null;
	AV avFrontRoom = null;
	AV avAll = null;
	AV kitchenAV = null;
	
	protected void setUp() throws Exception {
		super.setUp();
		super.setUp();
		model = new Model();
	
		avAll = new AV ("All",DeviceType.AV);
		avAll.setKey("0");
		avAll.setOutputKey("ALL");
		
		avFrontRoom = new AV ("Front AV",DeviceType.AV);
		avFrontRoom.setKey("1");
		avFrontRoom.setOutputKey("FRONT_AV");

		kitchenAV = new AV ("Kitchen AV",DeviceType.AV);
		kitchenAV.setKey("2");
		kitchenAV.setOutputKey("KITCHEN_AV");

		model.addControlledItem(avFrontRoom.getKey(),avFrontRoom,DeviceType.MONITORED);
		model.addControlledItem(avAll.getKey(),avAll,DeviceType.MONITORED);
		model.addControlledItem(kitchenAV.getKey(),kitchenAV,DeviceType.MONITORED);
		
		model.addControlledItem("FRONT_AV",avFrontRoom,DeviceType.OUTPUT);
		model.addControlledItem("ALL",avAll,DeviceType.OUTPUT);
		model.addControlledItem("KITCHEN_AV",kitchenAV,DeviceType.OUTPUT);
		
		HashMap<String, String> map = new HashMap<String,String> (40);
		
		map.put("DVD1", "1");
		map.put("DVD2", "2");
		map.put("digital","3");
		map.put("tv", "4");
		
		model.setCatalogueDefs("SignVideo AV Inputs",map);
		
		model.setParameter("AV_INPUTS", "SignVideo AV Inputs", DeviceModel.MAIN_DEVICE_GROUP);
		model.setupParameterBlocks ();
		model.setPadding (1); 
	}

	public void testInterpretPowerOnSignVideo() {
		
		CommsCommand testString = new CommsCommand();
		testString.setCommandBytes(new byte[]{((byte)0xA4)});
		
		Vector <CommandInterface>expectedOutFlash = new Vector<CommandInterface>();
		
		AVCommand testCommand1 = new AVCommand("CLIENT_SEND","on",null,"");
		testCommand1.setDisplayName("FRONT_AV");
		expectedOutFlash.add(testCommand1);
		
		AVCommand testCommand2 = new AVCommand("CLIENT_SEND","on",null,"");
		testCommand2.setDisplayName("STUDY_AV");
		expectedOutFlash.add(testCommand2);
		
		AVCommand testCommand4 = new AVCommand("CLIENT_SEND","on",null,"");
		testCommand4.setDisplayName("KITCHEN_AV");
		expectedOutFlash.add(testCommand4);
		
		AVCommand testCommand5 = new AVCommand("CLIENT_SEND","on",null,"");
		testCommand5.setDisplayName("ALL");
		expectedOutFlash.add(testCommand5);

		BuildReturnWrapper val = model.interpretBytesFromSignVideo(testString);
		ListAssert.assertEquals ("Return value for interpret failed",val.getOutputFlash(),expectedOutFlash);
	}

	public void testInterpretPowerOffSignVideo() {
		
		CommsCommand testString = new CommsCommand();
		testString.setCommandBytes(new byte[]{((byte)0xA5)});
		
		Vector <CommandInterface>expectedOutFlash = new Vector<CommandInterface>();
		
		AVCommand testCommand1 = new AVCommand("CLIENT_SEND","off",null,"");
		testCommand1.setDisplayName("FRONT_AV");
		expectedOutFlash.add(testCommand1);
		
		AVCommand testCommand2 = new AVCommand("CLIENT_SEND","off",null,"");
		testCommand2.setDisplayName("STUDY_AV");
		expectedOutFlash.add(testCommand2);
		
		AVCommand testCommand4 = new AVCommand("CLIENT_SEND","off",null,"");
		testCommand4.setDisplayName("KITCHEN_AV");
		expectedOutFlash.add(testCommand4);
		
		AVCommand testCommand5 = new AVCommand("CLIENT_SEND","off",null,"");
		testCommand5.setDisplayName("ALL");
		expectedOutFlash.add(testCommand5);

		BuildReturnWrapper val = model.interpretBytesFromSignVideo(testString);
		ListAssert.assertEquals ("Return value for interpret failed",val.getOutputFlash(),expectedOutFlash);
	}
}
