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
import junitx.framework.ArrayAssert;

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
		model.setPadding (1); 
		
	}

	protected void tearDown() throws Exception {
		super.tearDown();
	}

	public void testBuildAVAllOff() {
		ClientCommand testCommand = new ClientCommand("ALL","off",null,"","","","","");
		byte[] expectedOut = new byte[]{((byte)0xA5)};
		SignVideoCommand val = model.buildAVString(avAll, testCommand);
		ArrayAssert.assertEquals ("Return value for av all off failed",expectedOut,val.avOutputBytes.firstElement());
	}

	public void testBuildAVAllOn() {
		ClientCommand testCommand = new ClientCommand("ALL","on",null,"","","","","");
		byte[] expectedOut = new byte[]{((byte)0xA4)};
		SignVideoCommand val = model.buildAVString(avAll, testCommand);
		ArrayAssert.assertEquals ("Return value for av all off failed",expectedOut,val.avOutputBytes.firstElement());
	}
	
	public void testBuildAVSrc() {
		ClientCommand testCommand = new ClientCommand("FRONT_AV","src",null,"DVD1","","","","");
		byte[] expectedOut = new byte[]{((byte)0x10)};
		SignVideoCommand val = model.buildAVString(avFrontRoom, testCommand);
		ArrayAssert.assertEquals ("Return value for src failed",expectedOut,val.avOutputBytes.firstElement());
		
		ClientCommand testCommand2 = new ClientCommand("FRONT_AV","src",null,"DVD2","","","","");
		byte[] expectedOut2 = new byte[]{((byte)0x11)};
		SignVideoCommand val2 = model.buildAVString(avFrontRoom, testCommand2);
		ArrayAssert.assertEquals ("Return value for src failed",expectedOut2,val2.avOutputBytes.firstElement());
				
		ClientCommand testCommand4 = new ClientCommand("FRONT_AV","src",null,"x","","","","");
		SignVideoCommand val4 = model.buildAVString(avFrontRoom, testCommand4);
		Assert.assertEquals ("Return value for unknown src failed",true,val4.error);

		ClientCommand testCommand5 = new ClientCommand("KITCHEN_AV","src",null,"DVD1","","AUDIO_ONLY","","");
		SignVideoCommand val5 = model.buildAVString(this.kitchenAV, testCommand5);
		byte[] expectedOut5_audio_switch = new byte[]{((byte)0xA2)};
		byte[] expectedOut5_src_switch = new byte[]{((byte)0x20)};
		byte[] expectedOut5_av_switch = new byte[]{((byte)0xA0)};
		Vector <byte[]>expectedOut5 = new Vector<byte []>();
		expectedOut5.add(expectedOut5_audio_switch);
		expectedOut5.add(expectedOut5_src_switch);
		expectedOut5.add(expectedOut5_av_switch);
		
		ListAssert.assertEquals("Return value for audio only src failed",val5.avOutputBytes,expectedOut5);

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
