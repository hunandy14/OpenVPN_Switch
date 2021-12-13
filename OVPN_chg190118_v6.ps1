[CmdletBinding()]
param (
    [switch] $Disconnect,
    [switch] $Switch,
    [switch] $Info,
    [switch] $Load
)
function __Openvpn_NetAdapter__ {
    return (Get-NetAdapter -InterfaceDescription "TAP-Windows Adapter V9")
}function __Openvpn_Status__ {
    return ($(__Openvpn_NetAdapter__).Status -eq "Up")
}
function OVPN_chg190118_v6 {
    param (
        [switch] $Disconnect,
        [switch] $Info
    )
    if ($Info) {
        $ms_tcpip6 = (Get-NetAdapterBinding -Com:ms_tcpip6) | Select-Object Name, @{Name='IPv6'; Expression='Enabled'}
        $ms_tcpip4 = (Get-NetAdapterBinding -Com:ms_tcpip) | Select-Object Name, @{Name='IPv4'; Expression='Enabled'}
        $ms_tcpip4 | LeftJoin $ms_tcpip6 -On Name | Out-Default
    } else {
        $ovpn        = "C:\Program Files\OpenVPN\bin\openvpn-gui.exe"
        $ovpnSetting = "chg190118_v6.ovpn"
        
        if ($Disconnect) {
            .$ovpn --command disconnect $ovpnSetting
            Get-NetAdapterBinding -ComponentID:ms_tcpip6| Out-Null | Where-Object{!$_.Enabled} | ForEach-Object{Enable-NetAdapterBinding -Name:$_.Name -ComponentID:ms_tcpip6;$_}
            while (__Openvpn_Status__) {
                Write-Host "openVPN DisConnecting..."
                Start-Sleep -s 1
            }
        } else {
            if (!(__Openvpn_Status__)){
                $job = Start-Job { ((Get-NetConnectionProfile).InterfaceAlias | ForEach-Object{ Disable-NetAdapterBinding -ComponentID:ms_tcpip6 -Name:$_ }) }
                Wait-Job $job | Out-Null; Receive-Job $job
                .$ovpn --connect $ovpnSetting
                
                while (!(__Openvpn_Status__)) {
                    Write-Host "openVPN connecting..."
                    Start-Sleep -s 1
                }
            }
        }
    }
    $(__Openvpn_NetAdapter__) | Select-Object Name, InterfaceDescription, Status
}

function OVPN_chg190118_v6_Disconnect {
    OVPN_chg190118_v6 -Disconnect
}
function OVPN_chg190118_v6_Switch {
    if (__Openvpn_Status__) {
        OVPN_chg190118_v6 -Disconnect
    } else {
        OVPN_chg190118_v6
    }
}

function __main__ {
    if ($Load) {
        return
    } elseif ($Switch) {
        OVPN_chg190118_v6_Switch
    } elseif ($Disconnect) {
        OVPN_chg190118_v6_Disconnect
    } elseif ($Info) {
        OVPN_chg190118_v6 -Info:$Info
    } else {
        OVPN_chg190118_v6
    }
} __main__