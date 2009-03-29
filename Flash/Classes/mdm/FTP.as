/**
* @author 	MDM
* @version 	1.0.0
*/
intrinsic class mdm.FTP {
	/* events */
	var onAborted:Function;
	var onBusy:Function;
	var onConnected:Function;
	var onDirChanged:Function;
	var onDirCreated:Function;
	var onDirDeleted:Function;
	var onError:Function;
	var onFileDeleted:Function;
	var onFileReceived:Function;
	var onFileRenamed:Function;
	var onFileSent:Function;
	var onFileTransfered:Function;
	var onIndexFileReceived:Function;
	var onListingDone:Function;
	var onLoggedIn:Function;
	var onQuit:Function;
	var onReady:Function;
	var onResolvedLinks:Function;
	/* constructor */
	function FTP();
	/* methods */
	function abort();
	function chDir();
	function close();
	function deleteDir();
	function deleteFile();
	function dirExists();
	function fileExists();
	function getDirAttribs();
	function getDirDateTime();
	function getFile();
	function getFiles();
	function getFileDateTime();
	function getFileAttribs();
	function getFileSize();
	function getFolders();
	function login();
	function makeDir();
	function moveFile();
	function mMakeDir();
	function mDeleteDir();
	function mDeleteFile();
	function mGetFile();
	function mMoveFile();
	function mRenameFile();
	function mSendFile();
	function mTransferFile();
	function refresh();
	function renameFile();
	function resumePosition();
	function sendCommand();
	function sendFile();
	function setProxy();
	function transferFile();
	/* properties */
	var account;
	var async;
	var bytesTransfered;
	var currentDir;
	var error;
	var files;
	var filesDetailed;
	var folders;
	var foldersDetailed;
	var id;
	var initialDir;
	var isBusy;
	var isConnected;
	var lastReply;
	var loggerData;
	var noop;
	var passive;
	var port;
	var serverType;
	var success;
	var supportsResume;
	var timeout;
	var transferMode;
	var transferTime;
}
