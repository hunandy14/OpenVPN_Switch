[CmdletBinding()] param ()
function __Openvpn_Status__ {
    return ((Get-NetAdapter -InterfaceDescription "TAP-Windows Adapter V9").Status -eq "Up")
}
function __main__ {
    $ovpn        = "C:\Program Files\OpenVPN\bin\openvpn-gui.exe"
    $ovpnSetting = "chg190118_v6.ovpn"
    
    if (__Openvpn_Status__) {
        .$ovpn --command disconnect $ovpnSetting
        while (__Openvpn_Status__) {
            Write-Host "openVPN DisConnecting..."
            Start-Sleep -s 1
        }
    } else {
        .$ovpn --connect $ovpnSetting
        while (!(__Openvpn_Status__)) {
            Write-Host "openVPN connecting..."
            Start-Sleep -s 1
        }
    }    
} __main__