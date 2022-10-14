-- Unexpected long-running processes running as root
--
-- false positives:
--   * new software requiring escalated privileges
--
-- tags: process state
-- platform: darwin
SELECT
  p.pid,
  p.name,
  p.path,
  p.euid,
  p.gid,
  f.ctime,
  f.directory AS dirname,
  p.cmdline,
  hash.sha256,
  pp.name AS parent_name,
  pp.cmdline AS parent_cmdline,
  signature.identifier,
  signature.authority
FROM
  processes p
  LEFT JOIN file f ON p.path = f.path
  LEFT JOIN hash ON p.path = hash.path
  LEFT JOIN processes pp ON p.parent = pp.pid
  LEFT JOIN signature ON p.path = signature.path
WHERE
  p.uid = 0
  AND (strftime('%s', 'now') - p.start_time) > 15
  AND p.path NOT IN (
    '/Applications/Foxit PDF Reader.app/Contents/MacOS/FoxitPDFReaderUpdateService.app/Contents/MacOS/FoxitPDFReaderUpdateService',
    '/Applications/OneDrive.app/Contents/StandaloneUpdaterDaemon.xpc/Contents/MacOS/StandaloneUpdaterDaemon',
    '/Applications/Opal.app/Contents/Library/LaunchServices/com.opalcamera.cameraExtensionShim',
    '/Applications/Parallels Desktop.app/Contents/MacOS/Parallels Service.app/Contents/MacOS/prl_disp_service',
    '/Applications/Parallels Desktop.app/Contents/MacOS/prl_naptd',
    '/bin/bash',
    '/Library/Apple/System/Library/CoreServices/XProtect.app/Contents/MacOS/XProtect',
    '/Library/Apple/System/Library/CoreServices/XProtect.app/Contents/XPCServices/XProtectPluginService.xpc/Contents/MacOS/XProtectPluginService',
    '/Library/Application Support/Adobe/Adobe Desktop Common/ElevationManager/Adobe Installer',
    '/Library/Application Support/Objective Development/Little Snitch/Components/at.obdev.littlesnitch.daemon.bundle/Contents/MacOS/at.obdev.littlesnitch.daemon',
    '/Library/Audio/Plug-Ins/HAL/SolsticeDesktopSpeakers.driver/Contents/XPCServices/RelayXpc.xpc/Contents/MacOS/RelayXpc',
    '/Library/Nessus/run/sbin/nessusd',
    '/Library/Nessus/run/sbin/nessus-service',
    '/Library/PrivilegedHelperTools/com.adobe.acc.installer.v2',
    '/Library/PrivilegedHelperTools/com.docker.vmnetd',
    '/Library/PrivilegedHelperTools/com.macpaw.CleanMyMac4.Agent',
    '/Library/PrivilegedHelperTools/keybase.Helper',
    '/Library/SystemExtensions/2DA71D8A-7905-4012-A7D5-0B246D5AA77B/at.obdev.littlesnitch.networkextension.systemextension/Contents/MacOS/at.obdev.littlesnitch.networkextension',
    '/opt/homebrew/Cellar/telepresence-arm64/2.7.6/bin/telepresence',
    '/sbin/launchd',
    '/System/Library/CoreServices/backupd.bundle/Contents/Resources/backupd',
    '/System/Library/CoreServices/backupd.bundle/Contents/Resources/backupd-helper',
    '/System/Library/CoreServices/CrashReporterSupportHelper',
    '/System/Library/CoreServices/iconservicesagent',
    '/System/Library/CoreServices/launchservicesd',
    '/System/Library/CoreServices/logind',
    '/System/Library/CoreServices/loginwindow.app/Contents/MacOS/loginwindow',
    '/System/Library/CoreServices/osanalyticshelper',
    '/System/Library/CoreServices/powerd.bundle/powerd',
    '/System/Library/CoreServices/ReportCrash',
    '/System/Library/CoreServices/sharedfilelistd',
    '/System/Library/CoreServices/Software Update.app/Contents/Resources/suhelperd',
    '/System/Library/CoreServices/SubmitDiagInfo',
    '/System/Library/CryptoTokenKit/com.apple.ifdreader.slotd/Contents/MacOS/com.apple.ifdreader',
    '/System/Library/CryptoTokenKit/com.apple.ifdreader.slotd/Contents/XPCServices/com.apple.ifdbundle.xpc/Contents/MacOS/com.apple.ifdbundle',
    '/System/Library/Frameworks/ApplicationServices.framework/Versions/A/Frameworks/HIServices.framework/Versions/A/XPCServices/com.apple.hiservices-xpcservice.xpc/Contents/MacOS/com.apple.hiservices-xpcservice',
    '/System/Library/Frameworks/AudioToolbox.framework/AudioComponentRegistrar',
    '/System/Library/Frameworks/AudioToolbox.framework/XPCServices/CAReportingService.xpc/Contents/MacOS/CAReportingService',
    '/System/Library/Frameworks/AudioToolbox.framework/XPCServices/com.apple.audio.SandboxHelper.xpc/Contents/MacOS/com.apple.audio.SandboxHelper',
    '/System/Library/Frameworks/ColorSync.framework/Versions/A/XPCServices/com.apple.ColorSyncXPCAgent.xpc/Contents/MacOS/com.apple.ColorSyncXPCAgent',
    '/System/Library/Frameworks/CoreMediaIO.framework/Versions/A/Resources/com.apple.cmio.registerassistantservice',
    '/System/Library/Frameworks/CoreMediaIO.framework/Versions/A/Resources/iOSScreenCapture.plugin/Contents/Resources/iOSScreenCaptureAssistant',
    '/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/CarbonCore.framework/Versions/A/Support/coreservicesd',
    '/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/CarbonCore.framework/Versions/A/XPCServices/csnameddatad.xpc/Contents/MacOS/csnameddatad',
    '/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/FSEvents.framework/Versions/A/Support/fseventsd',
    '/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/Metadata.framework/Versions/A/Support/mds',
    '/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/Metadata.framework/Versions/A/Support/mds_stores',
    '/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/Metadata.framework/Versions/A/Support/mdsync',
    '/System/Library/Frameworks/CryptoTokenKit.framework/ctkahp.bundle/Contents/MacOS/ctkahp',
    '/System/Library/Frameworks/GSS.framework/Helpers/GSSCred',
    '/System/Library/Frameworks/LocalAuthentication.framework/Support/coreauthd',
    '/System/Library/Frameworks/Metal.framework/Versions/A/XPCServices/MTLCompilerService.xpc/Contents/MacOS/MTLCompilerService',
    '/System/Library/Frameworks/NetFS.framework/Versions/A/XPCServices/PlugInLibraryService.xpc/Contents/MacOS/PlugInLibraryService',
    '/System/Library/Frameworks/OpenGL.framework/Versions/A/Libraries/CVMServer',
    '/System/Library/Frameworks/PCSC.framework/Versions/A/XPCServices/com.apple.ctkpcscd.xpc/Contents/MacOS/com.apple.ctkpcscd',
    '/System/Library/Frameworks/PreferencePanes.framework/Versions/A/XPCServices/cacheAssistant.xpc/Contents/MacOS/cacheAssistant',
    '/System/Library/Frameworks/Security.framework/Versions/A/XPCServices/authd.xpc/Contents/MacOS/authd',
    '/System/Library/Frameworks/Security.framework/Versions/A/XPCServices/com.apple.CodeSigningHelper.xpc/Contents/MacOS/com.apple.CodeSigningHelper',
    '/System/Library/Frameworks/SystemExtensions.framework/Versions/A/Helpers/sysextd',
    '/System/Library/PrivateFrameworks/AccountPolicy.framework/XPCServices/com.apple.AccountPolicyHelper.xpc/Contents/MacOS/com.apple.AccountPolicyHelper',
    '/System/Library/PrivateFrameworks/AmbientDisplay.framework/Versions/A/XPCServices/com.apple.AmbientDisplayAgent.xpc/Contents/MacOS/com.apple.AmbientDisplayAgent',
    '/System/Library/PrivateFrameworks/AppleCredentialManager.framework/AppleCredentialManagerDaemon',
    '/System/Library/PrivateFrameworks/AppleNeuralEngine.framework/XPCServices/ANECompilerService.xpc/Contents/MacOS/ANECompilerService',
    '/System/Library/PrivateFrameworks/AppleNeuralEngine.framework/XPCServices/ANEStorageMaintainer.xpc/Contents/MacOS/ANEStorageMaintainer',
    '/System/Library/PrivateFrameworks/ApplePushService.framework/apsd',
    '/System/Library/PrivateFrameworks/AppStoreDaemon.framework/Versions/A/XPCServices/com.apple.AppStoreDaemon.StorePrivilegedTaskService.xpc/Contents/MacOS/com.apple.AppStoreDaemon.StorePrivilegedTaskService',
    '/System/Library/PrivateFrameworks/AssetCacheServicesExtensions.framework/Versions/A/XPCServices/AssetCacheManagerService.xpc/Contents/MacOS/AssetCacheManagerService',
    '/System/Library/PrivateFrameworks/AssetCacheServicesExtensions.framework/Versions/A/XPCServices/AssetCacheTetheratorService.xpc/Contents/MacOS/AssetCacheTetheratorService',
    '/System/Library/PrivateFrameworks/AuthKit.framework/Versions/A/Support/akd',
    '/System/Library/PrivateFrameworks/CacheDelete.framework/deleted_helper',
    '/System/Library/PrivateFrameworks/CloudKitDaemon.framework/Support/cloudd',
    '/System/Library/PrivateFrameworks/CoreAccessories.framework/Support/accessoryd',
    '/System/Library/PrivateFrameworks/CoreDuetContext.framework/Versions/A/Resources/contextstored',
    '/System/Library/PrivateFrameworks/CoreKDL.framework/Support/corekdld',
    '/System/Library/PrivateFrameworks/CoreSymbolication.framework/coresymbolicationd',
    '/System/Library/PrivateFrameworks/FamilyControls.framework/Versions/A/Resources/parentalcontrolsd',
    '/System/Library/PrivateFrameworks/FindMyMac.framework/Versions/A/Resources/FindMyMacd',
    '/System/Library/PrivateFrameworks/GenerationalStorage.framework/Versions/A/Support/revisiond',
    '/System/Library/PrivateFrameworks/GeoServices.framework/Versions/A/XPCServices/com.apple.geod.xpc/Contents/MacOS/com.apple.geod',
    '/System/Library/PrivateFrameworks/MediaRemote.framework/Support/mediaremoted',
    '/System/Library/PrivateFrameworks/MobileInstallation.framework/XPCServices/com.apple.MobileInstallationHelperService.xpc/Contents/MacOS/com.apple.MobileInstallationHelperService',
    '/System/Library/PrivateFrameworks/MobileSoftwareUpdate.framework/Versions/A/XPCServices/com.apple.MobileSoftwareUpdate.CleanupPreparePathService.xpc/Contents/MacOS/com.apple.MobileSoftwareUpdate.CleanupPreparePathService',
    '/System/Library/PrivateFrameworks/Noticeboard.framework/Versions/A/Resources/nbstated',
    '/System/Library/PrivateFrameworks/PackageKit.framework/Versions/A/Resources/installd',
    '/System/Library/PrivateFrameworks/PackageKit.framework/Versions/A/Resources/system_installd',
    '/System/Library/PrivateFrameworks/PackageKit.framework/Versions/A/XPCServices/package_script_service.xpc/Contents/MacOS/package_script_service',
    '/System/Library/PrivateFrameworks/SiriInference.framework/Support/siriinferenced',
    '/System/Library/PrivateFrameworks/SkyLight.framework/Versions/A/Resources/WindowServer',
    '/System/Library/PrivateFrameworks/StorageKit.framework/Versions/A/Resources/storagekitd',
    '/System/Library/PrivateFrameworks/SystemAdministration.framework/XPCServices/writeconfig.xpc/Contents/MacOS/writeconfig',
    '/System/Library/PrivateFrameworks/SystemMigration.framework/Versions/A/Resources/systemmigrationd',
    '/System/Library/PrivateFrameworks/SystemStatusServer.framework/Support/systemstatusd',
    '/System/Library/PrivateFrameworks/TCC.framework/Support/tccd',
    '/System/Library/PrivateFrameworks/Uninstall.framework/Versions/A/Resources/uninstalld',
    '/System/Library/PrivateFrameworks/ViewBridge.framework/Versions/A/XPCServices/ViewBridgeAuxiliary.xpc/Contents/MacOS/ViewBridgeAuxiliary',
    '/System/Library/PrivateFrameworks/WiFiPolicy.framework/XPCServices/WiFiCloudAssetsXPCService.xpc/Contents/MacOS/WiFiCloudAssetsXPCService',
    '/System/Library/PrivateFrameworks/WirelessDiagnostics.framework/Support/awdd',
    '/System/Library/PrivateFrameworks/XprotectFramework.framework/Versions/A/XPCServices/XprotectService.xpc/Contents/MacOS/XprotectService',
    '/usr/bin/sudo',
    '/usr/bin/sysdiagnose',
    '/usr/libexec/AirPlayXPCHelper',
    '/usr/libexec/airportd',
    '/usr/libexec/amfid',
    '/usr/libexec/aned',
    '/usr/libexec/apfsd',
    '/usr/libexec/applessdstatistics',
    '/usr/libexec/ApplicationFirewall/socketfilterfw',
    '/usr/libexec/ASPCarryLog',
    '/usr/libexec/autofsd',
    '/usr/libexec/automountd',
    '/usr/libexec/batteryintelligenced',
    '/usr/libexec/biokitaggdd',
    '/usr/libexec/biometrickitd',
    '/usr/libexec/bootinstalld',
    '/usr/libexec/colorsyncd',
    '/usr/libexec/colorsync.displayservices',
    '/usr/libexec/configd',
    '/usr/libexec/containermanagerd',
    '/usr/libexec/corebrightnessd',
    '/usr/libexec/coreduetd',
    '/usr/libexec/corestoraged',
    '/usr/libexec/dasd',
    '/usr/libexec/diskarbitrationd',
    '/usr/libexec/diskmanagementd',
    '/usr/libexec/dprivacyd',
    '/usr/libexec/endpointsecurityd',
    '/usr/libexec/findmydeviced',
    '/usr/libexec/InternetSharing',
    '/usr/libexec/IOMFB_bics_daemon',
    '/usr/libexec/ioupsd',
    '/usr/libexec/kernelmanagerd',
    '/usr/libexec/keybagd',
    '/usr/libexec/logd',
    '/usr/libexec/logd_helper',
    '/usr/libexec/lsd',
    '/usr/libexec/memoryanalyticsd',
    '/usr/libexec/microstackshot',
    '/usr/libexec/misagent',
    '/usr/libexec/mobileactivationd',
    '/usr/libexec/mobileassetd',
    '/usr/libexec/nehelper',
    '/usr/libexec/nesessionmanager',
    '/usr/libexec/online-authd',
    '/usr/libexec/opendirectoryd',
    '/usr/libexec/PerfPowerServices',
    '/usr/libexec/periodic-wrapper',
    '/usr/libexec/powerdatad',
    '/usr/libexec/PowerUIAgent',
    '/usr/libexec/remoted',
    '/usr/libexec/rtcreportingd',
    '/usr/libexec/runningboardd',
    '/usr/libexec/sandboxd',
    '/usr/libexec/searchpartyd',
    '/usr/libexec/secinitd',
    '/usr/libexec/securityd_service',
    '/usr/libexec/smd',
    '/usr/libexec/symptomsd-diag',
    '/usr/libexec/sysmond',
    '/usr/libexec/syspolicyd',
    '/usr/libexec/tailspind',
    '/usr/libexec/taskgated',
    '/usr/libexec/thermalmonitord',
    '/usr/libexec/TouchBarServer',
    '/usr/libexec/tzd',
    '/usr/libexec/tzlinkd',
    '/usr/libexec/usbd',
    '/usr/libexec/UserEventAgent',
    '/usr/libexec/warmd',
    '/usr/libexec/watchdogd',
    '/usr/libexec/wifianalyticsd',
    '/usr/libexec/wifip2pd',
    '/usr/libexec/wifivelocityd',
    '/usr/local/kolide-k2/bin/osquery-extension.ext',
    '/usr/sbin/aslmanager',
    '/usr/sbin/auditd',
    '/usr/sbin/BlueTool',
    '/usr/sbin/bluetoothd',
    '/usr/sbin/BTLEServer',
    '/usr/sbin/cfprefsd',
    '/usr/sbin/distnoted',
    '/usr/sbin/filecoordinationd',
    '/usr/sbin/KernelEventAgent',
    '/usr/sbin/mDNSResponderHelper',
    '/usr/sbin/notifyd',
    '/usr/sbin/securityd',
    '/usr/sbin/spindump',
    '/usr/sbin/syslogd',
    '/usr/sbin/systemsoundserverd',
    '/usr/sbin/systemstats',
    '/usr/sbin/WirelessRadioManagerd'

  )
  AND signature.identifier IN (
    'Developer ID Application: Adobe Inc. (JQ525L2MZD)',
    'Developer ID Application: Docker Inc (9BNSXJN65R)',
    'Developer ID Application: Foxit Corporation (8GN47HTP75)',
    'Developer ID Application: Keybase, Inc. (99229SGT5K)',
    'Developer ID Application: Kolide Inc (YZ3EM74M78)',
    'Developer ID Application: MacPaw Inc. (S8EX82NJP6)',
    'Developer ID Application: Mersive Technologies (63B5A5WDNG)',
    'Developer ID Application: Microsoft Corporation (UBF8T346G9)',
    'Developer ID Application: Objective Development Software GmbH (MLZF7K7B5R)',
    'Developer ID Application: Opal Camera Inc (97Z3HJWCRT)',
    'Developer ID Application: Parallels International GmbH (4C6364ACXT)',
    'Developer ID Application: Private Internet Access, Inc. (5357M5NW9W)',
    'Developer ID Application: Tenable, Inc. (4B8J598M7U)',
    'Software Signing'
  )
GROUP BY
  p.path
