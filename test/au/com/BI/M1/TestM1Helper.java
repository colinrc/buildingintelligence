package au.com.BI.M1;

import static org.junit.Assert.*;
import org.junit.Before;
import org.junit.Test;

public class TestM1Helper {
	M1Helper m1Helper = null;
	
	@Before
	public void setUp () {
		m1Helper = new M1Helper();
	}

	@Test
	public void testCalcM1Checksum() {
		assertEquals("Generate checksum failed","66",m1Helper.calcM1Checksum("06as00"));
		assertEquals("Generate checksum failed","0E",m1Helper.calcM1Checksum("1EAS10000000400000003000000000"));		
	}

	@Test
	public void testPassChecksum() {
		assertEquals("Pass checksum failed",true,m1Helper.passChecksum("06as0066"));
		assertEquals("Pass checksum failed",true,m1Helper.passChecksum("1EAS100000004000000030000000000E"));
		assertEquals("Pass checksum failed",false,m1Helper.passChecksum("06as0065"));		
	}

	@Test
	public void testBuildCompleteM1String() {
		assertEquals("Pass build string failed","1EAS100000004000000030000000000E",m1Helper.buildCompleteM1String("AS10000000400000003000000000"));
		assertEquals("Pass build string failed","06as0066",m1Helper.buildCompleteM1String("as00"));
	}
}
