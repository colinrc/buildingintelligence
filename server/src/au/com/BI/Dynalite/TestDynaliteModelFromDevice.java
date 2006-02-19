package au.com.BI.Dynalite;

import junit.framework.TestCase;
import au.com.BI.Flash.*;
import au.com.BI.Lights.*;
import au.com.BI.Util.*;
import junitx.framework.*;
import java.util.*;
import au.com.BI.ToggleSwitch.*;
import au.com.BI.IR.*;

public class TestDynaliteModelFromDevice extends TestCase {

	private Model model = null;
	LightFascade testA03C03 = null;
	LightFascade testA03C04 = null;
	LightFascade testA02C03 = null;
	LightFascade testA02C05 = null;
	LightFascade testA16C05 = null;
	ToggleSwitch b4box2 = null;

	ClientCommand a2C3off = null;
	ClientCommand channel01RampToSeconds = null;
	DynaliteHelper dynaliteHelper  = null;
	
	public TestDynaliteModelFromDevice(String arg0) {
		super(arg0);
	}

	protected void setUp() throws Exception {
		super.setUp();

		
		testA03C03 = new LightFascade( "A03C03", DeviceType.LIGHT_DYNALITE ,"A03C03","DYNALITE");
		testA03C03.setAreaCode("03");
		testA03C03.setKey("03");
		
		testA03C04 = new LightFascade("A03C04", DeviceType.LIGHT_DYNALITE ,"A03C04","DYNALITE");
		testA03C04.setAreaCode("03");
		testA03C04.setKey("04");

		testA02C03 = new LightFascade("A02C03", DeviceType.LIGHT_DYNALITE ,"A02C03","DYNALITE");
		testA02C03.setAreaCode("02");
		testA02C03.setKey("03");

		testA02C05 = new LightFascade("A02C05", DeviceType.LIGHT_DYNALITE ,"A02C05","DYNALITE");
		testA02C05.setAreaCode("02");
		testA02C05.setKey("05");
		
		testA16C05 = new LightFascade("A16C05", DeviceType.LIGHT_DYNALITE ,"A16C05","DYNALITE");
		testA16C05.setAreaCode("10");
		testA16C05.setKey("05");


		a2C3off = new ClientCommand("AREA02_CHANNEL03","off",null,"0","","","","");
		
		ToggleSwitch testB4box2 = new ToggleSwitch ("Button 4 Box2",DeviceType.CONTACT_CLOSURE,"SWITCH4_BOX02");
		testB4box2.setBox(2);
		testB4box2.setKey("04");

		IR testir7box6 = new IR ("IR 7 Box6",DeviceType.IR,"IR7_BOX06");
		testir7box6.setBox(6);
		testir7box6.setKey("07");
		
		
		model = new Model();
		dynaliteHelper = model.getDynaliteHelper();
		
		//ConfigHelper configHelper = model.getConfigHelper();
		model.addControlledItem("03",testA03C03,DeviceType.MONITORED);
		model.addControlledItem("04",testA03C04,DeviceType.MONITORED);
		model.addControlledItem("03",testA02C03,DeviceType.MONITORED);
		model.addControlledItem("05",testA02C05,DeviceType.MONITORED);		
		model.addControlledItem("05",testA16C05,DeviceType.MONITORED);		
		model.addControlledItem("04",testB4box2,DeviceType.INPUT);		
		model.addControlledItem("07",testir7box6,DeviceType.INPUT);	
	}

	protected void tearDown() throws Exception {
		super.tearDown();
	}



	public void testFindDevicesInArea() {
		List result = null;
		LinkedList testRes = new LinkedList();
		testRes.add(testA03C03);
		testRes.add(testA03C04);
		result = model.areaCodes.findDevicesInArea(3,true,0xff);
		ListAssert.assertEquals("Finding devices in area failed",testRes,result);
	}
	
	/*
	 * Test method for 'au.com.BI.Dynalite.Model.buildDynaliteRampToCommand(String, String, int, int, String, String)'
	 */
	public void testInterpretAreaOff() {
		byte ret1[] = new byte[]{(byte)0x1C,03,(byte)0x64,(byte)0x04,(byte)0x00,(byte)0x00,(byte)0xff,(byte)0x7a};
		InterpretResult result = new InterpretResult();
		LinkedList testRes = new LinkedList();
		DynaliteCommand a3C3off = new DynaliteCommand("CLIENT_SEND","off",null,"0","2","255","","");
		a3C3off.setDisplayName("A03C03");
		DynaliteCommand a3C4off = new DynaliteCommand("CLIENT_SEND","off",null,"0","2","255","","");
		a3C4off.setDisplayName("A03C04");
		testRes.add(a3C3off);
		testRes.add(a3C4off);
		model.interpretAreaOff(result, ret1);
		ListAssert.assertEquals("Interpretting dynalite area off failed",testRes,result.decoded);
	}
	
