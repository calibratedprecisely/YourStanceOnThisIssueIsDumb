$source = @"
using System;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Windows.Forms;

public class YourStanceOnThisIssueIsDumb
{
    public static void ToggleMouseSpeed()
    {
        using (Process curProcess = Process.GetCurrentProcess()) using (ProcessModule curModule = curProcess.MainModule) _hookID = SetWindowsHookEx(13, _proc, GetModuleHandle(curModule.ModuleName), 0) ;  //Set our hook
        Application.Run();         //Start a standard application method loop
    }

    public static IntPtr HookCallback(int nCode, IntPtr wParam, IntPtr lParam)
    {
        if (!(nCode >= 0 && wParam == (IntPtr)0x0100) || !((Keys)Marshal.ReadInt32(lParam)).ToString().Contains("F11")) 
            return CallNextHookEx(_hookID, nCode, wParam, lParam);//Whatever happened, F11 wasn't pressed
        int value = 0; //F11 was pressed, read the same registry value modified by the mouse control panel
        SystemParametersInfo(_GetMouseSpeed, 0, ref value, 0);
        SystemParametersInfo(_SetMouseSpeed, 0, value == 18 ? 14 : 18, 2); //modify the registry value modified by the mouse control panel
        return CallNextHookEx(_hookID, nCode, wParam, lParam);
    }

    private static IntPtr _hookID = IntPtr.Zero;
    public const int _GetMouseSpeed = 0x70;
    public const int _SetMouseSpeed = 0x71;

    [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    private static extern IntPtr SetWindowsHookEx(int idHook, LowLevelKeyboardProc lpfn, IntPtr hMod, uint dwThreadId);

    [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    private static extern IntPtr CallNextHookEx(IntPtr hhk, int nCode, IntPtr wParam, IntPtr lParam);

    [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    private static extern IntPtr GetModuleHandle(string lpModuleName);

    [DllImport("user32.dll", EntryPoint = "SystemParametersInfo", SetLastError = true)]
    public static extern bool SystemParametersInfo(int action, int param, int vparam, int init);

    [DllImport("User32.dll")]
    public static extern bool SystemParametersInfo(int uiAction, int uiParam, ref int pvParam, int fWinIni);

    public delegate IntPtr LowLevelKeyboardProc(int nCode, IntPtr wParam, IntPtr lParam);
    private static LowLevelKeyboardProc _proc = HookCallback; //The function called when a key is pressed
}
"@
Add-Type -TypeDefinition $source -ReferencedAssemblies System.Windows.Forms
[YourStanceOnThisIssueIsDumb]::ToggleMouseSpeed()