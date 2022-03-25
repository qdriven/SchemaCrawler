SELECT /*+ PARALLEL(AUTO) */
  NULL AS TABLE_CAT,
  PRIMARY_KEYS.OWNER AS TABLE_SCHEM,
  PRIMARY_KEYS.TABLE_NAME,
  PRIMARY_KEYS.CONSTRAINT_NAME AS PK_NAME,
  PK_COLUMNS.COLUMN_POSITION AS KEY_SEQ,
  PK_COLUMNS.COLUMN_NAME
FROM 
  ${catalogscope}_CONSTRAINTS PRIMARY_KEYS
  INNER JOIN ${catalogscope}_IND_COLUMNS PK_COLUMNS
  ON 
    PRIMARY_KEYS.CONSTRAINT_NAME = PK_COLUMNS.INDEX_NAME
    AND PRIMARY_KEYS.OWNER = PK_COLUMNS.TABLE_OWNER
    AND PRIMARY_KEYS.TABLE_NAME = PK_COLUMNS.TABLE_NAME
    AND PRIMARY_KEYS.OWNER = PK_COLUMNS.INDEX_OWNER
WHERE
  PRIMARY_KEYS.OWNER NOT IN 
    ('ANONYMOUS', 'APEX_050000', 'APEX_PUBLIC_USER',
    'APPQOSSYS', 'AUDSYS', 'BI', 'CTXSYS', 'DBSFWUSER',
    'DBSNMP', 'DIP', 'DVF', 'DVSYS', 'EXFSYS', 'FLOWS_FILES',
    'GGSYS', 'GSMADMIN_INTERNAL', 'GSMCATUSER', 'GSMUSER',
    'HR', 'IX', 'LBACSYS', 'MDDATA', 'MDSYS', 'MGMT_VIEW',
    'OE', 'OLAPSYS', 'ORACLE_OCM', 'ORDDATA', 'ORDPLUGINS',
    'ORDSYS', 'OUTLN', 'OWBSYS', 'PM', 'RDSADMIN',
    'REMOTE_SCHEDULER_AGENT', 'SCOTT', 'SH',
    'SI_INFORMTN_SCHEMA', 'SPATIAL_CSW_ADMIN_USR',
    'SPATIAL_WFS_ADMIN_USR', 'SYS', 'SYS$UMF', 'SYSBACKUP',
    'SYSDG', 'SYSKM', 'SYSMAN', 'SYSRAC', 'SYSTEM', 'TSMSYS',
    'WKPROXY', 'WKSYS', 'WK_TEST', 'WMSYS', 'XDB', 'XS$NULL')
  AND NOT REGEXP_LIKE(PRIMARY_KEYS.OWNER, '^APEX_[0-9]{6}$')
  AND NOT REGEXP_LIKE(PRIMARY_KEYS.OWNER, '^FLOWS_[0-9]{5,6}$')
  AND REGEXP_LIKE(PRIMARY_KEYS.OWNER, '${schemas}')
  AND PRIMARY_KEYS.TABLE_NAME NOT LIKE 'BIN$%'
  AND NOT REGEXP_LIKE(PRIMARY_KEYS.TABLE_NAME, '^(SYS_IOT|MDOS|MDRS|MDRT|MDOT|MDXT)_.*$')
  AND PRIMARY_KEYS.CONSTRAINT_TYPE = 'P'
ORDER BY 
  TABLE_SCHEM,
  TABLE_NAME,
  PK_NAME,
  KEY_SEQ
