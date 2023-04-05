<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="windowsPE">
        <component name="Microsoft-Windows-International-Core-WinPE" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <SetupUILanguage>
                <UILanguage>${ vm_inst_os_language }</UILanguage>
                <WillShowUI>Never</WillShowUI>
            </SetupUILanguage>
            <InputLocale>${ vm_inst_os_keyboard }</InputLocale>
            <SystemLocale>${ vm_inst_os_language }</SystemLocale>
            <UILanguageFallback>${ vm_inst_os_language }</UILanguageFallback>
            <UserLocale>${ vm_inst_os_language }</UserLocale>
            <UILanguage>${ vm_inst_os_language }</UILanguage>
        </component>
        <component name="Microsoft-Windows-PnpCustomizationsWinPE" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <DriverPaths>
                <PathAndCredentials wcm:action="add" wcm:keyValue="1">
                    <Path>E:\Program Files\VMware\VMware Tools\Drivers\pvscsi\Win8\amd64</Path>
                </PathAndCredentials>
            </DriverPaths>
        </component>
        <component name="Microsoft-Windows-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <DiskConfiguration>
                <Disk wcm:action="add">
                    <CreatePartitions>
                        <CreatePartition wcm:action="add">
                            <Order>1</Order>
                            <Size>450</Size>
                            <Type>Primary</Type>
                        </CreatePartition>
                        <CreatePartition wcm:action="add">
                            <Order>3</Order>
                            <Size>16</Size>
                            <Type>MSR</Type>
                        </CreatePartition>
                        <CreatePartition wcm:action="add">
                            <Order>2</Order>
                            <Size>100</Size>
                            <Type>EFI</Type>
                        </CreatePartition>
                        <CreatePartition wcm:action="add">
                            <Order>4</Order>
                            <Extend>true</Extend>
                            <Type>Primary</Type>
                        </CreatePartition>
                    </CreatePartitions>
                    <ModifyPartitions>
                        <ModifyPartition wcm:action="add">
                            <Order>1</Order>
                            <Format>NTFS</Format>
                            <Label>WinRE</Label>
                            <PartitionID>1</PartitionID>
                            <TypeID>DE94BBA4-06D1-4D40-A16A-BFD50179D6AC</TypeID>
                        </ModifyPartition>
                        <ModifyPartition wcm:action="add">
                            <Order>2</Order>
                            <Format>FAT32</Format>
                            <Label>System</Label>
                            <PartitionID>2</PartitionID>
                        </ModifyPartition>
                        <ModifyPartition wcm:action="add">
                            <Order>3</Order>
                            <PartitionID>3</PartitionID>
                        </ModifyPartition>
                        <ModifyPartition wcm:action="add">
                            <Order>4</Order>
                            <Format>NTFS</Format>
                            <Label>Windows</Label>
                            <Letter>C</Letter>
                            <PartitionID>4</PartitionID>
                        </ModifyPartition>
                    </ModifyPartitions>
                    <DiskID>0</DiskID>
                    <WillWipeDisk>true</WillWipeDisk>
                </Disk>
            </DiskConfiguration>
            <ImageInstall>
                <OSImage>
                    <InstallFrom>
                        <MetaData wcm:action="add">
                            <Key>/IMAGE/NAME</Key>
                            <Value>${ vm_inst_os_image }</Value>
                        </MetaData>
                    </InstallFrom>
                    <InstallTo>
                        <DiskID>0</DiskID>
                        <PartitionID>4</PartitionID>
                    </InstallTo>
                </OSImage>
            </ImageInstall>
            <UserData>
                <AcceptEula>true</AcceptEula>
                <Organization>Example Org Inc</Organization>
                <ProductKey>
                    <Key>${ vm_inst_os_kms_key }</Key>
                    <WillShowUI>OnError</WillShowUI>
                </ProductKey>
            </UserData>
        </component>
    </settings>
    <settings pass="offlineServicing">
        <component name="Microsoft-Windows-LUA-Settings" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <EnableLUA>false</EnableLUA>
        </component>
    </settings>
    <settings pass="specialize">
        <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <OEMInformation>
                <Logo>C:\Windows\System32\oemlogo.bmp</Logo>
                <Manufacturer>Example Org Inc</Manufacturer>
                <SupportHours>24/7</SupportHours>
                <SupportPhone>48-1516-2342</SupportPhone>
                <SupportURL>https://example.service-now.com/</SupportURL>
            </OEMInformation>
            <CopyProfile>true</CopyProfile>
            <OEMName>Example Org Inc</OEMName>
            <RegisteredOrganization>Example Org Inc</RegisteredOrganization>
            <RegisteredOwner>LAB</RegisteredOwner>
            <TimeZone>${ vm_guest_os_timezone }</TimeZone>
            <ComputerName>${ vm_guest_os_hostname }</ComputerName>
        </component>
        <component name="Microsoft-Windows-ServerManager-SvrMgrNc" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <DoNotOpenServerManagerAtLogon>true</DoNotOpenServerManagerAtLogon>
        </component>
        <component name="Microsoft-Windows-OutOfBoxExperience" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <DoNotOpenInitialConfigurationTasksAtLogon>true</DoNotOpenInitialConfigurationTasksAtLogon>
        </component>
        <component name="Microsoft-Windows-Security-SPP-UX" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <SkipAutoActivation>true</SkipAutoActivation>
        </component>
        <component name="Microsoft-Windows-Deployment" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <RunSynchronous>
                <RunSynchronousCommand wcm:action="add">
                    <Description>Disable first logon animation 1 of 2</Description>
                    <Order>1</Order>
                    <Path>reg add HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System /v &quot;EnableFirstLogonAnimation&quot; /t REG_DWORD /d 0 /f</Path>
                </RunSynchronousCommand>
                <RunSynchronousCommand wcm:action="add">
                    <Description>Disable first logon animation 2 of 2</Description>
                    <Order>2</Order>
                    <Path>reg add HKLM\Software\Microsoft\Windows\Windows NT\CurrentVersion\Winlogon /v &quot;EnableFirstLogonAnimation&quot; /t REG_DWORD /d 0 /f</Path>
                </RunSynchronousCommand>
            </RunSynchronous>
        </component>
        <component name="Security-Malware-Windows-Defender" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <DisableAntiSpyware>true</DisableAntiSpyware>
        </component>
    </settings>
    <settings pass="oobeSystem">
        <component name="Microsoft-Windows-International-Core" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <InputLocale>${ vm_guest_os_keyboard }</InputLocale>
            <SystemLocale>${ vm_guest_os_language }</SystemLocale>
            <UILanguageFallback>${ vm_guest_os_language }</UILanguageFallback>
            <UserLocale>${ vm_guest_os_language }</UserLocale>
            <UILanguage>${ vm_guest_os_language }</UILanguage>
        </component>
        <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <AutoLogon>
                <Password>
                    <Value>${ build_password }</Value>
                    <PlainText>true</PlainText>
                </Password>
                <Enabled>true</Enabled>
                <LogonCount>3</LogonCount>
                <Username>${ build_username }</Username>
            </AutoLogon>
            <OOBE>
                <HideEULAPage>true</HideEULAPage>
                <HideLocalAccountScreen>true</HideLocalAccountScreen>
                <HideOEMRegistrationScreen>true</HideOEMRegistrationScreen>
                <HideOnlineAccountScreens>true</HideOnlineAccountScreens>
                <HideWirelessSetupInOOBE>true</HideWirelessSetupInOOBE>
                <ProtectYourPC>1</ProtectYourPC>
                <UnattendEnableRetailDemo>false</UnattendEnableRetailDemo>
            </OOBE>
            <UserAccounts>
                <AdministratorPassword>
                    <Value>${ build_password }</Value>
                    <PlainText>true</PlainText>
                </AdministratorPassword>
                <LocalAccounts>
                    <LocalAccount wcm:action="add">
                        <Password>
                            <Value>${ build_password }</Value>
                            <PlainText>true</PlainText>
                        </Password>
                        <Description>Main local admin</Description>
                        <DisplayName>${ build_username }</DisplayName>
                        <Name>${ build_username }</Name>
                        <Group>Administrators</Group>
                    </LocalAccount>
                </LocalAccounts>
            </UserAccounts>
            <TimeZone>${ vm_guest_os_timezone }</TimeZone>
            <RegisteredOrganization>Example Org Inc</RegisteredOrganization>
            <RegisteredOwner>LAB</RegisteredOwner>
            <FirstLogonCommands>
                <SynchronousCommand wcm:action="add">
                    <Description>Set Execution Policy 64-bit</Description>
                    <CommandLine>cmd.exe /c powershell -Command "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force"</CommandLine>
                    <Order>1</Order>
                </SynchronousCommand>
                <SynchronousCommand wcm:action="add">
                    <Description>Set Execution Policy 32-bit</Description>
                    <CommandLine>C:\Windows\SysWOW64\cmd.exe /c powershell -Command "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force"</CommandLine>
                    <Order>2</Order>
                </SynchronousCommand>
                <SynchronousCommand wcm:action="add">
                    <Description>Set local account to not expire</Description>
                    <CommandLine>cmd.exe /c wmic useraccount where "name='${ build_username }'" set PasswordExpires=FALSE</CommandLine>
                    <Order>3</Order>
                </SynchronousCommand>
                <SynchronousCommand wcm:action="add">
                    <Description>Disable network discovery</Description>
                    <CommandLine>cmd.exe /c a:\disable-network-discovery.cmd</CommandLine>
                    <Order>4</Order>
                </SynchronousCommand>
                <SynchronousCommand wcm:action="add">
                    <Description>Install VMware Tools</Description>
                    <CommandLine>cmd.exe /c powershell -File a:\Install-VMTools.ps1</CommandLine>
                    <Order>5</Order>
                </SynchronousCommand>
                <SynchronousCommand wcm:action="add">
                    <Description>Install .NET 3.5</Description>
                    <CommandLine>cmd.exe /c a:\install-dotnet35.cmd</CommandLine>
                    <Order>6</Order>
                </SynchronousCommand>
                <SynchronousCommand wcm:action="add">
                    <Description>Disable IPv6</Description>
                    <CommandLine>cmd.exe /c powershell -File a:\Disable-IPv6.ps1</CommandLine>
                    <Order>7</Order>
                </SynchronousCommand>
                <SynchronousCommand wcm:action="add">
                    <Description>Install certificates</Description>
                    <CommandLine>cmd.exe /c powershell -ExecutionPolicy Bypass -File a:\install-certs.ps1</CommandLine>
                    <Order>8</Order>
                </SynchronousCommand>
                <SynchronousCommand wcm:action="add">
                    <Description>Disable screensaver</Description>
                    <CommandLine>cmd.exe /c powershell -ExecutionPolicy Bypass -File a:\disable-screensaver.ps1</CommandLine>
                    <Order>9</Order>
                </SynchronousCommand>
                <SynchronousCommand wcm:action="add">
                    <Description>Run Windows updates</Description>
                    <CommandLine>cmd.exe /c powershell -File a:\win-updates.ps1</CommandLine>
                    <Order>10</Order>
                </SynchronousCommand>
            </FirstLogonCommands>
        </component>
    </settings>
</unattend>
