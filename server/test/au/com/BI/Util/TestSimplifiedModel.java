package au.com.BI.Util;

import java.util.HashMap;

import au.com.BI.Command.Command;
import au.com.BI.Command.CommandInterface;
import au.com.BI.Comms.CommsCommand;
import au.com.BI.CustomConnect.*;
import au.com.BI.Device.DeviceType;
import junit.framework.TestCase;

public class TestSimplifiedModel extends TestCase {

	SimplifiedModel testModel = null;
	
	protected void setUp() throws Exception {
		super.setUp();
		testModel = new SimplifiedModel();
		testModel.setName("Test model");
	}
	
	/*
	 * Test method for 'au.com.BI.Util.BaseModel.formatKey(String)'
	 */
	public void testFormatKeyHexHex2Padding() {
		testModel.setConfigKeysInDecimal(false);
		testModel.setDeviceKeysDecimal(false);
		testModel.setPadding(2);
		String result = testModel.formatKey("a",null);
		assertEquals ("Format Key Hex Hex 2 padding failed","0A",result);
	}

	public void testFormatKeyHexHex1Padding() {
		testModel.setConfigKeysInDecimal(false);
		testModel.setDeviceKeysDecimal(false);
		testModel.setPadding(1);
		String result = testModel.formatKey("a",null);
		assertEquals ("Format Key Hex Hex 1 padding failed","A",result);
	}


	public void testFormatKeyDecHex2Padding() {
		testModel.setConfigKeysInDecimal(true);
		testModel.setDeviceKeysDecimal(false);
		testModel.setPadding(2);
		String result = testModel.formatKey("10",null);
		assertEquals ("Format Key Dec Hex 2 padding failed","0A",result);
	}

	public void testFormatKeyDecDec3Padding() {
		testModel.setConfigKeysInDecimal(true);
		testModel.setDeviceKeysDecimal(true);
		testModel.setPadding(3);
		String result = testModel.formatKey("16",null);
		assertEquals ("Format Key Dec Hex 2 padding failed","016",result);
	}
	
}
