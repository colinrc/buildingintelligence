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
		logger = Logger.getLogger(M1CommandFactory.class.getPackage().getName());
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
	 *   <li>as - Arming Status Request Message</li>
	 *   <li>AS - Arming Status Report Message</li>
	 *   <li>zs - Zone Status Request Message</li>
	 *   <li>ZS - Zone Status Report Message</li>
	 *   <li>zp - Zone Partition Request Message</li>
	 *   <li>ZP - Zone Partition Report Message</li>
	 *   <li>zb - Zone Bypass Request Message</li>
	 *   <li>ZB - Zone Bypass Report Message</li>
	 *   <li>cn - Control Output On Message</li>
	 *   <li>cf - Control Output Off Message</li>
	 *   <li>ct - Control Output Toggle Message</li>
	 *   <li>cs - Control Output Status Request Message</li>
	 *   <li>CS - Control Output Status Report Message</li>
	 *   <li>st - Request Temperature Message</li>
	 *   <li>ST - Request Temperature Reply Message</li>
	 *   <li>az - Alarm by Zone Request Message</li>
	 *   <li>AZ - Reply Alarm by Zone Report Data Message</li>
	 *   <li>tn - Task Activation</li>
	 *   <li>TC - Tasks Change Update</li>
	 *   <li>PC - PLC Change Update</li>
	 *   <li>pf - Turn Off PLC Device</li>
	 *   <li>pn - Turn On PLC Device</li>
	 *   <li>pt - Toggle PLC Device</li>
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
		} else if (unparsedCommand.substring(2,4).equals("zb")) {
			m1Command = parseZoneBypassRequest(unparsedCommand);
		} else if (unparsedCommand.substring(2,4).equals("ZB")) {
			m1Command = parseReplyWithBypassedZoneState(unparsedCommand);
		} else if (unparsedCommand.substring(2,4).equals("ZC")) {
			m1Command = parseZoneChangeUpdate(unparsedCommand);
		} else if (unparsedCommand.substring(2,4).equals("cn")) {
			m1Command = parseControlOutputOn(unparsedCommand);
		} else if (unparsedCommand.substring(2,4).equals("cf")) {
			m1Command = parseControlOutputOff(unparsedCommand);
		} else if (unparsedCommand.substring(2,4).equals("ct")) {
			m1Command = parseControlOutputToggle(unparsedCommand);
		} else if (unparsedCommand.substring(2,4).equals("cs")) {
			m1Command = parseControlOutputStatusRequest(unparsedCommand);
		} else if (unparsedCommand.substring(2,4).equals("CS")) {
			m1Command = parseControlOutputStatusReport(unparsedCommand);
		} else if (unparsedCommand.substring(2,4).equals("st")) {
			m1Command = parseRequestTemperature(unparsedCommand);
		} else if (unparsedCommand.substring(2,4).equals("ST")) {
			m1Command = parseRequestTemperatureReply(unparsedCommand);
		} else if (unparsedCommand.substring(2,4).equals("az")) {
			m1Command = parseAlarmByZoneRequest(unparsedCommand);
		} else if (unparsedCommand.substring(2,4).equals("AZ")) {
			m1Command = parseReplyAlarmByZoneReportData(unparsedCommand);
		} else if (unparsedCommand.substring(2,4).equals("tn")) {
			m1Command = parseTaskActivation(unparsedCommand);
		} else if (unparsedCommand.substring(2,4).equals("TC")) {
			m1Command = parseTasksChangeUpdate(unparsedCommand);
		} else if (unparsedCommand.substring(2,4).equals("PC")) {
			m1Command = parsePLCChangeUpdate(unparsedCommand);
		} else if (unparsedCommand.substring(2,4).equals("pn")) {
			m1Command = parsePLCDeviceOn(unparsedCommand);
		} else if (unparsedCommand.substring(2,4).equals("pf")) {
			m1Command = parsePLCDeviceOff(unparsedCommand);
		} else if (unparsedCommand.substring(2,4).equals("pt")) {
			m1Command = parsePLCDeviceToggle(unparsedCommand);
		}
		
		
		if (m1Command == null) {
			logger.log(Level.FINEST,"m1Command was not found for: " + unparsedCommand);
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
	
	/**
	 * Parse a request for arming status.
	 * @param command
	 * @return
	 */
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
	
	/**
	 * Parse a message that contains the arming status report data.
	 * @param command
	 * @return
	 */
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
	
	/**
	 * Parse a message for a zone status request.
	 * @param command
	 * @return
	 */
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
	
	/**
	 * Parse a message for a zone status report.
	 * @param command
	 * @return
	 */
	private M1Command parseZoneStatusReport(String command) {
		String hexLength = command.substring(0,2);
		int length = Integer.parseInt(hexLength,16);
		
		if (length != command.length() -2) {
			return (null);
		}
		
		ZoneStatusReport _command = new ZoneStatusReport();
		_command.setCommand(command);
		_command.setKey(command.substring(2,4));
		_command.setCheckSum(command.substring(0,command.length()-2));

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
	
	/**
	 * Parse a message for a zone partition request.
	 * @param command
	 * @return
	 */
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
	
	/**
	 * Parse a message with a zone partition report.
	 * @param command
	 * @return
	 */
	private M1Command parseZonePartitionReport(String command) {
		String hexLength = command.substring(0,2);
		int length = Integer.parseInt(hexLength,16);
		
		if (length != command.length() -2) {
			return (null);
		}
		
		ZonePartitionReport _command = new ZonePartitionReport();
		_command.setCommand(command);
		_command.setKey(command.substring(2,4));
		_command.setCheckSum(command.substring(0,command.length()-2));
		
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
	
	/**
	 * Parse a message with the zone bypass request.
	 * @param command
	 * @return
	 */
	private M1Command parseZoneBypassRequest(String command) {
		
		String hexLength = command.substring(0,2);
		int length = Integer.parseInt(hexLength,16);
		
		if (length != command.length() -2) {
			return (null);
		}
		ZoneBypassRequest _command = new ZoneBypassRequest();
		_command.setCommand(command);
		_command.setCheckSum(command.substring(command.length()-2));
		String zone = command.substring(4,7);
		_command.setZone(zone);
		_command.setKey(zone);
		
		if (zone.equals("000")) {
			_command.setBypassAllZones(true);
		} else if (zone.equals("999")) {
			_command.setBypassAllViolatedZones(true);
		}
		_command.setArea(command.substring(7,8));
		_command.setPinCode(command.substring(8,14));
		_command.setFutureUse(command.substring(14,15));
		
		String checkSum = new M1Helper().calcM1Checksum(command.substring(0,command.length()-2));
		if (checkSum.equals(_command.getCheckSum())) {
			return(_command);
		} else {
			return(null);
		}
	}
	
	/**
	 * Parse a message for a reply with the bypassed zone's state.
	 * @param command
	 * @return
	 */
	private M1Command parseReplyWithBypassedZoneState(String command) {
		String hexLength = command.substring(0,2);
		int length = Integer.parseInt(hexLength,16);
		
		if (length != command.length() -2) {
			return (null);
		}
		ReplyWithBypassedZoneState _command = new ReplyWithBypassedZoneState();
		_command.setCommand(command);
		_command.setCheckSum(command.substring(command.length()-2));
		_command.setZone(command.substring(4,7));
		_command.setKey(command.substring(4,7));
		_command.setBypassState(ZoneBypassState.getByValue(command.substring(7,8)));
		
		String checkSum = new M1Helper().calcM1Checksum(command.substring(0,command.length()-2));
		if (checkSum.equals(_command.getCheckSum())) {
			return(_command);
		} else {
			return(null);
		}
	}
	
	/**
	 * Parse a message for a zone change update.
	 * @param command
	 * @return
	 */
	private M1Command parseZoneChangeUpdate(String command) {
		String hexLength = command.substring(0,2);
		int length = Integer.parseInt(hexLength,16);
		
		if (length != command.length() -2) {
			return (null);
		}
		
		ZoneChangeUpdate _command = new ZoneChangeUpdate();
		_command.setCommand(command);
//		_command.setKey(command.substring(2,4));
		_command.setCheckSum(command.substring(command.length()-2));
		_command.setZone(command.substring(4,7));
		_command.setKey(command.substring(4,7));
		_command.setZoneStatus(ZoneStatus.getByValue(command.substring(7,8)));
		_command.setFutureUse(command.substring(8,10));
		
		if (_command.getZoneStatus() == ZoneStatus.VIOLATED_SHORT) {
			_command.setOutputState("1");
		}
		if (_command.getZoneStatus() == ZoneStatus.NORMAL_EOL) {
			_command.setOutputState("0");
		}
		// Dave you need to make sure these status strings don't trigger an alarm, they are just standard PIR on/off messages
			
		String checkSum = new M1Helper().calcM1Checksum(command.substring(0,command.length()-2));
		if (checkSum.equals(_command.getCheckSum())) {
			return(_command);
		} else {
			return(null);
		}
	}
	
	/**
	 * Parse a message to turn a control output on.
	 * @param command
	 * @return
	 */
	private M1Command parseControlOutputOn(String command) {
		String hexLength = command.substring(0,2);
		int length = Integer.parseInt(hexLength,16);
		
		if (length != command.length() -2) {
			return (null);
		}
		
		ControlOutputOn _command = new ControlOutputOn();
		_command.setCommand(command);
		_command.setCheckSum(command.substring(command.length()-2));
		_command.setKey(command.substring(4,7));
		_command.setOutputNumber(command.substring(4,7));
		_command.setSeconds(command.substring(7,12));
		
		String checkSum = new M1Helper().calcM1Checksum(command.substring(0,command.length()-2));
		if (checkSum.equals(_command.getCheckSum())) {
			return(_command);
		} else {
			return(null);
		}
	}
	
	/**
	 * Parse a message to turn a control output off.
	 * @param command
	 * @return
	 */
	private M1Command parseControlOutputOff(String command) {
		String hexLength = command.substring(0,2);
		int length = Integer.parseInt(hexLength,16);
		
		if (length != command.length() -2) {
			return (null);
		}
		
		ControlOutputOff _command = new ControlOutputOff();
		_command.setCommand(command);
		_command.setCheckSum(command.substring(command.length()-2));
		_command.setKey(command.substring(4,7));
		_command.setOutputNumber(command.substring(4,7));
		
		String checkSum = new M1Helper().calcM1Checksum(command.substring(0,command.length()-2));
		if (checkSum.equals(_command.getCheckSum())) {
			return(_command);
		} else {
			return(null);
		}
	}
	
	/**
	 * Parse a message to toggle a control output.
	 * @param command
	 * @return
	 */
	private M1Command parseControlOutputToggle(String command) {
		String hexLength = command.substring(0,2);
		int length = Integer.parseInt(hexLength,16);
		
		if (length != command.length() -2) {
			return (null);
		}
		
		ControlOutputToggle _command = new ControlOutputToggle();
		_command.setCommand(command);
		_command.setCheckSum(command.substring(command.length()-2));
		_command.setKey(command.substring(4,7));
		_command.setOutputNumber(command.substring(4,7));
		
		String checkSum = new M1Helper().calcM1Checksum(command.substring(0,command.length()-2));
		if (checkSum.equals(_command.getCheckSum())) {
			return(_command);
		} else {
			return(null);
		}
	}
	
	/**
	 * Parse a message that contains the request for the states of control output devices in the system.
	 * @param command
	 * @return
	 */
	private M1Command parseControlOutputStatusRequest(String command) {
		String hexLength = command.substring(0,2);
		int length = Integer.parseInt(hexLength,16);
		
		if (length != command.length() -2) {
			return (null);
		}
		
		ControlOutputStatusRequest _command = new ControlOutputStatusRequest();
		_command.setCommand(command);
		_command.setCheckSum(command.substring(command.length()-2));
		
		String checkSum = new M1Helper().calcM1Checksum(command.substring(0,command.length()-2));
		if (checkSum.equals(_command.getCheckSum())) {
			return(_command);
		} else {
			return(null);
		}
	}
	
	/**
	 * Parse a message that contains the states of the control outputs in the system.
	 * @param command
	 * @return
	 */
	private M1Command parseControlOutputStatusReport(String command) {
		String hexLength = command.substring(0,2);
		int length = Integer.parseInt(hexLength,16);
		
		if (length != command.length() -2) {
			return (null);
		}
		
		ControlOutputStatusReport _command = new ControlOutputStatusReport();
		_command.setCommand(command);
		_command.setKey(command.substring(2,4));
		_command.setCheckSum(command.substring(0,command.length()-2));
		boolean[] states = new boolean[208];
		for (int i=0;i<208;i++) {
			String state = command.substring(i+4,i+5);
			
			if (state.equals("0")) {
				states[i] = false;
			} else {
				states[i] = true;
			}
		}
		_command.setOutputStatus(states);
		_command.setCheckSum(command.substring(command.length()-2));
		
		String checkSum = new M1Helper().calcM1Checksum(command.substring(0,command.length()-2));
		if (checkSum.equals(_command.getCheckSum())) {
			return(_command);
		} else {
			return(null);
		}
	}
	
	/**
	 * Construct a message to request the temperature for a given device/group.
	 * @param command
	 * @return
	 */
	private M1Command parseRequestTemperature(String command) {
		String hexLength = command.substring(0,2);
		int length = Integer.parseInt(hexLength,16);
		
		if (length != command.length() -2) {
			return (null);
		}
		
		RequestTemperature _command = new RequestTemperature();
		_command.setCommand(command);
		_command.setKey(command.substring(2,4));
		_command.setCheckSum(command.substring(0,command.length()-2));
		_command.setGroup(Group.getByValue(command.substring(4,5)));
		_command.setDevice(command.substring(5,7));
		_command.setCheckSum(command.substring(command.length()-2));
		
		String checkSum = new M1Helper().calcM1Checksum(command.substring(0,command.length()-2));
		if (checkSum.equals(_command.getCheckSum())) {
			return(_command);
		} else {
			return(null);
		}
	}
	
	/**
	 * Construct a message to parse replies to the temperature requests.
	 * @param command
	 * @return The temperature reply message
	 */
	private M1Command parseRequestTemperatureReply(String command) {
		String hexLength = command.substring(0,2);
		int length = Integer.parseInt(hexLength,16);
		
		if (length != command.length() -2) {
			return (null);
		}
		
		RequestTemperatureReply _command = new RequestTemperatureReply();
		_command.setCommand(command);
		_command.setKey(command.substring(5,7));
		_command.setCheckSum(command.substring(0,command.length()-2));
		_command.setGroup(Group.getByValue(command.substring(4,5)));
		_command.setDevice(command.substring(5,7));
		_command.setTemperature(command.substring(7,10));
		_command.setCheckSum(command.substring(command.length()-2));
		
		String checkSum = new M1Helper().calcM1Checksum(command.substring(0,command.length()-2));
		if (checkSum.equals(_command.getCheckSum())) {
			return(_command);
		} else {
			return(null);
		}
	}
	
	/**
	 * Construct a message to request alarms by the zone.
	 * @param command
	 * @return The request for alarms by zone message
	 */
	private M1Command parseAlarmByZoneRequest(String command) {
		String hexLength = command.substring(0,2);
		int length = Integer.parseInt(hexLength,16);
		
		if (length != command.length()-2) {
			return (null);
		}
		
		AlarmByZoneRequest _command = new AlarmByZoneRequest();
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
	
	/**
	 * Parse a reply with the alarms by zones report.
	 * @param command
	 * @return
	 */
	private M1Command parseReplyAlarmByZoneReportData(String command) {
		String hexLength = command.substring(0,2);
		int length = Integer.parseInt(hexLength,16);
		
		if (length != command.length() -2) {
			return (null);
		}
		
		ReplyAlarmByZoneReportData _command = new ReplyAlarmByZoneReportData();
		_command.setCommand(command);
		_command.setKey(command.substring(2,4));
		_command.setCheckSum(command.substring(0,command.length()-2));
		ZoneDefinition[] zoneDefinitions = new ZoneDefinition[208];
		for (int i=0;i<208;i++) {
			String zoneDefinition = command.substring(i+4,i+5);
			
			zoneDefinitions[i] = ZoneDefinition.getByValue(zoneDefinition);
		}
		_command.setZoneDefinition(zoneDefinitions);
		_command.setCheckSum(command.substring(command.length()-2));
		
		String checkSum = new M1Helper().calcM1Checksum(command.substring(0,command.length()-2));
		if (checkSum.equals(_command.getCheckSum())) {
			return(_command);
		} else {
			return(null);
		}
	}
	
	/**
	 * Tasks Change Update
	 * @param command
	 * @return
	 */
	private M1Command parseTaskActivation(String command) {
		String hexLength = command.substring(0,2);
		int length = Integer.parseInt(hexLength,16);
		
		if (length != command.length() -2) {
			return (null);
		}
		
		TaskActivation _command = new TaskActivation();
		_command.setCommand(command);
		_command.setKey(command.substring(2,4));
		_command.setCheckSum(command.substring(command.length()-2));
		_command.setTask(command.substring(4,7));
		
		String checkSum = new M1Helper().calcM1Checksum(command.substring(0,command.length()-2));
		if (checkSum.equals(_command.getCheckSum())) {
			return(_command);
		} else {
			return(null);
		}
	}
	
	/**
	 * 
	 * @param command
	 * @return
	 */
	private M1Command parseTasksChangeUpdate(String command) {
		String hexLength = command.substring(0,2);
		int length = Integer.parseInt(hexLength,16);
		
		if (length != command.length() -2) {
			return (null);
		}
		
		TasksChangeUpdate _command = new TasksChangeUpdate();
		_command.setCommand(command);
		_command.setKey(command.substring(2,4));
		_command.setCheckSum(command.substring(command.length()-2));
		_command.setTask(command.substring(4,7));
		
		String checkSum = new M1Helper().calcM1Checksum(command.substring(0,command.length()-2));
		if (checkSum.equals(_command.getCheckSum())) {
			return(_command);
		} else {
			return(null);
		}
	}
	
	private M1Command parsePLCChangeUpdate(String command) {
		String hexLength = command.substring(0,2);
		int length = Integer.parseInt(hexLength,16);
		
		if (length != command.length() -2) {
			return (null);
		}
		
		PLCChangeUpdate _command = new PLCChangeUpdate();
		_command.setCommand(command);
		_command.setKey(command.substring(2,4));
		_command.setCheckSum(command.substring(command.length()-2));
		_command.setHouseCode(command.substring(4,5));
		_command.setUnitCode(command.substring(5,7));
		
		String levelStatus = command.substring(7,9);
		if (_command.getUnitCode().equals("00") && levelStatus.equals("01")) {
			_command.setLevelStatus(PLCLevelStatus.X10_ALL_UNITS_OFF);
		} else if (_command.getUnitCode().equals("00") && levelStatus.equals("02")) {
			_command.setLevelStatus(PLCLevelStatus.X10_ALL_LIGHTS_ON);
		} else if (_command.getUnitCode().equals("00") && levelStatus.equals("07")) {
			_command.setLevelStatus(PLCLevelStatus.X10_ALL_LIGHTS_OFF);
		} else if (levelStatus.equals("00")) {
			_command.setLevelStatus(PLCLevelStatus.OFF);
		} else if (levelStatus.equals("01")) {
			_command.setLevelStatus(PLCLevelStatus.ON);
		} else {
			_command.setLevelStatus(PLCLevelStatus.getByValue(levelStatus));
		}
		
		String checkSum = new M1Helper().calcM1Checksum(command.substring(0,command.length()-2));
		if (checkSum.equals(_command.getCheckSum())) {
			return(_command);
		} else {
			return(null);
		}
	}
	
	/**
	 * Parse a message to turn a PLC Device on.
	 * @param command
	 * @return
	 */
	private M1Command parsePLCDeviceOn(String command) {
		String hexLength = command.substring(0,2);
		int length = Integer.parseInt(hexLength,16);
		
		if (length != command.length() -2) {
			return (null);
		}
		
		PLCDeviceOn _command = new PLCDeviceOn();
		_command.setCommand(command);
		_command.setCheckSum(command.substring(command.length()-2));
		_command.setHouseCode(command.substring(4,5));
		_command.setUnitCode(command.substring(5,7));
		
		String checkSum = new M1Helper().calcM1Checksum(command.substring(0,command.length()-2));
		if (checkSum.equals(_command.getCheckSum())) {
			return(_command);
		} else {
			return(null);
		}
	}
	
	/**
	 * Parse a message to turn a PLC Device off.
	 * @param command
	 * @return
	 */
	private M1Command parsePLCDeviceOff(String command) {
		String hexLength = command.substring(0,2);
		int length = Integer.parseInt(hexLength,16);
		
		if (length != command.length() -2) {
			return (null);
		}
		
		PLCDeviceOff _command = new PLCDeviceOff();
		_command.setCommand(command);
		_command.setCheckSum(command.substring(command.length()-2));
		_command.setHouseCode(command.substring(4,5));
		_command.setUnitCode(command.substring(5,7));
		
		String checkSum = new M1Helper().calcM1Checksum(command.substring(0,command.length()-2));
		if (checkSum.equals(_command.getCheckSum())) {
			return(_command);
		} else {
			return(null);
		}
	}
	
	/**
	 * Parse a message to toggle a PLC Device.
	 * @param command
	 * @return
	 */
	private M1Command parsePLCDeviceToggle(String command) {
		String hexLength = command.substring(0,2);
		int length = Integer.parseInt(hexLength,16);
		
		if (length != command.length() -2) {
			return (null);
		}
		
		PLCDeviceToggle _command = new PLCDeviceToggle();
		_command.setCommand(command);
		_command.setCheckSum(command.substring(command.length()-2));
		_command.setHouseCode(command.substring(4,5));
		_command.setUnitCode(command.substring(5,7));
		
		String checkSum = new M1Helper().calcM1Checksum(command.substring(0,command.length()-2));
		if (checkSum.equals(_command.getCheckSum())) {
			return(_command);
		} else {
			return(null);
		}
	}
	
}
