SELECT
  NULL AS FUNCTION_CAT,
  COLUMNS.OWNER AS FUNCTION_SCHEM,
  COLUMNS.OBJECT_NAME AS FUNCTION_NAME,
  COLUMNS.ARGUMENT_NAME AS COLUMN_NAME,
  CASE 
    WHEN COLUMNS.POSITION = 0 THEN 4
    WHEN COLUMNS.IN_OUT = 'IN' THEN 1
    WHEN COLUMNS.IN_OUT = 'OUT' THEN 3
    WHEN COLUMNS.IN_OUT = 'IN/OUT' THEN 2
    ELSE 0
  END AS COLUMN_TYPE,
  DECODE(
  (SELECT A.TYPECODE
     FROM ${catalogscope}_TYPES A
     WHERE A.TYPE_NAME = COLUMNS.DATA_TYPE
     AND (A.OWNER = COLUMNS.OWNER OR A.OWNER IS NULL)),
  'OBJECT', 2002,
  'COLLECTION', 2003,
  DECODE(SUBSTR(COLUMNS.DATA_TYPE, 1, 9),
    'TIMESTAMP',
      DECODE(SUBSTR(COLUMNS.DATA_TYPE, 10, 1),
        '(',
          DECODE(SUBSTR(COLUMNS.DATA_TYPE, 19, 5),
            'LOCAL', -102, 'TIME ', -101, 93),
        DECODE(SUBSTR(COLUMNS.DATA_TYPE, 16, 5),
          'LOCAL', -102, 'TIME ', -101, 93)),
    'INTERVAL ',
      DECODE(SUBSTR(COLUMNS.DATA_TYPE, 10, 3),
       'DAY', -104, 'YEA', -103),
    DECODE(COLUMNS.DATA_TYPE,
      'BINARY_DOUBLE', 101,
      'BINARY_FLOAT', 100,
      'BFILE', -13,
      'BLOB', 2004,
      'CHAR', 1,
      'CLOB', 2005,
      'COLLECTION', 2003,
      'DATE', 93,
      'FLOAT', 6,
      'LONG', -1,
      'LONG RAW', -4,
      'NCHAR', -15,
      'NCLOB', 2011,
      'NUMBER', 3,
      'NVARCHAR', -9,
      'NVARCHAR2', -9,
      'OBJECT', 2002,
      'OPAQUE/XMLTYPE', 2009,
      'RAW', -3,
      'REF', 2006,
      'ROWID', -8,
      'SQLXML', 2009,
      'UROWID', -8,
      'VARCHAR2', 12,
      'VARRAY', 2003,
      'XMLTYPE', 2009,
      1111)))
  AS DATA_TYPE,
  COLUMNS.DATA_TYPE AS TYPE_NAME,
  DECODE (COLUMNS.DATA_PRECISION, NULL, DECODE(COLUMNS.DATA_TYPE, 'NUMBER', DECODE(COLUMNS.DATA_SCALE, NULL, 0 , 38), DECODE (COLUMNS.DATA_TYPE, 'CHAR', COLUMNS.CHAR_LENGTH, 'VARCHAR', COLUMNS.CHAR_LENGTH, 'VARCHAR2', COLUMNS.CHAR_LENGTH, 'NVARCHAR2', COLUMNS.CHAR_LENGTH, 'NCHAR', COLUMNS.CHAR_LENGTH, 'NUMBER', 0, COLUMNS.DATA_LENGTH) ), COLUMNS.DATA_PRECISION)
  AS PRECISION,
  COLUMNS.DATA_LENGTH AS LENGTH,
  DECODE (COLUMNS.DATA_TYPE, 'NUMBER', DECODE(COLUMNS.DATA_PRECISION, NULL, DECODE(COLUMNS.DATA_SCALE, NULL, -127 , COLUMNS.DATA_SCALE), COLUMNS.DATA_SCALE), COLUMNS.DATA_SCALE)
  AS SCALE,
  COLUMNS.RADIX AS RADIX,
  0 AS NULLABLE,
  NULL AS REMARKS,
  COLUMNS.DEFAULT_VALUE AS COLUMN_DEF,
  0 AS SQL_DATA_TYPE,
  0 AS SQL_DATETIME_SUB,
  COLUMNS.DATA_LENGTH AS CHAR_OCTET_LENGTH,
  COLUMNS.POSITION AS ORDINAL_POSITION,
  'NO' AS IS_NULLABLE,
  COLUMNS.OBJECT_NAME AS SPECIFIC_NAME
FROM
  ${catalogscope}_PROCEDURES FUNCTIONS
  INNER JOIN ${catalogscope}_ARGUMENTS COLUMNS
    ON FUNCTIONS.OBJECT_ID = COLUMNS.OBJECT_ID
WHERE
  COLUMNS.OWNER NOT IN
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
  AND NOT REGEXP_LIKE(COLUMNS.OWNER, '^APEX_[0-9]{6}$')
  AND NOT REGEXP_LIKE(COLUMNS.OWNER, '^FLOWS_[0-9]{5,6}$')
  AND REGEXP_LIKE(COLUMNS.OWNER, '${schemas}')
  AND COLUMNS.OBJECT_NAME NOT LIKE 'BIN$%'
  AND NOT REGEXP_LIKE(COLUMNS.OBJECT_NAME, '^(SYS_IOT|MDOS|MDRS|MDRT|MDOT|MDXT)_.*$')
  AND FUNCTIONS.OBJECT_TYPE = 'FUNCTION'
ORDER BY
  FUNCTION_SCHEM,
  FUNCTION_NAME,
  ORDINAL_POSITION
