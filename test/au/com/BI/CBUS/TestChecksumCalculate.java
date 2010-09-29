/**
 * 
 */
package au.com.BI.CBUS;

import au.com.BI.CBUS.CBUSHelper;
import junit.framework.TestCase;

/**
 * @author colin
 *
 */
public class TestChecksumCalculate extends TestCase {
	private CBUSHelper helper = null;
	
	protected void setUp() throws Exception {
		super.setUp();
		helper = new CBUSHelper();
	}
	
	/**
	 * Test method for {@link au.com.BI.CBUS.Model#calcChecksum(java.lang.String)}.
	 */
	public void testCalcChecksumString() {
		assertEquals ("Checksum Failed",helper.calcChecksum("A3410069"),	"B3");
	}

	public void test2CalcChecksumString() {
		assertEquals ("Checksum Failed",helper.calcChecksum("0538007920"),	"2A");
	}
	
	public void test3CalcChecksumString() {
		assertEquals ("Checksum Failed",helper.calcChecksum("0538007988"),	"C2");
	}
	
}
