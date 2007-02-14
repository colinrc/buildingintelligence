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
		long startTime = System.currentTimeMillis();
		
		CommandInterface triggeringCommand = new Command();
		triggeringCommand.setDisplayName("DLT_1");
		triggeringCommand.setCommand("on");
		labelMgr.setLabelState("DLT_1", "ON");
		scriptModel.groovyScriptHandler.runScript("TimeTest",null, scriptModel, triggeringCommand);
		
		long endTime1 = System.currentTimeMillis();
		
		 triggeringCommand = new Command();
		triggeringCommand.setDisplayName("DLT_1");
		triggeringCommand.setCommand("on");
		labelMgr.setLabelState("DLT_1", "OFF");
		scriptModel.groovyScriptHandler.runScript("TimeTest",null, scriptModel, triggeringCommand);
		assertEquals("Script did not create the correct number of command objects",6,commandQueue.size());
		
		
		long endTime2 = System.currentTimeMillis();
		
		System.out.println("Time to run 2 commands created (ms) "  + (endTime1  -  startTime));
		System.out.println("Time to run 4 commands created (ms) "  + (endTime2  -  endTime1));
			
	}
	

}
