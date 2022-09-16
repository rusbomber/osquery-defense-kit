-- Ported from exotic-commands
-- Events version of sketchy-fetchers
-- Designed for execution every 5 minutes (where the parent may still be around)
SELECT p.pid,
    p.path,
    p.cmdline,
    p.mode,
    p.cwd,
    p.euid,
    p.parent,
    p.syscall,
    pp.path AS parent_path,
    pp.name AS parent_name,
    pp.cmdline AS parent_cmdline,
    pp.euid AS parent_euid,
    hash.sha256 AS parent_sha256
FROM uptime, process_events p
    LEFT JOIN processes pp ON p.parent = pp.pid
    LEFT JOIN hash ON pp.path = hash.path
WHERE p.time > (strftime('%s', 'now') -300)
    AND p.path IN (
        '/usr/bin/bpftool',
        '/usr/bin/netcat',
        '/usr/bin/mkfifo',
        '/usr/bin/socat',
        '/usr/bin/kmod'
    )
    -- Things that could reasonably happen at boot.
    AND NOT (p.path="/usr/bin/kmod" AND parent_path="/usr/lib/systemd/systemd" AND parent_cmdline="/sbin/init")

    AND NOT (
        p.path = '/usr/bin/kmod'
        AND uptime.total_seconds < 15
    )
    -- gpgtools
    AND NOT (
        p.path = '/usr/bin/mkfifo'
        AND p.cmdline LIKE "%/org.gpgtools.log.%/fifo"
    )
    -- Docker
    AND NOT (
        p.path = '/usr/bin/kmod'
        AND parent_name IN ('dockerd')
    )
    AND NOT p.cmdline LIKE 'modprobe -va%'
    AND NOT p.cmdline LIKE 'modprobe -ab%'
    AND NOT p.cmdline LIKE '%modprobe overlay'
    AND NOT p.cmdline LIKE '%modprobe aufs'
    AND NOT p.cmdline IN (
        'lsmod'
    )