using System;
using System.Diagnostics;
using System.Collections;
using System.Runtime.InteropServices;
using Microsoft.WindowsCE.Forms;
using System.Windows.Forms;
using System.Resources;
using System.Reflection;



namespace eLifeTerminate
{

    public class CProcess
    {
        private int current;
        private string processName;
        private IntPtr handle;
        private int threadCount;
        private int baseAddress;
       
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
        private const int ALL = 2035711;
        [DllImport("coredll.dll")]
        private static extern bool TerminateProcess(IntPtr hProcess, uint ExitCode);
        [DllImport("coredll.dll")]
        private static extern bool CloseHandle(IntPtr handle);
        private const int INVALID_HANDLE_VALUE = -1;
        [DllImport("coredll.dll")]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool SetForegroundWindow(IntPtr handle);
        [DllImport("coredll.dll", SetLastError = true)]
        static extern IntPtr FindWindow(string lpClassName, string lpWindowName);
        [DllImport("coredll.dll", EntryPoint = "FindWindowW", SetLastError = true)]
        private static extern IntPtr FindWindowCE(string lpClassName, string lpWindowName);

        //default constructor
        public CProcess()
        {

        }

        public string ProcessName
        {
            get
            {
                return processName;
            }
        }
        public int Current
        {
            get
            {
                return current;
            }
            set
            {
                current = value;
            }
        }
        public override string ToString()
        {
            return processName;
        }

        public int BaseAddress
        {
            get
            {
                return baseAddress;
            }
        }

        public int ThreadCount
        {
            get
            {
                return threadCount;
            }
        }

        public IntPtr Handle
        {
            get
            {
                return handle;
            }
        }

        public int BaseAddess
        {
            get
            {
                return baseAddress;
            }
        }

        //private helper constructor
        private CProcess(IntPtr id, string procname, int threadcount, int baseaddress)
        {
            handle = id;
            processName = procname;
            threadCount = threadcount;
            baseAddress = baseaddress;
        }

        public static CProcess[] GetProcesses()
        {
            //temp ArrayList
            ArrayList procList = new ArrayList();

            IntPtr handle = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);

            if ((int)handle > 0)
            {
                try
                {
                    PROCESSENTRY32 peCurrent;
                    PROCESSENTRY32 pe32 = new PROCESSENTRY32();
                    //Get byte array to pass to the API calls
                    byte[] peBytes = pe32.ToByteArray();
                    //Get the first process
                    int retval = Process32First(handle, peBytes);
                    while (retval == 1)
                    {
                        //Convert bytes to the class
                        peCurrent = new PROCESSENTRY32(peBytes);
                        //New instance of the Process class
                        CProcess proc = new CProcess(new IntPtr((int)peCurrent.PID),
                                       peCurrent.Name, (int)peCurrent.ThreadCount,
                                       (int)peCurrent.BaseAddress);

                        procList.Add(proc);

                        retval = Process32Next(handle, peBytes);
                    }
                }
                catch (Exception ex)
                {
                    throw new Exception("Exception: " + ex.Message);
                }
                //Close handle
                CloseToolhelp32Snapshot(handle);

                return (CProcess[])procList.ToArray(typeof(CProcess));

            }
            else
            {
                throw new Exception("Unable to create snapshot");
            }
        }

        public void Kill()
        {
            try
            {
                IntPtr hProcess;
                hProcess = OpenProcess(PROCESS_TERMINATE, false, (int)handle);
                if (hProcess != (IntPtr)INVALID_HANDLE_VALUE)
                {
                    bool bRet;
                    bRet = TerminateProcess(hProcess, 0);
                    CloseHandle(hProcess);                 
                }
            }
            catch (Exception ex)
            {
                throw new Exception("Exception: " + ex.Message);
            }

        }

    }

    /// <summary>
    /// ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /// </summary>
    class Program 
    {
        
        static void Main(string[] args)
        {
            String ourProcess = "j9w.exe";
           
            Program main = new Program();
                       
            CProcess Processes = new CProcess();
            int current = System.Diagnostics.Process.GetCurrentProcess().Id;
            
            CProcess[] allProcesses = CProcess.GetProcesses();

            foreach (CProcess theProcess in allProcesses)
            {
                //Console.WriteLine(theProcess.ProcessName.ToString());
                if (theProcess.ProcessName.ToLower().Equals(ourProcess))
                {
                    theProcess.Kill();
                    break;
                }
            }
        }
    }
}
