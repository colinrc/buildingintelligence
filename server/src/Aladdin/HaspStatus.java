package Aladdin;
/*
 *  $Id: HaspStatus.java,v 1.1 2005/10/24 14:01:09 colinc Exp $
 *
 *  Copyright 2004 Aladdin Knowledge Systems Ltd. All rights reserved.
 *  Use is subject to license terms.
 */



public class HaspStatus{
  /**
   * return codes 
   */

  /**
   * no error occurred 
   */
  public static final int HASP_STATUS_OK              = 0;   

  /**
   * invalid memory address 
   */
  public static final int HASP_MEM_RANGE              = 1;   

  /**
   * unknown/invalid feature id option 
   */
  public static final int HASP_INV_PROGNUM_OPT        = 2;   
  
  /**
   * memory allocation failed 
   */
  public static final int HASP_INSUF_MEM              = 3;   

  /**
   * too many open features 
   */
  public static final int HASP_TMOF                   = 4;   

  /**
   * feature access denied 
   */
  public static final int HASP_ACCESS_DENIED          = 5;   

  /**
   * incompatible feature 
   */
  public static final int HASP_INCOMPAT_FEATURE       = 6;   

  /** 
   * license container not found 
   */
  public static final int HASP_CONTAINER_NOT_FOUND    = 7;   

  /**
   * en-/decryption length too short 
   */
  public static final int HASP_TOO_SHORT              = 8;   

  /**
   * invalid handle 
   */
  public static final int HASP_INV_HND                = 9;   

  /** invalid file id / memory descriptor 
   * 
   */
  public static final int HASP_INV_FILEID             = 10;  

  /** driver or support daemon version too old 
   *
   */
  public static final int HASP_OLD_DRIVER             = 11;  

  /**
   * real time support not available 
   */
  public static final int HASP_NO_TIME                = 12;  

  /**
   * generic error from host system call 
   */
  public static final int HASP_SYS_ERR                = 13;  

  /**
   * hardware key driver not found 
   */
  public static final int HASP_NO_DRIVER              = 14;  

  /**
   * unrecognized info format 
   */
  public static final int HASP_INV_FORMAT             = 15;  

  /** 
   * request not supported 
   */

  public static final int HASP_REQ_NOT_SUPP           = 16;  

  /**
   * invalid update object
   */
  public static final int HASP_INV_UPDATE_OBJ         = 17;  

  /**
   * key with requested id was not found 
   */
  public static final int HASP_KEYID_NOT_FOUND        = 18;  

  /** 
   * update data consistency check failed 
   */
  public static final int HASP_INV_UPDATE_DATA        = 19; 
  /**
   * update not supported by this key 
   */
  public static final int HASP_INV_UPDATE_NOTSUPP     = 20; 
  /**
   * update counter mismatch 
   */
  public static final int HASP_INV_UPDATE_CNTR        = 21; 
  /**
   * invalid vendor code 
   */
  public static final int HASP_INV_VCODE              = 22; 
  /**
   * requested encryption algorithm not supported 
   */
  public static final int HASP_ENC_NOT_SUPP           = 23;  
  /**
   * invalid date / time 
   */
  public static final int HASP_INV_TIME               = 24;  
  /**
   * clock has no power  
   */
  public static final int HASP_NO_BATTERY_POWER       = 25;  
  /**
   * update requested acknowledgement, but no area to return it 
   */
  public static final int HASP_NO_ACK_SPACE           = 26;  
  /**
   * terminal services (remote terminal) detected 
   */
  public static final int HASP_TS_DETECTED            = 27;  
  /**
   * feature type not implemented 
   */
  public static final int HASP_FEATURE_TYPE_NOT_IMPL  = 28;  
  /**
   * unknown algorithm 
   */
  public static final int HASP_UNKNOWN_ALG            = 29;  
  /** 
   * signature check failed 
   */
  public static final int HASP_INV_SIG                = 30;  
  /**
   * feature not found 
   */
  public static final int HASP_FEATURE_NOT_FOUND      = 31;  

  /* c++ use  */
  public static final int HASP_INVALID_OBJECT         = 500;
  public static final int HASP_INVALID_PARAMETER      = 501;
  public static final int HASP_ALREADY_LOGGED_IN      = 502;
  public static final int HASP_ALREADY_LOGGED_OUT     = 503;

  /* .net use */
  public static final int HASP_OPERATION_FAILED       = 525;

  /* inside-api use */
  public static final int HASP_NO_EXTBLOCK            = 600;  /* no classic memory extension block available */

  /* catch-all */
  public static final int HASP_NOT_IMPL               = 698;  /* capability isn't available */
  public static final int HASP_INT_ERR                = 699;  /* internal API error */
}

