package au.com.BI.Calendar;

import org.junit.Before;
import org.junit.Test;
import static junit.framework.Assert.*;
import java.util.*;

public class TestSkipDatesDoISkip {
	SkipDates skipDates;
	
	@Before
	public void setUp() throws Exception {
		skipDates = new SkipDates ();
	}

	@Test
	public void testDoISkipDate() {
		skipDates.addDates("2005-12-01 12:00:00","2005-12-15 12:00:00");
		skipDates.addDates("2005-12-17 12:00:00","2005-12-19 12:00:00");	

		assertEquals("Do I skip failed ",false,skipDates.doISkipDate(new Date (105,11,16)));
		assertEquals("Do I skip failed on start date",true,skipDates.doISkipDate(new Date (105,11,1)));
		assertEquals("Do I skip failed on end date",true,skipDates.doISkipDate(new Date (105,11,15)));
		assertEquals("Do I skip failed on start,second range",true,skipDates.doISkipDate(new Date (105,11,17)));
		assertEquals("Do I skip failed outside range,second range",false,skipDates.doISkipDate(new Date (105,10,17)));

	}

}
