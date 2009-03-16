/*
 *  $Id: Hasp.java,v 1.6 2004/06/03 10:25:21 horatiu Exp $
 *
 *  Copyright 2004 Aladdin Knowledge Systems Ltd. All rights reserved.
 *  Use is subject to license terms.
 */

package Aladdin;

import java.nio.*;
import Aladdin.HaspStatus;
import Aladdin.HaspTime;

public class Hasp {
  /**
   * private members 
   */

  /**
   * handle           - pointer to the resulting session handle 
   */
  private int[] handle = {0};

  /**
   * Unique identifier of the feature                           
   */
  private long featureid;

  /**
   * status of the last called function                         
   */
  private int status;

  public static final String HASP_UPDATEINFO  = new String("<haspformat format=\"updateinfo\"/>\0");   /*!< hasp_get_sessioninfo() format to get update info (C2V) */
  public static final String HASP_SESSIONINFO = new String("<haspformat format=\"sessioninfo\"/>\0");  /*!< hasp_get_sessioninfo() format to get session info */
  public static final String HASP_KEYINFO     = new String("<haspformat format=\"keyinfo\"/>\0");      /*!< hasp_get_sessioninfo() format to get key/hardware info */

  /**
   * "Featuretype" mask
   *
   *  AND-mask used to identify feature type
   */
  public static final long HASP_FEATURETYPE_MASK       = 0xffff0000;


  /**
   *  "PROGRAM NUMBER FEATURE" type
   *
   *  After AND-ing with HASP_FEATURETYPE_MASK feature type contain this value
   */
  public static final long HASP_PROGNUM_FEATURETYPE    = 0xffff0000;


  /**
   *  program number mask
   *
   *  AND-mask used to extract program number from feature id if program number feature
   */
  public static final long HASP_PROGNUM_MASK = 0x000000ff;


  /**
   *  prognum options mask
   *
   *  AND-mask used to identify prognum options:
   *     - HASP_PROGNUM_OPT_NO_LOCAL
   *     - HASP_PROGNUM_OPT_NO_REMOTE
   *     - HASP_PROGNUM_OPT_PROCESS
   *     - HASP_PROGNUM_OPT_CLASSIC
   *     - HASP_PROGNUM_OPT_TS
   *
   *  3 bits of the mask are reserved for future extensions and currently unused
   *  Initialize them to zero
   */
  public static final long HASP_PROGNUM_OPT_MASK = 0x0000ff00;


  /**
   *  "Prognum" option
   *
   *  Disable local license search
   */
  public static final long HASP_PROGNUM_OPT_NO_LOCAL = 0x00008000;


  /**
   *  "Prognum" option
   *
   *  Disable network license search
   */
  public static final long HASP_PROGNUM_OPT_NO_REMOTE = 0x00004000;


  /**
   *  "Prognum" option
   *
   *  Sets session count of network licenses to per-process
   */
  public static final long HASP_PROGNUM_OPT_PROCESS = 0x00002000;


  /** 
   *  "Prognum" option
   *
   *  Enables the API to access "classic" (HASP4 or earlier) keys
   */
  public static final long HASP_PROGNUM_OPT_CLASSIC = 0x00001000;


  /** 
   * "Prognum" option
   *
   *  Presence of Terminal Services gets ignored
   */
  public static final long HASP_PROGNUM_OPT_TS = 0x00000800;


  /** 
   *  HASP default feature id
   *
   *  Present in every hardware key
   */
  public static final long HASP_DEFAULT_FID = 0;


  /** 
   *  "Prognum" default feature id
   *
   *  Present in every hardware HASP key
   */
  public static final long HASP_PROGNUM_DEFAULT_FID  = (HASP_DEFAULT_FID | HASP_PROGNUM_FEATURETYPE);


  /** 
   *  Minimal block size for hasp_encrypt() and hasp_decrypt() functions
   */
  public static final int HASP_MIN_BLOCK_SIZE = 16;

  /**
   *  Minimal block size for legacy functions hasp_legacy_encrypt()
   *  and hasp_legacy_decrypt()
   */
  public static final long HASP_MIN_BLOCK_SIZE_LEGACY = 8;

  /** 
   *  hasp_file_ids Memory file id defines
   *
   * 
   */

  /** 
   *  HASP4 memory file
   *
   *  File id for HASP4 compatible memory contents w/o FAS
   */
  public static final int HASP_FILEID_MAIN = 0xfff0;