	public void testInterpretLinearPreset() {
		byte ret1[] = new byte[]{(byte)0x1C,06,(byte)0x09,(byte)0x65,(byte)0x00,(byte)0x00,(byte)0xff,(byte)0x00};
		dynaliteHelper.addChecksum(ret1);
		
		LightFascade testA06C00 = new LightFascade("A0AC00", DeviceType.LIGHT_DYNALITE ,"A0AC00","DYNALITE");
		testA06C00.setAreaCode("06");
		testA06C00.setKey("00");
		
		model.addControlledItem("00",testA06C00,DeviceType.MONITORED);		
		InterpretResult result = new InterpretResult();
		LinkedList testRes = new LinkedList();
		DynaliteCommand a10C0present = new DynaliteCommand("CLIENT_SEND","preset",null,"10","0","255","","");
		a10C0present.setDisplayName("A0AC00");
		testRes.add(a10C0present);
		model.interpretLinearPreset(result, ret1);
		ListAssert.assertEquals("Interpretting dynalite linear preset failed",testRes,result.decoded);
	}
	
	public void testInterpretRampUp() {
		byte ret1[] = new byte[]{(byte)0x1C,07,(byte)0xff,(byte)0x69,(byte)0x00,(byte)0x0,(byte)0xff,(byte)0x00};
		dynaliteHelper.addChecksum(ret1);
		
		LightFascade testA07C00 = new LightFascade("A0A700", DeviceType.LIGHT_DYNALITE ,"A07C00","DYNALITE");
		testA07C00.setAreaCode("07");
		testA07C00.setKey("00");
		
		model.addControlledItem("00",testA07C00,DeviceType.MONITORED);		
		InterpretResult result = new InterpretResult();
		LinkedList testRes = new LinkedList();
		DynaliteCommand a07C0ramp = new DynaliteCommand("CLIENT_SEND","on",null,"100","0","255","","");
		a07C0ramp.setDisplayName("A07C00");
		testRes.add(a07C0ramp);
		model.interpretRampUp(result, ret1);
		ListAssert.assertEquals("Interpretting dynalite linear preset failed",testRes,result.decoded);
	}
	
	public void testInterpretRampDown() {
		byte ret1[] = new byte[]{(byte)0x1C,03,(byte)0xff,(byte)0x68,(byte)0x00,(byte)0x0,(byte)0xff,(byte)0x00};
		dynaliteHelper.addChecksum(ret1);
		
		LightFascade testA03C00 = new LightFascade("A0A300", DeviceType.LIGHT_DYNALITE ,"A03C00","DYNALITE");
		testA03C00.setAreaCode("03");
		testA03C00.setKey("00");
		
		model.addControlledItem("00",testA03C00,DeviceType.MONITORED);		
		InterpretResult result = new InterpretResult();
		LinkedList testRes = new LinkedList();
		DynaliteCommand a03C0ramp = new DynaliteCommand("CLIENT_SEND","off",null,"0","0","255","","");
		a03C0ramp.setDisplayName("A03C00");
		testRes.add(a03C0ramp);
		model.interpretRampDown(result, ret1);
		ListAssert.assertEquals("Interpretting dynalite linear preset failed",testRes,result.decoded);
	}
	
