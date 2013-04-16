/**
 * 
 */
package au.com.BI.CBUS;

import au.com.BI.CBUS.CBUSHelper;
import static org.junit.Assert.*;
import org.junit.Before;
import org.junit.Test;

/**
 * @author colin
 *
 */
public class TestChecksumCalculate {
	private CBUSHelper helper = null;
	
	@Before
	public void setUp() {
		helper = new CBUSHelper();
	}

	@Test
	public void testCalcChecksumString() {
		assertEquals ("Checksum Failed",helper.calcChecksum("A3410069"),	"B3");
	}

	@Test
	public void test2CalcChecksumString() {
		assertEquals ("Checksum Failed",helper.calcChecksum("0538007920"),	"2A");
	}
	
	@Test
	public void test3CalcChecksumString() {
		assertEquals ("Checksum Failed",helper.calcChecksum("0538007988"),	"C2");
	}
	
}