  /**
   *   HASP4 FAS memory file
   *
   *  (Dummy) file id for license data area of memory contents
   */
  public static final long HASP_FILEID_LICENSE = 0xfff2;

  /**
   *  Returns the error that occured in the last function call.
   *
   *  @return error that occured in the last function call
   *
   */
  public int getLastError(){
    return status;
  }

  static {
    System.loadLibrary("HASPJava");
  }

  /**
   * private native methods 
   */
  private static native int Login(long feature_id,byte vendor_code[],int handle[]);
  private static native int Logout(int handle);
  private static native int Encrypt(int handle, byte buffer[], int length);
  private static native int Decrypt(int handle, byte buffer[], int length);
  private static native int GetRtc(int handle, long time[]);
  private static native byte[] GetSessioninfo(int handle,byte format[],int status[]);
  private static native void Free(long info);
  private static native byte[] Update(byte update_data[],int status[]);

  /**
   * functions to access the memory 
   */
  private static native int Read(int handle, int fileid, int offset, int length, byte buffer[]);
  private static native int Write(int handle, int fileid, int offset, int length, byte buffer[]);
  private static native int GetSize(int handle, int fileid, int size[]);

  /**
   * public functions 
   */

  /**
  * Hasp constructor
  *
  *  For local prognum features, concurrency is not handled and each login performs a decrement
  *  if it is a counting license.
  *
  *  Network prognum features just use the old HASPLM login logic with all drawbacks.
  *  There is only support for concurrent usage of \b one server (global server address).
  *
  *  @param feature_id       - Unique identifier of the feature\n
  *                            With "prognum" features (see \ref HASP_FEATURETYPE_MASK),
  *                            8 bits are reserved for legacy options (see \ref HASP_PROGNUM_OPT_MASK,
  *                            currently 5 bits are used):
  *                            - only local
  *                            - only remote
  *                            - login is counted per process ID
  *                            - disable terminal server check
  *                            - enable access to old (HASP3/HASP4) keys
  **/
  public Hasp(long feature_id){
    status = HaspStatus.HASP_STATUS_OK;
    featureid = feature_id;
    handle[0]=0;
  }

 /**
  *  Login into a feature.
  *
  *  This function establishes a context (logs into a feature).
  *
  *  @param vendor_code      - pointer to the vendor code
  *
  *  @return     TRUE/FALSE = function succeed/failed
  *
  *  @see  #logout
  *  @see  #getLastError for error code
  *
  */

  public boolean login(String vendor_code){
    status = Hasp.Login(featureid,vendor_code.getBytes(),handle);
    return (status == HaspStatus.HASP_STATUS_OK);
  }

 /**
  *  Logs out from a session and frees all allocated resources for the session.
  *
  *  @param handle       - handle of session to log out from
  *
  *  @return     TRUE/FALSE = function succeed/failed
  *
  *  @see  #login
  *  @see  #getLastError for error code
  *
  */
  public boolean logout(){
    status = Hasp.Logout(handle[0]);
    return (status == HaspStatus.HASP_STATUS_OK);
  }

 /** 
  *
  *  This function encrypts a buffer. If the encryption fails (e.g. key removed in-between) the 
  *  data pointed to by buffer is unmodified.
  *
  *  @param buffer      - pointer to the buffer to be encrypted
  *  @param length      - size in bytes of the buffer to be encrypted (16 bytes minimum)
  *
  *  @return     TRUE/FALSE = function succeed/failed
  *
  *  @see #decrypt
  *  @see #getLastError for error code
  */
  public boolean encrypt(byte[] buffer,int length){
    status = Hasp.Encrypt(handle[0],buffer,length);
    return (status == HaspStatus.HASP_STATUS_OK);
  }
    
 /** \brief Decrypt a buffer.
  *
  *  This function decrypts a buffer. This is the reverse operation of the
  *  encrypt() function. @See encrypt() for more information.
  *  If the decryption fails (e.g. key removed in-between) the data pointed 
  *  to by buffer is unmodified.
  *
  *  @param buffer      - pointer to the buffer to be decrypted
  *  @param length      - size in bytes of the buffer to be decrypted (16 bytes minimum)
  *
  *  @return     TRUE/FALSE = function succeed/failed
  *
  *  @see #encrypt
  */
  public boolean decrypt(byte[] buffer,int length){
    status = Hasp.Decrypt(handle[0],buffer,length);
    return (status == HaspStatus.HASP_STATUS_OK);
  }

