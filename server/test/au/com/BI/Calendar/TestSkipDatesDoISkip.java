package au.com.BI.Calendar;

import junit.framework.TestCase;
import java.util.*;

public class TestSkipDatesDoISkip extends TestCase {
	SkipDates skipDates;
	
	protected void setUp() throws Exception {
		super.setUp();
		skipDates = new SkipDates ();
	}



	/*
	 * Test method for 'au.com.BI.Calendar.SkipDates.doISkipDate(Date)'
	 */
	public void testDoISkipDate() {
		skipDates.addDates("2005-12-01","2005-12-15");
		skipDates.addDates("2005-12-17","2005-12-19");	

		assertEquals("Do I skip failed ",false,skipDates.doISkipDate(new Date (105,11,16)));
		assertEquals("Do I skip failed on start date",true,skipDates.doISkipDate(new Date (105,11,1)));
		assertEquals("Do I skip failed on end date",true,skipDates.doISkipDate(new Date (105,11,15)));
		assertEquals("Do I skip failed on start,second range",true,skipDates.doISkipDate(new Date (105,11,17)));
		assertEquals("Do I skip failed outside range,second range",false,skipDates.doISkipDate(new Date (105,10,17)));

	}

}
