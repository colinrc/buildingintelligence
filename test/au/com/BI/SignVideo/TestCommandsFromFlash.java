package au.com.BI.SignVideo;

import java.util.HashMap;
import java.util.Vector;

import au.com.BI.Command.CommandInterface;
import au.com.BI.AV.*;
import au.com.BI.Command.ReturnWrapper;
import au.com.BI.Device.DeviceType;
import au.com.BI.Flash.ClientCommand;
import au.com.BI.SignVideo.Model;
import au.com.BI.Util.DeviceModel;
import au.com.BI.Util.MessageDirection;

import static org.junit.Assert.*;
import org.junit.Before;
import org.junit.Test;

import junitx.framework.ArrayAssert;
import junitx.framework.ListAssert;
import au.com.BI.junitx.ListOfArrayAssert;

public class TestCommandsFromFlash {
	private Model model = null;
	AV avFrontRoom = null;
	AV avAll = null;
	AV kitchenAV = null;
	AV studyAV = null;
	
	@Before
	public void setUp() throws Exception {
		model = new Model();
	
		avAll = new AV ("All",DeviceType.AUDIO);
		avAll.setKey("0");
		avAll.setOutputKey("ALL");
		
		avFrontRoom = new AV ("Front AV",DeviceType.AUDIO);
		avFrontRoom.setKey("1");
		avFrontRoom.setOutputKey("FRONT_AV");

		kitchenAV = new AV ("Kitchen AV",DeviceType.AUDIO);
		kitchenAV.setKey("2");
		kitchenAV.setOutputKey("KITCHEN_AV");


		studyAV = new AV ("Study AV",DeviceType.AUDIO);
		studyAV.setKey("3");
		studyAV.setOutputKey("STUDY_AV");
		
		model.addControlledItem("FRONT_AV",avFrontRoom,MessageDirection.FROM_FLASH);
		model.addControlledItem("ALL",avAll,MessageDirection.FROM_FLASH);
		model.addControlledItem("KITCHEN_AV",kitchenAV,MessageDirection.FROM_FLASH);
		model.addControlledItem("STUDY_AV",studyAV,MessageDirection.FROM_FLASH);
		
		model.addControlledItem(avFrontRoom.getKey(),avFrontRoom,MessageDirection.FROM_HARDWARE);
		model.addControlledItem(avAll.getKey(),avAll,MessageDirection.FROM_HARDWARE);
		model.addControlledItem(kitchenAV.getKey(),kitchenAV,MessageDirection.FROM_HARDWARE);
		model.addControlledItem(studyAV.getKey(),studyAV,MessageDirection.FROM_HARDWARE);
		
		HashMap<String, String> map = new HashMap<String,String> (40);
		
		map.put("DVD1", "1");
		map.put("DVD2", "2");
		map.put("digital","3");
		map.put("tv", "4");
		
		model.setCatalogueDefs("Sign AV Inputs",map);
		
		model.setParameter("AV_INPUTS", "Sign AV Inputs", DeviceModel.MAIN_DEVICE_GROUP);
		model.setupParameterBlocks ();
		model.setPadding (1); 
		
	}

	@Test
	public void testBuildAVAllOff() {
		ClientCommand testCommand = new ClientCommand("ALL","off",null,"","","","","");
		byte[] expectedOut = new byte[]{((byte)0xA5)};
		ReturnWrapper val = model.buildAVString(avAll, testCommand);
		ArrayAssert.assertEquals ("Return value for av all off failed",expectedOut,val.getCommOutputBytes().firstElement());

		
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
		
		ListAssert.assertEquals ("Return value for all off failed",val.getOutputFlash(),expectedOutFlash);
	}

	@Test
	public void testBuildAVAllOn() {
		ClientCommand testCommand = new ClientCommand("ALL","on",null,"","","","","");
		byte[] expectedOut = new byte[]{((byte)0xA4)};
		ReturnWrapper val = model.buildAVString(avAll, testCommand);
		ArrayAssert.assertEquals ("Return value for av all off failed",expectedOut,val.getCommOutputBytes().firstElement());
		
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
		
		ListAssert.assertEquals ("Return value for all on failed",val.getOutputFlash(),expectedOutFlash);
	}
	
