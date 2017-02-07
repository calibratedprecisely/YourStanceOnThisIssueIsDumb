$source = @"
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Windows.Forms;

public class YourStanceOnThisIssueIsDumb2
{
    public static void Main()
    {
        Actions.Add("OemOpenBrackets", "-1,+0"); //[
        Actions.Add("Oem6", "+1,+0"); //]
        Actions.Add("OemMinus", "+0,-1"); //-
        Actions.Add("Oemplus", "+0,+1"); //=
        Actions.Add("F12", "20,360");
        _hookID = SetHook(_proc);  //Set our hook
        Application.Run();         //Start a standard application method loop
    }

    [StructLayout(LayoutKind.Sequential)]
    public struct Mousekeys
    {
        public Int32 cbSize;
        public UInt32 dwFlags;
        public Int32 iMaxSpeed;
        public Int32 iTimeToMaxSpeed;
        public Int32 iCtrlSpeed;
        public Int32 dwReserved1;
        public Int32 dwReserved2;
    }

    public static Dictionary<string, string> Actions = new Dictionary<string, string>();

    public static void SetSpeed(Int32 a, Int32 b)
    {
        SetMouseSpeed(a); SetMousekeyMaxSpeed(b);
    }

    public static Int32 GetMouseSpeed()
    {
        Int32 value;
        return SystemParametersInfo(0x70, 0, out value, 0) ? value : value; //0x70 = SPI_GETMOUSESPEED
    }

    public static void SetMouseSpeed(Int32 speed)
    {
        SystemParametersInfo(0x71, 0, speed, 2); //0x71 = SPI_SETMOUSESPEED
    }

    public static Mousekeys GetMousekeys()
    {
        Mousekeys value = new Mousekeys { cbSize = Marshal.SizeOf<Mousekeys>() };
        return SystemParametersInfo(0x36, Marshal.SizeOf<Mousekeys>(), ref value, 0) ? value : value; //0x36 = SPI_GETMOUSEKEYS
    }

    public static void SetMousekeys(Mousekeys mousekeys)
    {
        SystemParametersInfo(0x37, Marshal.SizeOf<Mousekeys>(), ref mousekeys, 2); //0x37 = SPI_SETMOUSEKEYS
    }

    public static void SetMousekeyMaxSpeed(Int32 maxSpeed)
    {
        var v = GetMousekeys();
        v.iMaxSpeed = maxSpeed;
        SetMousekeys(v);
    }

    public static void HandleMouseSpeed(string action)
    {
        int parse;
        if (action.StartsWith("+"))
            SetMouseSpeed(GetMouseSpeed() + (int.TryParse(action.Split('+')[1], out parse) ? parse : parse));
        else if (action.StartsWith("-"))
            SetMouseSpeed(GetMouseSpeed() - (int.TryParse(action.Split('-')[1], out parse) ? parse : parse));
        else
            SetMouseSpeed(int.TryParse(action, out parse) ? parse : parse);
        Console.WriteLine("Set MouseSpeed to " + GetMouseSpeed());
    }

    public static void HandleMousekeyMaxSpeed(string action)
    {
        var k = GetMousekeys();
        int parse;
        if (action.StartsWith("+"))
            k.iMaxSpeed += (int.TryParse(action.Split('+')[1], out parse) ? parse : parse);
        else if (action.StartsWith("-"))
            k.iMaxSpeed -= (int.TryParse(action.Split('-')[1], out parse) ? parse : parse);
        else
            k.iMaxSpeed = (int.TryParse(action, out parse) ? parse : parse);
        SetMousekeys(k);
        Console.WriteLine("Set MousekeyMaxSpeed to " + k.iMaxSpeed);
    }
    public static IntPtr HookCallback(int nCode, IntPtr wParam, IntPtr lParam)
    {
        if (!(nCode >= 0 && wParam == (IntPtr)0x0100))
            return CallNextHookEx(_hookID, nCode, wParam, lParam);

        var key = ((Keys)Marshal.ReadInt32(lParam)).ToString();
        if (!Actions.ContainsKey(key))
            return CallNextHookEx(_hookID, nCode, wParam, lParam);
        Console.WriteLine("===============================");
        var actions = Actions[key].Split(',');
        HandleMouseSpeed(actions[0]);
        HandleMousekeyMaxSpeed(actions[1]);
        return CallNextHookEx(_hookID, nCode, wParam, lParam);
    }

    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SystemParametersInfo(Int32 uiAction, Int32 uiParam, ref Mousekeys pvParam, Int32 fWinIni);

    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SystemParametersInfo(Int32 uiAction, Int32 uiParam, Int32 pvParam, Int32 fWinIni);

    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SystemParametersInfo(Int32 uiAction, Int32 uiParam, out Int32 pvParam, Int32 fWinIni);
    [DllImport("user32.dll", SetLastError = true)]
    private static extern IntPtr SetWindowsHookEx(int idHook, LowLevelKeyboardProc lpfn, IntPtr hMod, uint dwThreadId);

    [DllImport("user32.dll", SetLastError = true)]
    private static extern IntPtr CallNextHookEx(IntPtr hhk, int nCode, IntPtr wParam, IntPtr lParam);

    [DllImport("kernel32.dll", SetLastError = true)]
    private static extern IntPtr GetModuleHandle(string lpModuleName);

    public delegate IntPtr LowLevelKeyboardProc(int nCode, IntPtr wParam, IntPtr lParam);
    private static IntPtr _hookID = IntPtr.Zero;
    private static LowLevelKeyboardProc _proc = HookCallback; //The function called when a key is pressed
    public static IntPtr SetHook(LowLevelKeyboardProc proc)
    {
        using (Process curProcess = Process.GetCurrentProcess()) using (ProcessModule curModule = curProcess.MainModule) return SetWindowsHookEx(13, proc, GetModuleHandle(curModule.ModuleName), 0);
    }
}
"@
Add-Type -TypeDefinition $source -ReferencedAssemblies System.Windows.Forms
[YourStanceOnThisIssueIsDumb2]::Main()