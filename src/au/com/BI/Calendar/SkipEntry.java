package au.com.BI.Calendar;

import java.util.Date;

public class SkipEntry {
	Date startDate;
	Date endDate;
	
	public int hashCode() {
		  assert false : "hashCode not designed";
		  return 42; // any arbitrary constant will do 
	 }

	public Date getStartDate() {
		return startDate;
	}
	
	public void setStartDate(Date startDate) {
		this.startDate = startDate;
	}

	public Date getEndDate() {
		return endDate;
	}

	public void setEndDate(Date endDate) {
		this.endDate = endDate;
	}
	public boolean equals (Object toTest){
		if (!(toTest instanceof SkipEntry)) 
			return false;
		
		if (!((SkipEntry)toTest).startDate.equals(startDate))
			return false;
		
		if (!((SkipEntry)toTest).endDate.equals(endDate))
			return false;
		
		return true;
	}
}
