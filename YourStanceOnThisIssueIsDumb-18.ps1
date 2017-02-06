$source = @"
using System.Runtime.InteropServices;
public class mouse
{
    public const int SetMouseSpeed = 113;
    public const int UpdateIniFile = 1;
    public const int SendWinIniChange = 2;

    [DllImport("user32.dll", EntryPoint="SystemParametersInfo", SetLastError = true)]
    public static extern bool SystemParametersInfo (int action, int param, int vparam, int init);

    public static void SetSensitivity ( int sensitivity )
    {
        SystemParametersInfo(SetMouseSpeed, 0, sensitivity, SendWinIniChange);
    }
}
"@
Add-Type -TypeDefinition $source
[mouse]::SetSensitivity(18)