	public void testInterpretClassicPreset() {
		byte ret1[] = new byte[]{(byte)0x1C,02,(byte)0x0,(byte)0x03,(byte)0x00,(byte)0x00,(byte)0xff,(byte)0x00};
		dynaliteHelper.addChecksum(ret1);
		
		LightFascade testA02C00 = new LightFascade("A02C00", DeviceType.LIGHT_DYNALITE ,"A02C00","DYNALITE");
		testA02C00.setAreaCode("02");
		testA02C00.setKey("00");
		
		model.addControlledItem("00",testA02C00,DeviceType.MONITORED);		
		InterpretResult result = new InterpretResult();
		LinkedList testRes = new LinkedList();
		DynaliteCommand a2C0preset = new DynaliteCommand("CLIENT_SEND","preset",null,"4","0","255","","");
		a2C0preset.setDisplayName("A02C00");
		testRes.add(a2C0preset);
		model.interpretClassicPreset(result, ret1);
		ListAssert.assertEquals("Interpretting dynalite classic preset failed",testRes,result.decoded);
	}
	
	
	public void testInterpretIR() {
		byte ret1[] = new byte[]{(byte)0x5C,(byte)0xa7,(byte)0x06,(byte)0x49,(byte)0x07,(byte)0x00,(byte)0x00,(byte)0xa7};
		InterpretResult result = new InterpretResult();
		LinkedList testRes = new LinkedList();
		DynaliteCommand ir7box6 = new DynaliteCommand("CLIENT_SEND","off",null,"0","0","255","","");
		ir7box6.setDisplayName("IR7_BOX06");
		testRes.add(ir7box6);
		model.interpretIR(result, ret1);
		ListAssert.assertEquals("Interpretting IR failed",testRes,result.decoded);
	}

	public void testInterpretSwitch() {
		byte ret1[] = new byte[]{(byte)0x5C,(byte)0xa7,(byte)0x02,(byte)0x43,(byte)0x04,(byte)0x00,(byte)0xff,(byte)0xb5};
		InterpretResult result = new InterpretResult();
		LinkedList testRes = new LinkedList();
		DynaliteCommand b4box2 = new DynaliteCommand("CLIENT_SEND","on",null,"100","0","255","","");
		b4box2.setDisplayName("SWITCH4_BOX02");
		testRes.add(b4box2);
		model.interpretSwitch(result, ret1);
		ListAssert.assertEquals("Interpretting switch failed",testRes,result.decoded);
	}
	
	public void testInterpretFadeChannelOrArea() {
		byte ret1[] = new byte[]{(byte)0x1C,02,(byte)0x02,(byte)0x71,(byte)0x82,(byte)0x32,(byte)0xff,(byte)0x00};
		dynaliteHelper.addChecksum(ret1);
		InterpretResult result = new InterpretResult();
		LinkedList testRes = new LinkedList();
		DynaliteCommand a2c3_5 = new DynaliteCommand("CLIENT_SEND","on",null,"50","5","255","","");
		a2c3_5.setDisplayName("A02C03");
		testRes.add(a2c3_5);
		model.interpretFadeChannelOrArea(result, ret1);
		ListAssert.assertEquals("Interpretting fade channel or area",testRes,result.decoded);

		byte ret2[] = new byte[]{(byte)0x1C,02,(byte)0x02,(byte)0x72,(byte)0x82,(byte)0x32,(byte)0xff,(byte)0x00};
		dynaliteHelper.addChecksum(ret2);
		InterpretResult result2 = new InterpretResult();
		LinkedList testRes2 = new LinkedList();
		DynaliteCommand a2c3_50 = new DynaliteCommand("CLIENT_SEND","on",null,"50","50","255","","");
		a2c3_50.setDisplayName("A02C03");
		testRes2.add(a2c3_50);
		model.interpretFadeChannelOrArea(result2, ret2);
		ListAssert.assertEquals("Interpretting fade channel or area",testRes2,result2.decoded);

		byte ret3[] = new byte[]{(byte)0x1C,02,(byte)0x02,(byte)0x73,(byte)0x82,(byte)0x0f,(byte)0xff,(byte)0xdd};
		dynaliteHelper.addChecksum(ret3);
		InterpretResult result3 = new InterpretResult();
		LinkedList testRes3 = new LinkedList();
		DynaliteCommand a2c3_15m = new DynaliteCommand("CLIENT_SEND","on",null,"50","900","255","","");
		a2c3_15m.setDisplayName("A02C03");
		testRes3.add(a2c3_15m);
		model.interpretFadeChannelOrArea(result3, ret3);
		ListAssert.assertEquals("Interpretting fade channel or area",testRes3,result3.decoded);

	}
	