 /** 
  *  Get information in a session context.
  *
  *  @param      format       - XML definition of the output data structure
  *  @return     info         - pointer to the returned information (XML list)
  *
  *  @see  #getLastError for error code
  */
  public String getSessionInfo(String format){
    byte[] info={0};
    int[] status1 = {0};
    String s=null;

    info = Hasp.GetSessioninfo(handle[0], format.getBytes(),status1);

    status = status1[0];
    if( status == HaspStatus.HASP_STATUS_OK)
      s = new String(info);
  
    return s;
  }

 /**
  *  This function is used to read from the key memory.
  *  Valid fileids are HASP_FILEID_LICENSE and HASP_FILEID_MAIN.
  *
  *  @param      fileid       - id of the file to read (memory descriptor)
  *  @param      offset       - position in the file
  *  @param      length       - number of bytes to read
  *  @param      buffer       - result of the read operation
  *
  *  @return     TRUE/FALSE = function succeed/failed
  *
  *  @see  #getLastError for error code
  *  @see  #write
  *  @see  #getSize
  */
  public boolean read(int fileid, int offset,int length,byte[] buffer){
    status = Hasp.Read(handle[0],fileid,offset,length,buffer);
    return (status == HaspStatus.HASP_STATUS_OK);
  }

 /**
  *
  *  This function is used to write to the key memory. Depending on the provided
  *  session handle (either logged into the default feature or any other feature),
  *  write access to the FAS memory (HASP_FILEID_LICENSE) is not permitted.
  *
  *  @param      fileid       - id of the file to write
  *  @param      offset       - position in the file
  *  @param      length       - number of bytes to write
  *  @param      buffer       - what to write
  *
  *  @return     TRUE/FALSE = function succeed/failed
  *
  *  @see  #getLastError for error code
  *  @see  #read
  *  @see  #getSize
  */
  public boolean write(int fileid, int offset,int length,byte[] buffer){
    status = Hasp.Write(handle[0],fileid,offset,length,buffer);
    return (status == HaspStatus.HASP_STATUS_OK);
  }

 /** 
  *
  *  This function is used to determine the memory size.
  *  Valid fileids are HASP_FILEID_LICENSE and HASP_FILEID_MAIN.
  *
  *  @param      fileid       - id of the file to query
  *  @param      size         - pointer to the resulting file size
  *
  *  @return     size of memory
  *
  *
  *  @see  #getLastError for error code
  *  @see  #read
  *  @see  #write
  */
  public int getSize(int fileid){
    int[] size = {0};
    status = Hasp.GetSize(handle[0],fileid,size);    
    return size[0];
  }


 /**
  *
  *  This function writes update information. The update blob contains all necessary data
  *  to perform the update: Where to write (in which "container", e.g. dongle), the necessary
  *  access data (vendor code) and of course the update itself.
  *  If the update blob requested it, the function returns in an acknowledge blob,
  *  which is signed/encrypted by the updated instance and contains a proof that this update
  *  was successfully installed. Update via LM is not supported.
  *
  *  @param      update_data      - pointer to the complete update data.
  *
  *  @return     ack_data         - pointer to a buffer to get the acknowledge data.
  *
  *  @see #getLastError for error code
  */
  public String update(byte update_data[]){
    byte[] ack_data={0};
    int[] dll_status = {0};
    String s = null;

    ack_data = Hasp.Update(update_data,dll_status);
    status = dll_status[0];
     
    if(status == HaspStatus.HASP_STATUS_OK && ack_data != null)
      s = new String(ack_data);

    return s;
  }
  
 /** 
  *
  *  This function reads the current time from a time key.
  *  The time will be returned in seconds since Jan-01-1970 0:00:00 GMT.
  *
  *  The general purpose of this function is not related to licensing, but 
  *  to get reliable timestamps which are independent from the system clock.
  *  <p>
  *  This request is only supported on locally accessed keys. Trying to
  *  get the time from a remotely accessed key will return HASP_NO_TIME.
  *
  *
  *  @return     HaspTime object
  *
  */
  public HaspTime getRealTimeClock(){
    long[] time={0};
    HaspTime rtcTime;
    status = Hasp.GetRtc(handle[0],time);
    rtcTime = new HaspTime(time[0]);
    if( status == HaspStatus.HASP_STATUS_OK )
      status = rtcTime.getLastError();
    return rtcTime;
  }
}



