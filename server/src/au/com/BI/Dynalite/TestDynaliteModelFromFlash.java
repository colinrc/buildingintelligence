package au.com.BI.Dynalite;

import junit.framework.TestCase;
import au.com.BI.Flash.*;
import au.com.BI.Lights.*;
import au.com.BI.Util.*;
import junitx.framework.*;

public class TestDynaliteModelFromFlash extends TestCase {

	private Model model = null;
	LightFascade testWithChannelA02C03 = null;
	LightFascade testAreaOnly = null;

	ClientCommand area5Sec = null;
	ClientCommand area50Sec = null;
	ClientCommand area15Min = null;
	ClientCommand channel01RampToSeconds = null;
	private DynaliteHelper dynaliteHelper = null;
	
	public TestDynaliteModelFromFlash(String arg0) {
		super(arg0);
	}

	protected void setUp() throws Exception {
		super.setUp();

		
		testWithChannelA02C03 = new LightFascade( "Channel Plus Area", DeviceType.LIGHT_DYNALITE ,"CHANNEL01_PLUS_AREA01","DYNALITE");
		testWithChannelA02C03.setAreaCode("02");
		testWithChannelA02C03.setKey("03");
		
		testAreaOnly = new LightFascade("Area Only", DeviceType.LIGHT_DYNALITE_AREA ,"AREA03_ONLY","DYNALITE");
		//testAreaOnly.setAreaCode("03");
		testAreaOnly.setKey("03");
		
		area5Sec = new ClientCommand("AREA03_CHANNEL02","on",null,"50","5","","","");
		area50Sec = new ClientCommand("AREA03_CHANNEL02","on",null,"50","50","","","");
		area15Min = new ClientCommand("AREA03_CHANNEL02","on",null,"50","15m","","","");
		model = new Model();
		//ConfigHelper configHelper = model.getConfigHelper();
		model.addControlledItem("03",testWithChannelA02C03,DeviceType.MONITORED);
		model.addControlledItem("03",testAreaOnly,DeviceType.MONITORED);
		dynaliteHelper = model.getDynaliteHelper();
	}

	protected void tearDown() throws Exception {
		super.tearDown();
	}


	/*
	 * Test method for 'au.com.BI.Dynalite.Model.buildDynaliteRampToCommand(String, String, int, int, String, String)'
	 */
	public void testDynaliteLinearFadeArea() {
		byte ret1[] = new byte[]{(byte)0x1C,02,2,(byte)0x71,(byte)0x82,(byte)0x32,(byte)0xff,(byte)0xbc};
		byte ret2[] = new byte[]{(byte)0x1C,02,2,(byte)0x72,(byte)0x82,(byte)0x32,(byte)0xff,(byte)0xbb};
		byte ret3[] = new byte[]{(byte)0x1C,02,2,(byte)0x73,(byte)0x82,(byte)0x0f,(byte)0xff,(byte)0xdd};
		
		//DynaliteOutput result = model.buildDynaliteResult(testWithChannelA02C03,area5Sec);
		//ArrayAssert.assertEquals ("Return value for area fade to 50% over 5 seconds failed",ret1,result.outputCodes);
		
			model.protocol = DynaliteDevice.Linear;
			DynaliteOutput result2 = model.buildDynaliteResult(testWithChannelA02C03,area50Sec);
			ArrayAssert.assertEquals("Return value for area fade to 50% over 50 seconds failed",ret2,result2.outputCodes);
	
			DynaliteOutput result3 = model.buildDynaliteResult(testWithChannelA02C03,area15Min);
			ArrayAssert.assertEquals ("Return value for area fade over 15 minutes failed",ret3,result3.outputCodes);

			
	}
	

	public void testDynaliteClassicFadeArea() {
		byte ret1[] = new byte[]{(byte)0x1C,04,(byte)0x82,(byte)0x79,(byte)0x64,(byte)0x00,(byte)0xff,(byte)0x82};
	
		model.protocol = DynaliteDevice.Classic;
		ClientCommand area2Sec = new ClientCommand("AREA04_CHANNEL00","on",null,"50","2","255","","");
		
		LightFascade testAreaOnly = new LightFascade("Area Only", DeviceType.LIGHT_DYNALITE ,"AREA04_CHANNEL00","DYNALITE");
		testAreaOnly.setAreaCode("04");
		testAreaOnly.setKey("00");
		

		DynaliteOutput result1 = model.buildDynaliteResult(testAreaOnly,area2Sec);
		ArrayAssert.assertEquals("Return value for area fade to 50% over 2 seconds failed",ret1,result1.outputCodes);
	}
	
