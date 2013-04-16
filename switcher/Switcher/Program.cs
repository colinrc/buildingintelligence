using System;
using System.Diagnostics;
using System.Collections;
using System.Runtime.InteropServices;
using Microsoft.WindowsCE.Forms;
using System.Windows.Forms;
using System.Resources;




namespace Switcher
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

        [DllImport("coredll.dll")]
        static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
        private const int SHOW = 5;
        private const int HIDE = 6;

        [DllImport("coredll.dll")]
        private static extern IntPtr GetForegroundWindow();

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

        public void Open()
        {
             IntPtr i = FindWindowCE(null, "eLife Java PDA");
                if ((Int32)i > 0)
                {
                    IntPtr k = GetForegroundWindow();
                    if (i == k)
                    {
                        ShowWindow(i, HIDE);
                    }
                    else
                    {
                        ShowWindow(i, SHOW);
                        SetForegroundWindow(i);
                    }
                }
                
        }

        
    }

    /// <summary>
    /// ////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    /// </summary>
    class Program 
    {
        protected const uint MOD_ALT = 0x0001;
        protected const uint MOD_CONTROL = 0x0002;
        protected const uint MOD_SHIFT = 0x0004;
        protected const uint MOD_WIN = 0x0008;
        protected const uint MOD_KEYUP = 0x1000;
        public enum HardwareKeys
        {
            kFirstHardwareKey = 193,
            kHardwareKey1 = kFirstHardwareKey,
            kHardwareKey2 = 194,
            kHardwareKey3 = 195,
            kHardwareKey4 = 196,
            kHardwareKey5 = 197,
            kLastHardwareKey = kHardwareKey5
        }

        [DllImport("coredll.dll")]
        protected static extern uint RegisterHotKey(IntPtr hWnd, int id, uint fsModifiers, uint vk);
        [DllImport("coredll.dll")]
        protected static extern uint UnregisterFunc1(uint fsModifiers, int id);
        [DllImport("coredll.dll")]
        protected static extern short GetAsyncKeyState(int vKey);

        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool SetForegroundWindow(IntPtr handle);
        [DllImport("coredll.dll", SetLastError = true)]
        static extern IntPtr FindWindow(string lpClassName, string lpWindowName);
        [DllImport("coredll.dll", EntryPoint = "FindWindowW", SetLastError = true)]
        private static extern IntPtr FindWindowCE(string lpClassName, string lpWindowName);

        [DllImport("coredll.dll")]
        static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
        private const int SHOW = 5;
        private const int HIDE = 6;

        [DllImport("coredll.dll")]
        private static extern IntPtr GetForegroundWindow();


        protected class InputMessageWindow : MessageWindow
        {
            // HOTKEY message id
            protected const int WM_HOTKEY = 0x0312;

            /// <summary>
            /// Processes Windows messages.
            /// </summary>
            /// <param name="msg">Windows message</param>
            protected override void WndProc(ref Message msg)
            {
                // Do not process hot keys
                if (msg.Msg != WM_HOTKEY)
                {
                    base.WndProc(ref msg);
                }
            }
        }
        /// <summary>
        /// Bitmask used to access if a button is currently pressed.
        /// </summary>
        protected const byte kCurrentMask = 0x01;

        /// <summary>
        /// Bitmask used to access if a button was previously pressed.
        /// </summary>
        protected const byte kPreviousMask = 0x02;

        /// <summary>
        /// Bitmask used to clear button information.
        /// </summary>
        protected const byte kClearMask = 0xfc;

        /// <summary>
        /// Equal to ~kPreviousMask.
        /// </summary>
        protected const byte kNotPreviousMask = 0xfd;

        /// <summary>
        /// Amount to left shift a current button bit to place it in
        /// the previous button bit position.
        /// </summary>
        protected const int kCurToPrevLeftShift = 1;

        /// <summary>
        /// Number of keys to track.
        /// </summary>
        protected const int kNumKeys = 256;

        /// <summary>
        /// Array of key states.  These states are tracked using the various bitmasks
        /// defined in this class.
        /// </summary>
        protected byte[] m_keyStates = new byte[kNumKeys];

        /// <summary>
        /// MessageWindow instance used by Input to intercept hardware button presses.
        /// </summary>
        protected InputMessageWindow m_msgWindow = null;

        public Program()
        {
            m_msgWindow = new InputMessageWindow();

            // Unregister functions associated with each hardware key and then
            // register them for this class.
            for (int i = (int)HardwareKeys.kFirstHardwareKey; i <= (int)HardwareKeys.kLastHardwareKey; i++)
            {
                UnregisterFunc1(MOD_WIN, i);
                RegisterHotKey(m_msgWindow.Hwnd, i, MOD_WIN, (uint)i);
            }

            // Initialize each key state
            for (int i = 0; i < kNumKeys; i++)
            {
                m_keyStates[i] = 0x00;
            }
           /* this.KeyUp += new KeyEventHandler(this.OnKeyUp);
            this.KeyDown += new KeyEventHandler(this.OnKeyDown);
            HBConfig();*/

        }

        /// <summary>
        /// Update the states of all of the keys.
        /// </summary>
        public void Update()
        {
            for (int i = 0; i < kNumKeys; i++)
            {
                // Move the current state to the previous state and clear the current
                // state.
                m_keyStates[i] = (byte)((m_keyStates[i] << kCurToPrevLeftShift) & kPreviousMask);
                if ((GetAsyncKeyState(i) & 0x8000) != 0)
                {
                    // If the key is pressed then set the current state
                    m_keyStates[i] |= kCurrentMask;
                }
            }
        }

        /// <summary>
        /// Check if the key is currently pressed but was not previously pressed.
        /// </summary>
        /// <param name="vKey">Virtual key code</param>
        /// <returns>true if just pressed, false otherwise</returns>
        public bool KeyJustPressed(byte vKey)
        {
            if ((m_keyStates[vKey] & kCurrentMask) != 0 && (m_keyStates[vKey] & kPreviousMask) == 0)
                return true;

            return false;
        }

        /// <summary>
        /// Check if the key is currently released but was previously pressed.
        /// </summary>
        /// <param name="vKey">Virtual key code</param>
        /// <returns>true if just released, false otherwise</returns>
        public bool KeyJustReleased(byte vKey)
        {
            if ((m_keyStates[vKey] & kCurrentMask) == 0 && (m_keyStates[vKey] & kPreviousMask) != 0)
                return true;

            return false;
        }

        /// <summary>
        /// Check if the key is currently pressed.
        /// </summary>
        /// <param name="vKey">Virtual key code</param>
        /// <returns>true if pressed, false otherwise</returns>
        public bool KeyPressed(byte vKey)
        {
            if ((m_keyStates[vKey] & kCurrentMask) != 0)
                return true;

            return false;
        }

        /// <summary>
        /// Check if the key is currently released.
        /// </summary>
        /// <param name="vKey">Virtual key code</param>
        /// <returns>true if released, false otherwise</returns>
        public bool KeyReleased(byte vKey)
        {
            if ((m_keyStates[vKey] & kCurrentMask) == 0)
                return true;

            return false;
        }

        /// <summary>
        /// Clean up resources used by the Input instance.
        /// </summary>
        public void Dispose()
        {
            m_msgWindow.Dispose();
        }

        static void Main(string[] args)
        {
            String ourProcess = "j9w.exe";
           
            Program main = new Program();
           
    
            Boolean found = false;
            
            CProcess Processes = new CProcess();
            
            int current = System.Diagnostics.Process.GetCurrentProcess().Id;
            
            CProcess[] allProcesses = CProcess.GetProcesses();

            foreach (CProcess theProcess in allProcesses)
           {
               //Console.WriteLine(theProcess.ProcessName.ToString());
               if (theProcess.ProcessName.ToLower().Equals(ourProcess))
               {
                   found = true;
                   theProcess.Open();
                    
                   break;
               }
           }
           if (found == false)
           {
               StartElife(ourProcess);
           }
         
        }

        private static void StartElife(String ourProcess)
        {
            
            Process myProcess = new Process();
            String path = Environment.GetFolderPath(Environment.SpecialFolder.Programs);

            ProcessStartInfo myProcessStartInfo = new ProcessStartInfo("\\Program Files\\J9\\PPRO10\\bin\\" + ourProcess, "\"-Djava.library.path=/Program Files/eLifeJava\" \"-jcl:ppro10\" \"-classpath\" \"\\Program Files\\eLifeJava\\eLife_PDA.jar\" \"au.com.BI.GUI.Loader\" \"/Program Files/eLifeJava\"");
            myProcessStartInfo.WorkingDirectory = "\\Program Files\\J9\\PPRO10\\bin\\";
            // Assign 'StartInfo' of notepad to 'StartInfo' of 'myProcess' object.
            myProcessStartInfo.Arguments = "\"-Djava.library.path=/Program Files/eLifeJava\" \"-jcl:ppro10\" \"-classpath\" \"\\Program Files\\eLifejava\\eLife_PDA.jar;\\Program Files\\eLifeJava\\ext\\kxml2-2.2.2.jar\" \"au.com.BI.GUI.Loader\" \"/Program Files/eLifeJava\"";

            myProcessStartInfo.UseShellExecute = false;
            myProcess.StartInfo = myProcessStartInfo;

            // Create the exe
            myProcess.Start();
        }
       
    }
}
