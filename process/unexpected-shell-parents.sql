SELECT p.name,
    p.path AS path,
    p.cmdline AS cmdline,
    pp.name AS parent_name,
    pp.path AS parent_path,
    pp.cmdline AS parent_cmdline,
    hash.sha256 AS parent_sha256
FROM processes p
    LEFT JOIN processes pp ON pp.pid = p.parent
    LEFT JOIN hash ON pp.path = hash.path
WHERE p.name IN ('sh', 'fish', 'zsh', 'bash', 'dash')
    -- Editors & terminals mostly
    AND parent_name NOT IN (
        'alacritty',
        'bash',
        'Code - Insiders Helper (Renderer)',
        'Code Helper (Renderer)',
        'containerd-shim',
        'dash',
        'demoit',
        'fish',
        'go',
        'goland',
        'kubectl',
        'java',
        'make',
        'skhd',
        'monorail',
        'nvim',
        'perl',
        'python',
        'roxterm',
        'sdzoomplugin',
        'systemd',
        'terminator',
        'tmux:server',
        'node',
        'tmux',
        'test2json',
        'watch',
        'vi',
        'vim',
        'wezterm-gui',
        'xfce4-terminal',
        'zsh'
    )
    AND parent_path NOT IN (
        '/bin/dash',
        '/bin/sh',
        '/opt/X11/libexec/launchd_startx',
        '/sbin/launchd',
        '/usr/bin/alacritty',
        '/usr/bin/bash',
        '/usr/bin/crond',
        '/usr/bin/login',
        '/usr/bin/man',
        '/usr/libexec/periodic-wrapper',
        '/usr/bin/zsh',
        '/usr/libexec/gnome-terminal-server'
    )

    -- npm run server
    AND NOT p.cmdline IN (
        'sh -c -- exec-bin node_modules/.bin/hugo/hugo server'
    )
    AND NOT parent_cmdline LIKE "/Applications/Warp.app/%"
    AND NOT parent_name LIKE "terraform-provider-%"
    AND NOT parent_name LIKE "Emacs%"
    AND NOT parent_name LIKE "%term%"
    AND NOT parent_name LIKE "%Term%"
    AND NOT p.cmdline LIKE "%gcloud config config-helper%"
    AND NOT p.cmdline LIKE "%/Library/Apple/System/Library/InstallerSandboxes%"
    AND NOT parent_cmdline LIKE "%gcloud.py config config-helper%"
    AND NOT (parent_name='sshd' AND p.cmdline LIKE "%askpass%")
    AND NOT parent_path LIKE "/Users/%/Library/Google/GoogleSoftwareUpdate/GoogleSoftwareUpdate.bundle/Contents/Helpers/GoogleSoftwareUpdateAgent.app/Contents/MacOS/GoogleSoftwareUpdateAgent"

    -- Oh, NixOS.
    AND NOT parent_name LIKE "%/bin/bash"