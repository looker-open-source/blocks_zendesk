- view: _fivetran_audit
  sql_table_name: zendesk._fivetran_audit
  fields:

  - dimension_group: done
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.done

  - dimension: message
    sql: ${TABLE}.message

  - dimension: rows_updated_or_inserted
    type: number
    sql: ${TABLE}.rows_updated_or_inserted

  - dimension: schema
    sql: ${TABLE}.schema

  - dimension_group: start
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.start

  - dimension: status
    sql: ${TABLE}.status

  - dimension: table
    sql: ${TABLE}."table"

  - measure: count
    type: count
    drill_fields: []