	public void testDynaliteLevelRequestCommand() {
		byte ret1[] = new byte[]{(byte)0x1C,02,4,(byte)0x61,0,0x0,(byte)0xff,(byte)0x7e};

		DynaliteOutput result1 = model.buildDynaliteLevelRequestCommand("2",5,"",255);
		ArrayAssert.assertEquals ("Build level request failed",ret1,result1.outputCodes);
		
		DynaliteOutput result2 = model.buildDynaliteLevelRequestCommand("21h",5,"",255);
		assertEquals ("Level request area parsing failed",true,result2.isError);
	}

	public void testDynaliteLinearPreset() {
		byte ret1[] = new byte[]{(byte)0x1C,06,0x09,0x65,0x64,0,(byte)0xff,(byte)0x0d};

		DynaliteOutput result1 = model.buildDynaliteLinearPresetCommand("6","10","2",(byte)0xff);
		ArrayAssert.assertEquals ("Build set area preset failed. Area 6, preset 10, rate 2 s",ret1,result1.outputCodes);
		
	}

	public void testDynaliteClassicPreset() {
		byte ret1[] = new byte[]{(byte)0x1C,02,0x64,0x03,0x0,0,(byte)0xff,(byte)0x7c};

		DynaliteOutput result1 = model.buildDynaliteClassicPresetCommand("2","4","2",(byte)0xff);
		ArrayAssert.assertEquals ("Build set area preset failed. Area 2, preset 4, rate 2 s",ret1,result1.outputCodes);

		byte ret2[] = new byte[]{(byte)0x1C,02,0x30,0x0a,0x75,0x02,(byte)0xff,(byte)0};
		dynaliteHelper.addChecksum (ret2);

		DynaliteOutput result2 = model.buildDynaliteClassicPresetCommand("2","21","10m",(byte)0xff);
		ArrayAssert.assertEquals ("Build set area preset failed. Area 2, preset 21, rate 10 mins",ret2,result2.outputCodes);

	}
	
	public void testFindSingleDevice () {
		DynaliteDevice dev = model.findSingleDevice(DynaliteHelper.Light,2,3,false);
		assertEquals ("Find Single Device found incorrect device",dev,testWithChannelA02C03);

		DynaliteDevice dev4 = model.findSingleDevice(DynaliteHelper.Light,2,2,true);
		assertEquals ("Find Single Device found incorrect device",dev4,testWithChannelA02C03);

		DynaliteDevice dev2 = model.findSingleDevice(DynaliteHelper.Light,3,0,false);
		assertEquals ("Find Single Device found incorrect device",dev2,testAreaOnly);

		DynaliteDevice dev3 = model.findSingleDevice(DynaliteHelper.Light,1,3,false);
		assertEquals ("Find Single Device incorrectly found a device",dev3,null);
		
	}
		
	public void testDynaliteLinkArea() {
		byte ret1[] = new byte[]{(byte)0x1C,04,(byte)0x80,0x20,0x0,0,(byte)0xff,(byte)0xc0};
		dynaliteHelper.addChecksum (ret1);
		LightFascade testAreaOnly = new LightFascade("Area Only", DeviceType.LIGHT_DYNALITE_AREA ,"Area04","DYNALITE");
		testAreaOnly.setKey("04");
		testAreaOnly.setBLA("04");
		model.addControlledItem("04",testAreaOnly,DeviceType.MONITORED);
		
		DynaliteOutput result1 = model.buildLinkToCommand("04", "1","255", true);
		ArrayAssert.assertEquals ("Build linek area failed.",ret1,result1.outputCodes);
		
	}
	
	public void testDynaliteUnlinkArea() {
		byte ret1[] = new byte[]{(byte)0x1C,04,(byte)0x80,0x21,0x0,0,(byte)0xff,(byte)0x40};

		LightFascade testAreaOnly = new LightFascade("Area Only", DeviceType.LIGHT_DYNALITE_AREA ,"Area04","DYNALITE");
		testAreaOnly.setKey("04");
		testAreaOnly.setBLA("04");
		model.addControlledItem("04",testAreaOnly,DeviceType.MONITORED);
		
		DynaliteOutput result1 = model.buildLinkToCommand("04", "1","255", false);
		ArrayAssert.assertEquals ("Build linek area failed.",ret1,result1.outputCodes);
		
	}
}
