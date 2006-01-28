package au.com.BI.M1.Commands;

import java.util.logging.Level;
import java.util.logging.Logger;

import au.com.BI.M1.M1Helper;
import au.com.BI.Util.StringUtils;

public class M1CommandFactory {
	
	private static M1CommandFactory _singleton = null;
	private Logger logger;

	private M1CommandFactory() {
		super();
		// TODO Auto-generated constructor stub
		Logger logger = Logger.getLogger(M1CommandFactory.class.getPackage().getName());
	}
	
	public static M1CommandFactory getInstance() {
		if (_singleton == null) {
			_singleton = new M1CommandFactory();
		}
		return (_singleton);
	}
	
	/**
	 * Creates an appropriate command based on the string that is passed to it.
	 * If the string starts with the following:
	 * <ul>
	 * 	<li>CC - OutputChangeUpdate</li>
	 *   <li>a - Arm/Disarm Message</li>
	 * </ul>
	 * @param unparsedCommand
	 * @return
	 */
	public M1Command getM1Command(String unparsedCommand) {
		M1Command m1Command = null;
		
		if (unparsedCommand.substring(2,4).equals("CC")) {
			m1Command = parseOutputChangeCommand(unparsedCommand);
		} else if (unparsedCommand.substring(0,1).equals("a")) {
			m1Command = parseArmDisarmMessage(unparsedCommand);
		} else if (unparsedCommand.substring(2,4).equals("as")) {
			m1Command = parseArmingStatusRequest(unparsedCommand);
		} else if (unparsedCommand.substring(2,4).equals("AS")) {
			m1Command = parseReplyArmingStatusReportData(unparsedCommand);
		} else if (unparsedCommand.substring(2,4).equals("zs")) {
			m1Command = parseZoneStatusRequest(unparsedCommand);
		} else if (unparsedCommand.substring(2,4).equals("ZS")) {
			m1Command = parseZoneStatusReport(unparsedCommand);
		} else if (unparsedCommand.substring(2,4).equals("zp")) {
			m1Command = parseZonePartitionRequest(unparsedCommand);
		} else if (unparsedCommand.substring(2,4).equals("ZP")) {
			m1Command = parseZonePartitionReport(unparsedCommand);
		}
		
		if (m1Command == null) {
			logger.log(Level.WARNING,"m1Command was not found for: " + unparsedCommand);
		}
		return m1Command;
	}
	
	/**
	 * Parse an output change command.
	 * @param command
	 * @return
	 */
	private M1Command parseOutputChangeCommand(String command) {
		String hexLength = command.substring(0,2);
		int length = Integer.parseInt(hexLength,16);
		
		if (length != command.length()-2) {
			return (null);
		}
		
		OutputChangeUpdate _command = new OutputChangeUpdate();
		_command.setCommand(command);
		_command.setKey(command.substring(4,7));
		_command.setOutputState(command.substring(7,8));
		_command.setFutureUse(command.substring(8,10));
		_command.setCheckSum(command.substring(10));
		
		// Get checksum and compare
		String checkSum = new M1Helper().calcM1Checksum(command.substring(0,10));
		if (checkSum.equals(_command.getCheckSum())) {
			return(_command);
		} else {
			return(null);
		}
	}
	
	/**
	 * Parse an arm/disarm message
	 * @param command
	 * @return
	 */
	private M1Command parseArmDisarmMessage(String command) {
		String level = command.substring(1,2);
		String partition = command.substring(2,3);
		String userCode = command.substring(3);
		
		// do some sanity checks on the level, partition and userCode
		int _level = Integer.parseInt(level);
		if (_level < 0 || _level > 8) {
			logger.log(Level.WARNING,"level out of range for ArmDisarmMessage: " + command);
		}
		int _partition = Integer.parseInt(partition);
		if (_partition < 0 || _partition > 8) {
			logger.log(Level.WARNING,"partition out of range for ArmDisarmMessage: " + command);
		}
		
		if (level.equals("0")) {
			return(new Disarm(level,partition,userCode));
		} else if (level.equals("1")) {
			return(new ArmToAway(level,partition,userCode));
		} else if (level.equals("2")) {
			return(new ArmToStayHome(level,partition,userCode));
		} else if (level.equals("3")) {
			return(new ArmToStayInstant(level,partition,userCode));
		} else if (level.equals("4")) {
			return(new ArmToNight(level,partition,userCode));
		} else if (level.equals("5")) {
			return(new ArmToNightInstant(level,partition,userCode));
		} else if (level.equals("6")) {
			return(new ArmToVacation(level,partition,userCode));
		} else if (level.equals("7")) {
			return(new ArmStepToNextAwayMode(level,partition,userCode));
		} else if (level.equals("8")) {
			return(new ArmStepToNextStayMode(level,partition,userCode));
		}
		return null;
	}
	
	private M1Command parseArmingStatusRequest(String command) {
		String hexLength = command.substring(0,2);
		int length = Integer.parseInt(hexLength,16);
		
		if (length != command.length()-2) {
			return (null);
		}
		
		ArmingStatusRequest _command = new ArmingStatusRequest();
		_command.setCommand(command);
		_command.setKey(command.substring(2,4));
		_command.setFutureUse(command.substring(4,6));
		_command.setCheckSum(command.substring(6));
		
		// Get checksum and compare
		String checkSum = new M1Helper().calcM1Checksum(command.substring(0,6));
		if (checkSum.equals(_command.getCheckSum())) {
			return(_command);
		} else {
			return(null);
		}
	}
	
