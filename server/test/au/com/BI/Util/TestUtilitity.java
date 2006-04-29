package au.com.BI.Util;

import junit.framework.TestCase;

public class TestUtilitity extends TestCase {

	protected void setUp() throws Exception {
		super.setUp();
	}

	/*
	 * Test method for 'au.com.BI.Util.Utility.parseString(String)'
	 */
	public void testParseString() {
		String toTest = "abc#0aef";
		String result= Utility.parseString(toTest);
		assertEquals (result,"abc\nef");
	}

	/*
	 * Test method for 'au.com.BI.Util.Utility.parseBytesForPrint(byte[])'
	 */
	public void testParseBytesForPrint() {
		byte toTest[] = new byte[] {'a','b','c','\n','e','f'};
		String result = Utility.parseBytesForPrint(toTest);
		assertEquals (result,"abc#0aef");
	}


	/*
	 * Test method for 'au.com.BI.Util.Utility.padString(String)'
	 */
	public void testPadString() {
		assertEquals (Utility.padString("1"),"01");		
		assertEquals (Utility.padString(""),"00");
		assertEquals (Utility.padString(null),"00");
		assertEquals (Utility.padString("1234"),"34");
		assertEquals (Utility.padString("21"),"21");
	}

	/*
	 * Test method for 'au.com.BI.Util.Utility.padString(String)'
	 */
	public void testPadStringNplaces() {
		assertEquals (Utility.padString("",3),"000");		
		assertEquals (Utility.padString("1",3),"001");
		assertEquals (Utility.padString(null,4),"0000");
		assertEquals (Utility.padString("1234",2),"34");
		assertEquals (Utility.padString("21",4),"0021");
	}

	/*
	 * Test method for 'au.com.BI.Util.Utility.padString(String)'
	 */
	public void testPadStringToHex() {
		assertEquals (Utility.padStringTohex(1),"01");		
		assertEquals (Utility.padStringTohex(255),"FF");		
		assertEquals (Utility.padStringTohex(14),"0E");		
	}
	
	public void testScaleFromFlash() {
		assertEquals (12,Utility.scaleFromFlash("100",-12,12,false));
		assertEquals (-12,Utility.scaleFromFlash("0",-12,12,false));
		assertEquals (0,Utility.scaleFromFlash("50",-12,12,false));
		assertEquals (12,Utility.scaleFromFlash("0",-12,12,true));
		assertEquals (-12,Utility.scaleFromFlash("100",-12,12,true));
	}
}
