package au.com.BI.M1;

import junit.framework.TestCase;

public class TestM1Helper extends TestCase {
	M1Helper m1Helper = null;
	
	public void setUp () {
		m1Helper = new M1Helper();
		
	}
	/*
	 * Test method for 'M1Helper.calcM1Checksum(String)'
	 */
	public void testCalcM1Checksum() {
		assertEquals("Generate checksum failed","66",m1Helper.calcM1Checksum("06as00"));
		assertEquals("Generate checksum failed","0e",m1Helper.calcM1Checksum("1EAS10000000400000003000000000"));		

	}

	/*
	 * Test method for 'M1Helper.passChecksum(String)'
	 */
	public void testPassChecksum() {
		assertEquals("Pass checksum failed",true,m1Helper.passChecksum("06as0066"));
		assertEquals("Pass checksum failed",true,m1Helper.passChecksum("1EAS100000004000000030000000000E"));
		assertEquals("Pass checksum failed",false,m1Helper.passChecksum("06as0065"));		

	}

	/*
	 * Test method for 'M1Helper.buildCompleteM1String(String)'
	 */
	public void testBuildCompleteM1String() {

	}

}
