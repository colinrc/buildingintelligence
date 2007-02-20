package au.com.BI.Script;

import junit.framework.TestCase;
import java.util.*;

import au.com.BI.Command.Cache;
import au.com.BI.Command.Command;
import au.com.BI.Command.CommandInterface;
import au.com.BI.Command.CommandQueue;
import au.com.BI.LabelMgr.LabelMgr;

public class TestGroovyTimingTest extends TestCase {
	Model scriptModel = null;
	ScriptHandler sciptHandler = null;
	Map scriptRunBlockList = null;
	LabelMgr labelMgr = null;
	Cache cache = null;
	CommandQueue commandQueue = null;

	protected void setUp() throws Exception {
		super.setUp();
		scriptModel = new Model();
		labelMgr = new LabelMgr();
		 commandQueue = new CommandQueue();
		cache = new Cache(null);
		scriptModel.setCommandQueue(commandQueue);
		scriptModel.setCache(cache);
		scriptModel.setLabelMgr(labelMgr);
		scriptModel.loadGroovyScripts();
		sciptHandler = scriptModel.getScriptHandler();
		scriptRunBlockList = scriptModel.groovyScriptRunBlockList;
	}

	protected void tearDown() throws Exception {
		super.tearDown();
	}


	

	public void testScriptPerformance2Commands() {
		// 

		int numberRuns = 10;
		long twoCommands[] = new long[numberRuns];
		long fourCommands[] = new long[numberRuns];
		
		for (int i= 0; i < numberRuns; i ++) {
			long startTime = System.currentTimeMillis();
			CommandInterface triggeringCommand = new Command();
			triggeringCommand.setDisplayName("DLT_1");
			triggeringCommand.setCommand("on");
			labelMgr.setLabelState("DLT_1", "ON");
			scriptModel.groovyScriptHandler.runScript("TimeTest",null, scriptModel, triggeringCommand,false);
			
			long endTime1 = System.currentTimeMillis() ;

					
			 triggeringCommand = new Command();
			triggeringCommand.setDisplayName("DLT_1");
			triggeringCommand.setCommand("on");
			labelMgr.setLabelState("DLT_1", "OFF");
			scriptModel.groovyScriptHandler.runScript("TimeTest",null, scriptModel, triggeringCommand,false);
			long timeToRun2 = System.currentTimeMillis() - endTime1;
			long timeToRun1 = endTime1 - startTime;
			
			twoCommands [i] = timeToRun1;
			fourCommands[i] = timeToRun2;
			
		}
		long total1 = 0;
		long total2 = 0;
		
		for (int i = 0 ; i < numberRuns; i ++){
		
			System.out.println("Time to run 2 commands created (ms) "  + twoCommands[i]);
			total1 += twoCommands[i];
			System.out.println("Time to run 4 commands created (ms) "  + fourCommands[i]);
			total2 += fourCommands[i];
		}
		System.out.println ("Average 2 (ms) " + total1 / numberRuns);
		System.out.println ("Average 4 (ms) " + total2 / numberRuns);
		
		assertFalse("Script did not create any objects",commandQueue.isEmpty());
	
	}
}
