package au.com.BI.SignVideo;

import java.util.HashMap;
import java.util.Map;
import java.util.Vector;

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
		avAll.setKey("00");
		avAll.setOutputKey("ALL");
		
		avFrontRoom = new AV ("Front AV",DeviceType.AV);
		avFrontRoom.setKey("01");
		avFrontRoom.setOutputKey("FRONT_AV");

		kitchenAV = new AV ("Kitchen AV",DeviceType.AV);
		kitchenAV.setKey("02");
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
		model.setupAVInputs ();
		model.setPadding (1); 
	}

	public void testInterpretStringFromSignVideo() {
		
		Command testString = new Command();
		testString.setKey("#Z01PWRON,SRC2,GRP0,VOL-MT");
		Vector <CommandInterface>expectedOut = new Vector<CommandInterface>();
		
		AVCommand testCommand = new AVCommand("CLIENT_SEND","on",null,"");
		testCommand.setDisplayName("FRONT_AV");
		expectedOut.add(testCommand);

		AVCommand testCommand2 = new AVCommand("CLIENT_SEND","src",null,"DVD2");
		testCommand2.setDisplayName("FRONT_AV");
		expectedOut.add(testCommand2);

		AVCommand testCommand3 = new AVCommand("CLIENT_SEND","mute",null,"on");
		testCommand3.setDisplayName("FRONT_AV");
		expectedOut.add(testCommand3);

		BuildReturnWrapper val = model.interpretStringFromSignVideo(testString);
		ListAssert.assertEquals ("Return value for interpret failed",val.getOutputFlash(),expectedOut);
	}
	

	
	public void testInterpretStatus() {

		Vector <CommandInterface>expectedOut = new Vector<CommandInterface>();	
		Command testString = new Command();
		
		testString.setKey("#Z01PWRON,SRC2,GRP0,VOL-79");
		BuildReturnWrapper val = model.interpretStringFromSignVideo(testString);

		testString.setKey("#Z01PWRON,SRC2,GRP0,VOL-00");
		val = model.interpretStringFromSignVideo(testString);

		AVCommand testCommand = new AVCommand("CLIENT_SEND","volume",null,"100");
		testCommand.setDisplayName("FRONT_AV");
		
		AVCommand testCommand2 = new AVCommand("CLIENT_SEND","on",null,"");
		testCommand2.setDisplayName("FRONT_AV");
		expectedOut.add(testCommand2);
		
		AVCommand testCommand3 = new AVCommand("CLIENT_SEND","src",null,"DVD2");
		testCommand3.setDisplayName("FRONT_AV");
		expectedOut.add(testCommand3);
		
		ListAssert.assertContains ("Return value for interpret status volume failed",val.getOutputFlash(),testCommand);
		
		Assert.assertFalse ("Interpret status incorrectly contained power",val.getOutputFlash().contains(testCommand2));
		
		Assert.assertFalse ("Interpret status incorrectly contained src",val.getOutputFlash().contains(testCommand3));
		
		testString.setKey("#Z01PWRON,SRC1,GRP0,VOL-00");
		val = model.interpretStringFromSignVideo(testString);
		
		AVCommand testCommand4 = new AVCommand("CLIENT_SEND","src",null,"DVD2");
		testCommand4.setDisplayName("FRONT_AV");
		expectedOut.add(testCommand4);
		
		Assert.assertFalse ("Interpret status did not detect src change",val.getOutputFlash().contains(testCommand4));
	}

}
