-- Unexpected programs communicating over HTTPS (state-based)
--
-- references:
--   * https://attack.mitre.org/techniques/T1071/ (C&C, Application Layer Protocol)
--
-- tags: transient state net often
-- platform: macos
SELECT
  pos.protocol,
  pos.local_port,
  pos.remote_port,
  pos.remote_address,
  pos.local_port,
  pos.local_address,
  CONCAT (
    MIN(p0.euid, 500),
    ',',
    REGEX_MATCH (p0.path, '.*/(.*?)$', 1),
    ',',
    p0.name,
    ',',
    s.authority,
    ',',
    s.identifier
  ) AS exception_key,  
  CONCAT (
    MIN(p0.euid, 500),
    ',',
    REGEX_MATCH (p0.path, '.*/(.*?)$', 1),
    ',',
    p0.name,
    ',',
    MIN(f.uid, 500),
    'u,',
    MIN(f.gid, 500),
    'g'
  ) AS alt_exception_key,
  -- Child
  p0.pid AS p0_pid,
  p0.path AS p0_path,
  s.authority AS p0_sauth,
  s.identifier AS p0_sid,
  p0.name AS p0_name,
  p0.cmdline AS p0_cmd,
  p0.cwd AS p0_cwd,
  p0.euid AS p0_euid,
  p0_hash.sha256 AS p0_sha256,
  -- Parent
  p0.parent AS p1_pid,
  p1.path AS p1_path,
  p1.name AS p1_name,
  p1.euid AS p1_euid,
  p1.cmdline AS p1_cmd,
  p1_hash.sha256 AS p1_sha256,
  -- Grandparent
  p1.parent AS p2_pid,
  p2.name AS p2_name,
  p2.path AS p2_path,
  p2.cmdline AS p2_cmd,
  p2_hash.sha256 AS p2_sha256
FROM
  process_open_sockets pos
  LEFT JOIN processes p0 ON pos.pid = p0.pid
  LEFT JOIN hash p0_hash ON p0.path = p0_hash.path
  LEFT JOIN processes p1 ON p0.parent = p1.pid
  LEFT JOIN hash p1_hash ON p1.path = p1_hash.path
  LEFT JOIN processes p2 ON p1.parent = p2.pid
  LEFT JOIN hash p2_hash ON p2.path = p2_hash.path
  LEFT JOIN file f ON p0.path = f.path
  LEFT JOIN signature s ON p0.path = s.path
