SELECT
  *
FROM
  crontab
WHERE
  command NOT LIKE "root%run-parts%"
  AND command NOT LIKE "%freshclam%"
  AND command NOT LIKE "%clamscan%"
  AND command NOT LIKE "%e2scrub%"
  AND command NOT LIKE "%zfs-linux%"
  AND command NOT LIKE "%anacron start%"
  AND command NOT LIKE "%/usr/lib/php/sessionclean%"