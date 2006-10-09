using System;
using System.Collections.Generic;
using System.Text;
using System.Runtime.InteropServices;

namespace Switcher
{

     class PROCESSENTRY32
    {
        // constants for structure definition
        private const int SizeOffset = 0;
        private const int UsageOffset = 4;
        private const int ProcessIDOffset = 8;
        private const int DefaultHeapIDOffset = 12;
        private const int ModuleIDOffset = 16;
        private const int ThreadsOffset = 20;
        private const int ParentProcessIDOffset = 24;
        private const int PriClassBaseOffset = 28;
        private const int dwFlagsOffset = 32;
        private const int ExeFileOffset = 36;
        private const int MemoryBaseOffset = 556;
        private const int AccessKeyOffset = 560;
        private const int Size = 564; // the whole size of the structure
        private const int MAX_PATH = 260;

        // data members
        public uint dwSize;
        public uint cntUsage;
        public uint th32ProcessID;
        public uint th32DefaultHeapID;
        public uint th32ModuleID;
        public uint cntThreads;
        public uint th32ParentProcessID;
        public int pcPriClassBase;
        public uint dwFlags;
        public string szExeFile;
        public uint th32MemoryBase;
        public uint th32AccessKey;


        // utility:  get a uint from the byte array
        private static uint GetUInt(byte[] aData, int Offset)
        {
            return BitConverter.ToUInt32(aData, Offset);
        }

        // utility:  set a uint into the byte array
        private static void SetUInt(byte[] aData, int Offset, int Value)
        {
            byte[] buint = BitConverter.GetBytes(Value);
            Buffer.BlockCopy(buint, 0, aData, Offset, buint.Length);
        }
        // utility:  get a ushort from the byte array
        private static ushort GetUShort(byte[] aData, int Offset)
        {
            return BitConverter.ToUInt16(aData, Offset);
        }

        // utility:  set a ushort int the byte array
        private static void SetUShort(byte[] aData, int Offset, int Value)
        {
            byte[] bushort = BitConverter.GetBytes((short)Value);
            Buffer.BlockCopy(bushort, 0, aData, Offset, bushort.Length);
        }

        // utility:  get a unicode string from the byte array
        private static string GetString(byte[] aData, int Offset, int Length)
        {
            String sReturn = Encoding.Unicode.GetString(aData, Offset, Length);
            return sReturn;
        }

        // utility:  set a unicode string in the byte array
        private static void SetString(byte[] aData, int Offset, string Value)
        {
            byte[] arr = Encoding.ASCII.GetBytes(Value);
            Buffer.BlockCopy(arr, 0, aData, Offset, arr.Length);
        }
         public PROCESSENTRY32()
         { 
         }
        // create a PROCESSENTRY instance based on a byte array      
        public PROCESSENTRY32(byte[] aData)
        {
            dwSize = GetUInt(aData, SizeOffset);
            cntUsage = GetUInt(aData, UsageOffset);
            th32ProcessID = GetUInt(aData, ProcessIDOffset);
            th32DefaultHeapID = GetUInt(aData, DefaultHeapIDOffset);
            th32ModuleID = GetUInt(aData, ModuleIDOffset);
            cntThreads = GetUInt(aData, ThreadsOffset);
            th32ParentProcessID = GetUInt(aData, ParentProcessIDOffset);
            pcPriClassBase = (int)GetUInt(aData, PriClassBaseOffset);
            dwFlags = GetUInt(aData, dwFlagsOffset);
            szExeFile = GetString(aData, ExeFileOffset, MAX_PATH);
            th32MemoryBase = GetUInt(aData, MemoryBaseOffset);
            th32AccessKey = GetUInt(aData, AccessKeyOffset);
        }

        // create an initialized data array
        public byte[] ToByteArray()
        {
            byte[] aData;
            aData = new byte[Size];
            //set the Size member
            SetUInt(aData, SizeOffset, Size);
            return aData;
        }

        public string Name
        {
            get
            {
                return szExeFile.Substring(0, szExeFile.IndexOf('\0'));
            }
        }

        public ulong PID
        {
            get
            {
                return th32ProcessID;
            }
        }

        public ulong BaseAddress
        {
            get
            {
                return th32MemoryBase;
            }
        }

        public ulong ThreadCount
        {
            get
            {
                return cntThreads;
            }
        }

        private const int TH32CS_SNAPPROCESS = 0x00000002;
        [DllImport("toolhelp.dll")]
        public static extern IntPtr CreateToolhelp32Snapshot(uint flags, uint processid);
        [DllImport("toolhelp.dll")]
        public static extern int CloseToolhelp32Snapshot(IntPtr handle);
        [DllImport("toolhelp.dll")]
        public static extern int Process32First(IntPtr handle, byte[] pe);
        [DllImport("toolhelp.dll")]
        public static extern int Process32Next(IntPtr handle, byte[] pe);
        [DllImport("coredll.dll")]
        private static extern IntPtr OpenProcess(int flags, bool fInherit, int PID);
        private const int PROCESS_TERMINATE = 1;
        [DllImport("coredll.dll")]
        private static extern bool TerminateProcess(IntPtr hProcess, uint ExitCode);
        [DllImport("coredll.dll")]
        private static extern bool CloseHandle(IntPtr handle);
        private const int INVALID_HANDLE_VALUE = -1;
        [DllImport("coredll.dll")]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool SetForegroundWindow(IntPtr handle);
        [DllImport("coredll.dll")]
        private static extern IntPtr GetForegroundWindow();


    }



}
