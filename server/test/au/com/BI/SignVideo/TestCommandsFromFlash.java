package au.com.BI.SignVideo;

import java.util.HashMap;
import java.util.Vector;


import au.com.BI.AV.*;
import au.com.BI.Flash.ClientCommand;
import au.com.BI.SignVideo.Model;
import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.DeviceType;
import junit.framework.*;
import junitx.framework.ListAssert;

public class TestCommandsFromFlash extends TestCase {
	private Model model = null;
	AV avFrontRoom = null;
	AV avAll = null;
	AV kitchenAV = null;
	AV studyAV = null;
	
	public static void main(String[] args) {
		junit.swingui.TestRunner.run(TestCommandsFromFlash.class);
	}

	protected void setUp() throws Exception {
		super.setUp();
		model = new Model();
	
		avAll = new AV ("All",DeviceType.AUDIO);
		avAll.setKey("00");
		avAll.setOutputKey("ALL");
		
		avFrontRoom = new AV ("Front AV",DeviceType.AUDIO);
		avFrontRoom.setKey("01");
		avFrontRoom.setOutputKey("FRONT_AV");

		kitchenAV = new AV ("Kitchen AV",DeviceType.AUDIO);
		kitchenAV.setKey("02");
		kitchenAV.setOutputKey("KITCHEN_AV");


		studyAV = new AV ("Study AV",DeviceType.AUDIO);
		studyAV.setKey("03");
		studyAV.setOutputKey("STUDY_AV");
		
		model.addControlledItem("FRONT_AV",avFrontRoom,DeviceType.OUTPUT);
		model.addControlledItem("ALL",avAll,DeviceType.OUTPUT);
		model.addControlledItem("KITCHEN_AV",kitchenAV,DeviceType.OUTPUT);
		model.addControlledItem("STUDY_AV",studyAV,DeviceType.OUTPUT);
		
		model.addControlledItem(avFrontRoom.getKey(),avFrontRoom,DeviceType.MONITORED);
		model.addControlledItem(avAll.getKey(),avAll,DeviceType.MONITORED);
		model.addControlledItem(kitchenAV.getKey(),kitchenAV,DeviceType.MONITORED);
		model.addControlledItem(studyAV.getKey(),studyAV,DeviceType.MONITORED);
		
		HashMap<String, String> map = new HashMap<String,String> (40);
		
		map.put("DVD1", "1");
		map.put("DVD2", "2");
		map.put("digital","3");
		map.put("tv", "4");
		
		model.setCatalogueDefs("Sign AV Inputs",map);
		
		model.setParameter("AV_INPUTS", "Sign AV Inputs", DeviceModel.MAIN_DEVICE_GROUP);
		model.setupAVInputs ();
		model.initState();
		
		model.setPadding (2); // device requires 2 character keys that are 0 padded.
		
	}

	protected void tearDown() throws Exception {
		super.tearDown();
	}

	public void testBuildAVAllOff() {
		ClientCommand testCommand = new ClientCommand("ALL","off",null,"","","","","");
		byte[] expectedOut = new byte[]{((byte)0xA5)};
		SignVideoCommand val = model.buildAVString(avAll, testCommand);
		Assert.assertEquals ("Return value for av all off failed",expectedOut,val.avOutputStrings.firstElement());
	}

	public void testBuildAVAllOn() {
		ClientCommand testCommand = new ClientCommand("ALL","on",null,"","","","","");
		byte[] expectedOut = new byte[]{((byte)0xA4)};
		SignVideoCommand val = model.buildAVString(avAll, testCommand);
		Assert.assertEquals ("Return value for av all off failed",expectedOut,val.avOutputStrings.firstElement());
	}
	
	public void testBuildAVSrc() {
		ClientCommand testCommand = new ClientCommand("FRONT_AV","src",null,"DVD1","","","","");
		byte[] expectedOut = new byte[]{((byte)0x10)};
		SignVideoCommand val = model.buildAVString(avFrontRoom, testCommand);
		Assert.assertEquals ("Return value for src failed",expectedOut,val.avOutputStrings.firstElement());
		
		ClientCommand testCommand2 = new ClientCommand("FRONT_AV","src",null,"DVD2","","","","");
		byte[] expectedOut2 = new byte[]{((byte)0x11)};
		SignVideoCommand val2 = model.buildAVString(avFrontRoom, testCommand2);
		Assert.assertEquals ("Return value for src failed",expectedOut2,val2.avOutputStrings.firstElement());
				
		ClientCommand testCommand4 = new ClientCommand("FRONT_AV","src",null,"x","","","","");
		String expectedOut4 = "";
		SignVideoCommand val4 = model.buildAVString(avFrontRoom, testCommand4);
		Assert.assertEquals ("Return value for unknown src failed",true,val4.error);

	}
	

	public void testSrcCache() {
		ClientCommand testCommand = new ClientCommand("FRONT_AV","src",null,"DVD1","","","","");
		byte[] expectedOut = new byte[]{((byte)0x10)};
		SignVideoCommand val = model.buildAVString(avFrontRoom, testCommand);
		Assert.assertEquals ("Return value for src failed",expectedOut,val.avOutputStrings.firstElement());

		ClientCommand testCommandCache = new ClientCommand("FRONT_AV","src",null,"DVD1","","","","");
		SignVideoCommand valCache = model.buildAVString(avFrontRoom, testCommandCache);
		Assert.assertTrue ("Return value for cached src failed, the instruction was incorrectly returned",valCache.avOutputFlash.isEmpty());

	}
	

	public void testBuildAVSrcAll() {
		
		ClientCommand testCommand3 = new ClientCommand("ALL","src",null,"DVD2","","","","");
		Vector<byte[]> expectedOut = new Vector<byte[]>();
		expectedOut.add(new byte[]{((byte)0x11)});
		expectedOut.add(new byte[]{((byte)0x21)});
		expectedOut.add(new byte[]{((byte)0x31)});

		SignVideoCommand val3 = model.buildAVString(avAll, testCommand3);
		ListAssert.assertEquals("Return value for volume failed",expectedOut,val3.avOutputBytes);
	}
	
	
	/*
	 * preset
	 * src ; extra3="AV|VIDEO_ONLY|AUDIO_ONLY"
	 */

}
