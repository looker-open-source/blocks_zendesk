- view: category
  sql_table_name: zendesk._groups
  fields:

  - dimension: id
    primary_key: true
    type: int
    sql: ${TABLE}.id

  - dimension_group: created
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.created_at

  - dimension: deleted
    type: yesno
    sql: ${TABLE}.deleted

  - dimension: name
    description: 'type of ticket'
    sql: ${TABLE}.name

  - dimension_group: updated
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.updated_at

  - dimension: url
    sql: ${TABLE}.url

#   - measure: count    ## redundant logic ##
#     type: count
#     drill_fields: [id, name]

