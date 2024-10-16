SELECT
  NULL AS TABLE_CATALOG,
  VIEWS.OWNER AS TABLE_SCHEMA,
  VIEWS.VIEW_NAME AS TABLE_NAME,
  VIEWS.TEXT AS VIEW_DEFINITION,
  'UNKNOWN' AS CHECK_OPTION,
  CASE WHEN VIEWS.READ_ONLY = 'N' THEN 'Y' ELSE 'N' END AS IS_UPDATABLE
FROM
  ${catalogscope}_VIEWS VIEWS
  INNER JOIN ${catalogscope}_USERS USERS
    ON VIEWS.OWNER = USERS.USERNAME
      AND USERS.ORACLE_MAINTAINED = 'N'
      AND NOT REGEXP_LIKE(USERS.USERNAME, '^APEX_[0-9]{6}$')
      AND NOT REGEXP_LIKE(USERS.USERNAME, '^FLOWS_[0-9]{5}$')
      AND NOT REGEXP_LIKE(USERS.USERNAME, '^OPS\$ORACLE$')
WHERE
  REGEXP_LIKE(VIEWS.OWNER, '${schema-inclusion-rule}')
  AND REGEXP_LIKE(VIEWS.OWNER || '.' || VIEWS.VIEW_NAME, '${table-inclusion-rule}')
  AND VIEWS.VIEW_NAME NOT LIKE 'BIN$%'
  AND NOT REGEXP_LIKE(VIEWS.VIEW_NAME, '^(SYS_IOT|MDOS|MDRS|MDRT|MDOT|MDXT)_.*$')
UNION ALL
SELECT
  NULL AS TABLE_CATALOG,
  MVIEWS.OWNER AS TABLE_SCHEMA,
  MVIEWS.MVIEW_NAME AS TABLE_NAME,
  MVIEWS.QUERY AS VIEW_DEFINITION,
  'UNKNOWN' AS CHECK_OPTION,
  'N' AS IS_UPDATABLE
FROM
  ${catalogscope}_MVIEWS MVIEWS
  INNER JOIN ${catalogscope}_USERS USERS
    ON MVIEWS.OWNER = USERS.USERNAME
      AND USERS.ORACLE_MAINTAINED = 'N'
      AND NOT REGEXP_LIKE(USERS.USERNAME, '^APEX_[0-9]{6}$')
      AND NOT REGEXP_LIKE(USERS.USERNAME, '^FLOWS_[0-9]{5}$')
      AND NOT REGEXP_LIKE(USERS.USERNAME, '^OPS\$ORACLE$')
WHERE
  REGEXP_LIKE(MVIEWS.OWNER, '${schema-inclusion-rule}')
  AND REGEXP_LIKE(MVIEWS.OWNER || '.' || MVIEWS.MVIEW_NAME, '${table-inclusion-rule}')
  AND MVIEWS.MVIEW_NAME NOT LIKE 'BIN$%'
  AND NOT REGEXP_LIKE(MVIEWS.MVIEW_NAME, '^(SYS_IOT|MDOS|MDRS|MDRT|MDOT|MDXT)_.*$')