WHERE
  pos.protocol IN (6, 17)
  AND pos.remote_port = 443
  AND pos.remote_address NOT IN ('127.0.0.1', '::ffff:127.0.0.1', '::1')
  AND pos.remote_address NOT LIKE 'fe80:%'
  AND pos.remote_address NOT LIKE '127.%'
  AND pos.remote_address NOT LIKE '192.168.%'
  AND pos.remote_address NOT LIKE '172.1%'
  AND pos.remote_address NOT LIKE '172.2%'
  AND pos.remote_address NOT LIKE '172.30.%'
  AND pos.remote_address NOT LIKE '172.31.%'
  AND pos.remote_address NOT LIKE '::ffff:172.%'
  AND pos.remote_address NOT LIKE '10.%'
  AND pos.remote_address NOT LIKE '::ffff:10.%'
  AND pos.remote_address NOT LIKE 'fdfd:%'
  AND pos.remote_address NOT LIKE 'fc00:%'
  AND pos.state != 'LISTEN' -- Ignore most common application paths
  AND p0.path NOT LIKE '/Applications/%.app/Contents/%'
  AND p0.path NOT LIKE '/Library/Apple/System/Library/%'
  AND p0.path NOT LIKE '/Library/Application Support/%/Contents/%'
  AND p0.path NOT LIKE '/System/Applications/%'
  AND p0.path NOT LIKE '/System/Library/%'
  AND p0.path NOT LIKE '/Users/%/Library/%.app/Contents/MacOS/%'
  AND p0.path NOT LIKE '/Users/%/code/%'
  AND p0.path NOT LIKE '/Users/%/src/%'
  AND p0.path NOT LIKE '/Users/%/bin/%'
  AND p0.path NOT LIKE '/System/%'
  AND p0.path NOT LIKE '/opt/homebrew/Cellar/%/bin/%'
  AND p0.path NOT LIKE '/usr/libexec/%'
  AND p0.path NOT LIKE '/usr/sbin/%'
  AND p0.path NOT LIKE '/usr/local/kolide-k2/bin/%'
  AND p0.path NOT LIKE '/private/var/folders/%/go-build%/%'  
  -- Apple programs running from weird places, like the UpdateBrainService
  AND NOT (
    s.identifier LIKE 'com.apple.%'
    AND s.authority = 'Software Signing'
  )
  AND NOT exception_key IN (
    '0,Setup,Setup,Developer ID Application: Adobe Inc. (JQ525L2MZD),com.adobe.acc.Setup',
    '500,bash,bash,,bash',
    '500,cloud_sql_proxy,cloud_sql_proxy,,a.out',
    '500,Code Helper,Code Helper,Developer ID Application: Microsoft Corporation (UBF8T346G9),com.microsoft.VSCode.helper',
    '500,Code Helper (Plugin),Code Helper (Plugin),Developer ID Application: Microsoft Corporation (UBF8T346G9),com.github.Electron.helper',
    '500,Code Helper (Renderer),Code Helper (Renderer),Developer ID Application: Microsoft Corporation (UBF8T346G9),com.github.Electron.helper',
    '500,Ecamm Live Stream Deck Plugin,Ecamm Live Stream Deck Plugin,Developer ID Application: Ecamm Network, LLC (5EJH68M642),Ecamm Live Stream Deck Plugin',
    '500,Electron,Electron,Developer ID Application: Microsoft Corporation (UBF8T346G9),com.microsoft.VSCode',
    '500,git-remote-http,git-remote-http,,git-remote-http-55554944748a32c47cdc35cfa7f071bb69a39ce4',
    '500,go,go,Developer ID Application: Google LLC (EQHXZ8M8AV),org.golang.go',
    '500,grype,grype,Developer ID Application: ANCHORE, INC. (9MJHKYX5AT),grype',
    '500,melange,melange,,a.out',
    '500,node,node,Developer ID Application: Node.js Foundation (HX7739G8FX),node',
    '500,old,old,Developer ID Application: Denver Technologies, Inc (2BBY89MBSN),dev.warp.Warp-Stable',
    '500,op,op,Developer ID Application: AgileBits Inc. (2BUA8C4S2C),com.1password.op',
    '500,Paintbrush,Paintbrush,Developer ID Application: Michael Schreiber (G966ML7VBG),com.soggywaffles.paintbrush',
    '500,Reflect Helper,Reflect Helper,Developer ID Application: Reflect App, LLC (789ULN5MZB),app.reflect.ReflectDesktop',
    '500,Reflect,Reflect,Developer ID Application: Reflect App, LLC (789ULN5MZB),app.reflect.ReflectDesktop',
    '500,sdaudioswitch,sdaudioswitch,,sdaudioswitch',
    '500,snyk-ls_darwin_arm64,snyk-ls_darwin_arm64,,a.out',
    '500,syncthing,syncthing,,syncthing',
    '500,Transmit,Transmit,Developer ID Application: Panic, Inc. (VE8FC488U5),com.panic.Transmit',
    '500,TwitchStudioStreamDeck,TwitchStudioStreamDeck,Developer ID Application: Corsair Memory, Inc. (Y93VXCB8Q5),TwitchStudioStreamDeck',
    '500,zoom.us,zoom.us,Developer ID Application: Zoom Video Communications, Inc. (BJ4HAAB9B3),us.zoom.xos'
  )
  AND NOT alt_exception_key IN (
    '500,apko,apko,0u,0g',
    '500,cpu,cpu,500u,20g',
    '500,sdaudioswitch,sdaudioswitch,500u,20g',
    '500,sdzoomplugin,sdzoomplugin,500u,20g'
  )
  AND NOT alt_exception_key LIKE '500,terraform-provider-%,terraform-provider-%,500u,20g'
  AND NOT p0.path LIKE '/private/var/folders/%/T/GoLand/%'
  AND NOT (
    exception_key = '500,Python,Python,,org.python.python'
    AND (
      p0_cmd LIKE '%/gcloud.py%'
      OR p0_cmd LIKE '%pip install%'
    )
  )
  -- theScore and other iPhone apps
  AND NOT (
    s.authority = 'Apple iPhone OS Application Signing'
    AND p0.cwd = '/'
    AND p0.path = '/private/var/folders/%/Wrapper/%.app/%'
  )
  -- nix socket inheritance
  AND NOT (
    p0.path LIKE '/nix/store/%/bin/%'
    AND p1.path LIKE '/nix/store/%/bin/%'
  )
GROUP BY
  p0.cmdline