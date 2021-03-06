package au.com.BI.Util;

import static org.junit.Assert.*;
import org.junit.Test;

public class TestUtilitity {
	
	@Test
	public void testParseString() {
		String toTest = "abc#0aef";
		String result= Utility.parseString(toTest);
		assertEquals (result,"abc\nef");
	}

	@Test
	public void testParseBytesForPrint() {
		byte toTest[] = new byte[] {'a','b','c','\n','e','f'};
		String result = Utility.parseBytesForPrint(toTest);
		assertEquals (result,"abc#0aef");
	}

	@Test
	public void testPadString() {
		assertEquals (Utility.padString("1"),"01");		
		assertEquals (Utility.padString(""),"00");
		assertEquals (Utility.padString(null),"00");
		assertEquals (Utility.padString("1234"),"34");
		assertEquals (Utility.padString("21"),"21");
	}

	@Test
	public void testPadStringNplaces() {
		assertEquals (Utility.padString("",3),"000");		
		assertEquals (Utility.padString("1",3),"001");
		assertEquals (Utility.padString(null,4),"0000");
		assertEquals (Utility.padString("1234",2),"34");
		assertEquals (Utility.padString("21",4),"0021");
	}

	@Test
	public void testPadStringToHex() {
		assertEquals (Utility.padStringTohex(1),"01");		
		assertEquals (Utility.padStringTohex(255),"FF");		
		assertEquals (Utility.padStringTohex(14),"0E");		
	}
	
	@Test
	public void testScaleFromFlash() {
		assertEquals (12,Utility.scaleFromFlash("100",-12,12,false));
		assertEquals (-12,Utility.scaleFromFlash("0",-12,12,false));
		assertEquals (0,Utility.scaleFromFlash("50",-12,12,false));
		assertEquals (12,Utility.scaleFromFlash("0",-12,12,true));
		assertEquals (-12,Utility.scaleFromFlash("100",-12,12,true));
	}
	
	@Test
	public void testScaleForFlash() {
		assertEquals (100,Utility.scaleForFlash("12",-12,12,false));
		assertEquals (0,Utility.scaleForFlash("-12",-12,12,false));
		assertEquals (50,Utility.scaleForFlash("0",-12,12,false));
		assertEquals (0,Utility.scaleForFlash("12",-12,12,true));
		assertEquals (100,Utility.scaleForFlash("-12",-12,12,true));
		assertEquals (100,Utility.scaleForFlash("00",-78,0,false));
		assertEquals (0,Utility.scaleForFlash("-78",-78,0,false));
	}
}
