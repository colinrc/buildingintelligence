package au.com.BI.Calendar;

import junit.framework.TestCase;
import junitx.framework.*;
import java.util.*;

public class TestSkipDatesAddDate extends TestCase {
	SkipDates skipDates;
	
	protected void setUp() throws Exception {
		super.setUp();
		skipDates = new SkipDates ();
	}

	/*
	 * Test method for 'au.com.BI.Calendar.SkipDates.parseEvent(Element)'
	 */
	public void testParseEvent() {

	}

	/*
	 * Test method for 'au.com.BI.Calendar.SkipDates.addDates(String, String)'
	 */
	public void testAddDates() {
		skipDates.addDates("2005-12-01","2005-12-15");
		skipDates.addDates("2005-12-17","2005-12-19");	
		LinkedList testList = new LinkedList();
		SkipEntry testSkipEntry = new SkipEntry ();
		testSkipEntry.setStartDate(new Date(105,11,1));
		testSkipEntry.setEndDate(new Date(105,11,15));

		SkipEntry testSkipEntry2 = new SkipEntry ();
		testSkipEntry2.setStartDate(new Date(105,11,17));
		testSkipEntry2.setEndDate(new Date(105,11,19));
		testList.add(testSkipEntry);
		testList.add(testSkipEntry2);
		ListAssert.assertEquals("Add dates failed",testList,skipDates.skipDates);
	}


}
