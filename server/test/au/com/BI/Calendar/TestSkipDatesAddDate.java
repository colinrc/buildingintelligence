package au.com.BI.Calendar;

import org.junit.Before;
import org.junit.Test;

import au.com.BI.Calendar.SkipDates;
import au.com.BI.Calendar.SkipEntry;
import static junit.framework.Assert.*;
import java.util.*;

import junitx.framework.ListAssert;

public class TestSkipDatesAddDate {
	SkipDates skipDates;
	
	@Before
	public void setUp() {
		skipDates = new SkipDates ();
	}

	/*
	 * Test method for 'au.com.BI.Calendar.SkipDates.addDates(String, String)'
	 */
	@Test
	public void testAddDates() {
		skipDates.addDates("2005-12-01 12:00:00","2005-12-15 12:00:00");
		skipDates.addDates("2005-12-17 12:00:00","2005-12-19 12:00:00");	
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