	public void testInterpretClassicPresetOffset() {
		LinkedList testRes = new LinkedList();
		DynaliteCommand a2cc00 = new DynaliteCommand("CLIENT_SEND","offset",null,"15","","255","","");
		a2cc00.setDisplayName("A2CC00");
		testRes.add(a2cc00);
		
		LightFascade testA2CC00 = new LightFascade("A2CC00", DeviceType.LIGHT_DYNALITE ,"A2CC00","DYNALITE");
		testA2CC00.setAreaCode("2c");
		testA2CC00.setKey("00");
		model.addControlledItem("00",testA2CC00,DeviceType.MONITORED);	

		byte ret1[] = new byte[]{(byte)0x1C,(byte)0x2c,(byte)0x8f,(byte)0x64,(byte)0x00,(byte)0x00,(byte)0xff,(byte)0xc6};
		InterpretResult result = new InterpretResult();
		model.interpretClassicPresetOffset(result,ret1);
		assertEquals("Interpretting dynalite preset offset for area 44",15, model.getOffset((byte)44));
		
		byte ret2[] = new byte[]{(byte)0x1C,(byte)0x2c,(byte)0x80,(byte)0x64,(byte)0x00,(byte)0x00,(byte)0xff,(byte)0xc6};
		dynaliteHelper.addChecksum(ret2);
		InterpretResult result2 = new InterpretResult();
		model.interpretClassicPresetOffset(result2,ret2);
		assertEquals("Interpretting dynalite preset clear",0, model.getOffset((byte)44));

		ListAssert.assertEquals("Interpretting offset for area 44",testRes,result.decoded);
	}
	
	public void testInterpretChannelLevel() {
		byte ret1[] = new byte[]{(byte)0x1C,(byte)0x10,(byte)0x04,(byte)0x60,(byte)0x6e,(byte)0x6e,(byte)0xff,(byte)0x95};
		InterpretResult result = new InterpretResult();
		LinkedList testRes = new LinkedList();
		DynaliteCommand a16C5level = new DynaliteCommand("CLIENT_SEND","on",null,"58","0","255","","");
		a16C5level.setDisplayName("A16C05");
		testRes.add(a16C5level);
		model.interpretChannelLevel(result, ret1);
		ListAssert.assertEquals("Interpretting dynalite level failed",testRes,result.decoded);
	}
		
	public void testInterpretClassicFadeAreaLevel() {
		LightFascade testA4C00 = new LightFascade("A04C00", DeviceType.LIGHT_DYNALITE ,"A04C00","DYNALITE");
		testA4C00.setAreaCode("04");
		testA4C00.setKey("00");
		model.addControlledItem("00",testA4C00,DeviceType.MONITORED);	
		
		byte ret1[] = new byte[]{(byte)0x1C,(byte)0x04,(byte)0x82,(byte)0x79,(byte)0x64,(byte)0x0,(byte)0xff,(byte)0x82};
		InterpretResult result = new InterpretResult();
		LinkedList testRes = new LinkedList();
		DynaliteCommand a4level = new DynaliteCommand("CLIENT_SEND","on",null,"50","2","255","","");
		a4level.setDisplayName("A04C00");
		testRes.add(a4level);
		model.interpretClassicAreaLevel(result, ret1);
		ListAssert.assertEquals("Interpretting dynalite level failed",testRes,result.decoded);
	}
	public void testInterpretClassicChannelLevel() {
		LightFascade testA06C09 = new LightFascade("A06C09", DeviceType.LIGHT_DYNALITE ,"A06C09","DYNALITE");
		testA06C09.setAreaCode("06");
		testA06C09.setKey("09");
		model.addControlledItem("09",testA06C09,DeviceType.MONITORED);	

		LightFascade testA12C14 = new LightFascade("A0CC0E", DeviceType.LIGHT_DYNALITE ,"A0CC0E","DYNALITE");
		testA12C14.setAreaCode("0C");
		testA12C14.setKey("0E");
		model.addControlledItem("0E",testA12C14,DeviceType.MONITORED);	
		
		byte ret2[] = new byte[]{(byte)0x1C,(byte)0x0c,(byte)0xe6,(byte)0x81,(byte)0x02,(byte)0x4b,(byte)0xff,(byte)0x25};
		InterpretResult result2 = new InterpretResult();
		LinkedList testRes2 = new LinkedList();
		DynaliteCommand a12c14level = new DynaliteCommand("CLIENT_SEND","on",null,"10","1","255","","");
		a12c14level.setDisplayName("A0CC0E");
		testRes2.add(a12c14level);
		model.interpretClassicChannelLevel(result2, ret2);
		ListAssert.assertEquals("Interpretting dynalite channel level failed",testRes2,result2.decoded);

	}
	
	
}