	private M1Command parseReplyArmingStatusReportData(String command) {
		String hexLength = command.substring(0,2);
		int length = Integer.parseInt(hexLength,16);
		
		if (length != command.length()-2) {
			return(null);
		}
		
		ReplyArmingStatusReportData _command = new ReplyArmingStatusReportData();
		_command.setCommand(command);
		_command.setKey(command.substring(2,4));
		_command.setCheckSum(command.substring(30));
		_command.setFutureUse(command.substring(28,30));
		
		String[] armedStatus = StringUtils.split(command.substring(4,12));
		String[] armUpState = StringUtils.split(command.substring(12,20));
		String[] areaAlarmState = StringUtils.split(command.substring(20,28));
		ArmedStatus[] armedStatusArray = new ArmedStatus[armedStatus.length];
		ArmUpState[] armUpStateArray = new ArmUpState[armUpState.length];
		AreaAlarmState[] areaAlarmStateArray = new AreaAlarmState[areaAlarmState.length];
		
//		 build the arrays
		for (int i=0;i<armedStatus.length;i++) {
			armedStatusArray[i] = ArmedStatus.getByValue(armedStatus[i]);
		}
		for (int i=0;i<armUpState.length;i++) {
			armUpStateArray[i] = ArmUpState.getByValue(armUpState[i]);
		}
		for (int i=0;i<areaAlarmState.length;i++) {
			areaAlarmStateArray[i] = AreaAlarmState.getByValue(areaAlarmState[i]);
		}
		_command.setArmedStatus(armedStatusArray);
		_command.setArmUpState(armUpStateArray);
		_command.setAreaAlarmState(areaAlarmStateArray);
		
		String checkSum = new M1Helper().calcM1Checksum(command.substring(0,30));
		if (checkSum.equals(_command.getCheckSum())) {
			return(_command);
		} else {
			return(null);
		}
	}
	
	private M1Command parseZoneStatusRequest(String command) {
		String hexLength = command.substring(0,2);
		int length = Integer.parseInt(hexLength,16);
		
		if (length != command.length()-2) {
			return (null);
		}
		
		ZoneStatusRequest _command = new ZoneStatusRequest();
		_command.setCommand(command);
		_command.setKey(command.substring(2,4));
		_command.setFutureUse(command.substring(4,6));
		_command.setCheckSum(command.substring(6));
		
		// Get checksum and compare
		String checkSum = new M1Helper().calcM1Checksum(command.substring(0,6));
		if (checkSum.equals(_command.getCheckSum())) {
			return(_command);
		} else {
			return(null);
		}
	}
	
	private M1Command parseZoneStatusReport(String command) {
		String hexLength = command.substring(0,2);
		int length = Integer.parseInt(hexLength,16);
		
		if (length != command.length() -2) {
			return (null);
		}
		
		ZoneStatusReport _command = new ZoneStatusReport();
		ZoneStatus[] states = new ZoneStatus[208];
		for (int i=0;i<208;i++) {
			states[i] = ZoneStatus.getByValue(command.substring(i+4,i+5));
		}
		_command.setZoneStatus(states);
		_command.setCheckSum(command.substring(command.length()-2));
		
		String checkSum = new M1Helper().calcM1Checksum(command.substring(0,command.length()-2));
		if (checkSum.equals(_command.getCheckSum())) {
			return(_command);
		} else {
			return(null);
		}
	}
	
	private M1Command parseZonePartitionRequest(String command) {
		String hexLength = command.substring(0,2);
		int length = Integer.parseInt(hexLength,16);
		
		if (length != command.length()-2) {
			return (null);
		}
		
		ZonePartitionRequest _command = new ZonePartitionRequest();
		_command.setCommand(command);
		_command.setKey(command.substring(2,4));
		_command.setFutureUse(command.substring(4,6));
		_command.setCheckSum(command.substring(6));
		
		// Get checksum and compare
		String checkSum = new M1Helper().calcM1Checksum(command.substring(0,6));
		if (checkSum.equals(_command.getCheckSum())) {
			return(_command);
		} else {
			return(null);
		}
	}
	
	private M1Command parseZonePartitionReport(String command) {
		String hexLength = command.substring(0,2);
		int length = Integer.parseInt(hexLength,16);
		
		if (length != command.length() -2) {
			return (null);
		}
		
		ZonePartitionReport _command = new ZonePartitionReport();
		ZonePartition[] partitions = new ZonePartition[208];
		for (int i=0;i<208;i++) {
			partitions[i] = ZonePartition.getByValue(command.substring(i+4,i+5));
		}
		_command.setZonePartitions(partitions);
		_command.setCheckSum(command.substring(command.length()-2));
		
		String checkSum = new M1Helper().calcM1Checksum(command.substring(0,command.length()-2));
		if (checkSum.equals(_command.getCheckSum())) {
			return(_command);
		} else {
			return(null);
		}
	}
	
}