	@Test
	public void testBuildAVSrc() {
		ClientCommand testCommand = new ClientCommand("FRONT_AV","src",null,"DVD1","","","","");
		byte[] expectedOut = new byte[]{((byte)0x10)};
		ReturnWrapper val = model.buildAVString(avFrontRoom, testCommand);
		ArrayAssert.assertEquals ("Return value for src failed",expectedOut,val.getCommOutputBytes().firstElement());
		
		ClientCommand testCommand2 = new ClientCommand("FRONT_AV","src",null,"DVD2","","","","");
		byte[] expectedOut2 = new byte[]{((byte)0x11)};
		ReturnWrapper val2 = model.buildAVString(avFrontRoom, testCommand2);
		ArrayAssert.assertEquals ("Return value for src failed",expectedOut2,val2.getCommOutputBytes().firstElement());
				
		ClientCommand testCommand4 = new ClientCommand("FRONT_AV","src",null,"x","","","","");
		ReturnWrapper val4 = model.buildAVString(avFrontRoom, testCommand4);
		assertEquals ("Return value for unknown src failed",true,val4.isError());

		ClientCommand testCommand5 = new ClientCommand("KITCHEN_AV","src",null,"DVD1","","AUDIO_ONLY","","");
		ReturnWrapper val5 = model.buildAVString(this.kitchenAV, testCommand5);
		byte[] expectedOut5_audio_switch = new byte[]{((byte)0xA2)};
		byte[] expectedOut5_src_switch = new byte[]{((byte)0x20)};
		byte[] expectedOut5_av_switch = new byte[]{((byte)0xA0)};
		Vector <byte[]>expectedOut5 = new Vector<byte []>();
		expectedOut5.add(expectedOut5_audio_switch);
		expectedOut5.add(expectedOut5_src_switch);
		expectedOut5.add(expectedOut5_av_switch);
		
		ListOfArrayAssert.assertByteEquals("Return value for audio only src failed",val5.getCommOutputBytes(),expectedOut5);

	}
	
	@Test
	public void testBuildAVPreset() {
		ClientCommand testCommand = new ClientCommand("ALL","preset",null,"2","","","","");

		Vector <byte[]>expectedOutVec = new Vector<byte []>();
		expectedOutVec.add(new byte[]{((byte)0x99)});
		expectedOutVec.add(new byte[]{((byte)0xA3)});
		
		ReturnWrapper val = model.buildAVString(avFrontRoom, testCommand);
		ListOfArrayAssert.assertByteEquals("Return value for av preset failed",val.getCommOutputBytes(),expectedOutVec);	
	}

	@Test
	public void testBuildAVPresetSet() {
		ClientCommand testCommand = new ClientCommand("ALL","preset_set",null,"2","","","","");
		byte[] expectedOut = new byte[]{((byte)0x91)};
		ReturnWrapper val = model.buildAVString(avFrontRoom, testCommand);
		ArrayAssert.assertEquals ("Return value for preset store failed",expectedOut,val.getCommOutputBytes().firstElement());
	}
	
	@Test
	public void testBuildAVSrcAll() {
		
		ClientCommand testCommand3 = new ClientCommand("ALL","src",null,"DVD2","","","","");
		Vector<byte[]> expectedOut = new Vector<byte[]>();
		expectedOut.add(new byte[]{((byte)0x11)});
		expectedOut.add(new byte[]{((byte)0x21)});
		expectedOut.add(new byte[]{((byte)0x31)});
		
		Vector <CommandInterface>expectedOutFlash = new Vector<CommandInterface>();
		
		AVCommand testCommand1 = new AVCommand("CLIENT_SEND","src",null,"DVD2");
		testCommand1.setDisplayName("FRONT_AV");
		expectedOutFlash.add(testCommand1);
		
		AVCommand testCommand2 = new AVCommand("CLIENT_SEND","src",null,"DVD2");
		testCommand2.setDisplayName("STUDY_AV");
		expectedOutFlash.add(testCommand2);
		
		AVCommand testCommand4 = new AVCommand("CLIENT_SEND","src",null,"DVD2");
		testCommand4.setDisplayName("KITCHEN_AV");
		expectedOutFlash.add(testCommand4);

		ReturnWrapper val3 = model.buildAVString(avAll, testCommand3);
		ListOfArrayAssert.assertByteEquals("Return value for src all failed",expectedOut,val3.getCommOutputBytes());
		
		ListAssert.assertEquals ("Return value for interpret failed",val3.getOutputFlash(),expectedOutFlash);
	}
	
	
	/*
	 * preset
	 * src ; extra3="AV|VIDEO_ONLY|AUDIO_ONLY"
	 * off
	 * on
	 */

}
