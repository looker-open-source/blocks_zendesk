- view: category_memberships
  sql_table_name: zendesk._group_memberships
  fields:

  - dimension: id
    primary_key: true
    type: int
    sql: ${TABLE}.id

  - dimension_group: created
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.created_at

  - dimension: default
    type: yesno
    sql: ${TABLE}."default"

  - dimension: category_id
    type: int
    sql: ${TABLE}.group_id

  - dimension_group: updated
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.updated_at

  - dimension: url
    sql: ${TABLE}.url

  - dimension: user_id
    type: int
    sql: ${TABLE}.user_id

  - measure: count
    type: count
    drill_fields: [id]

