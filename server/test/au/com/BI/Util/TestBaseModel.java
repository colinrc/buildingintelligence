package au.com.BI.Util;

import junit.framework.TestCase;

public class TestBaseModel extends TestCase {

	BaseModel testModel = null;
	
	protected void setUp() throws Exception {
		super.setUp();
		testModel = new BaseModel();
	}
	
	/*
	 * Test method for 'au.com.BI.Util.BaseModel.formatKey(String)'
	 */
	public void testFormatKeyHexHex2Padding() {
		testModel.setConfigKeysInDecimal(false);
		testModel.setDeviceKeysDecimal(false);
		testModel.setPadding(2);
		String result = testModel.formatKey("a");
		assertEquals ("Format Key Hex Hex 2 padding failed","0A",result);
	}

	public void testFormatKeyHexHex1Padding() {
		testModel.setConfigKeysInDecimal(false);
		testModel.setDeviceKeysDecimal(false);
		testModel.setPadding(1);
		String result = testModel.formatKey("a");
		assertEquals ("Format Key Hex Hex 1 padding failed","A",result);
	}


	public void testFormatKeyDecHex2Padding() {
		testModel.setConfigKeysInDecimal(true);
		testModel.setDeviceKeysDecimal(false);
		testModel.setPadding(2);
		String result = testModel.formatKey("10");
		assertEquals ("Format Key Dec Hex 2 padding failed","0A",result);
	}

	public void testFormatKeyDecDec3Padding() {
		testModel.setConfigKeysInDecimal(true);
		testModel.setDeviceKeysDecimal(true);
		testModel.setPadding(3);
		String result = testModel.formatKey("16");
		assertEquals ("Format Key Dec Hex 2 padding failed","016",result);
	}

}
