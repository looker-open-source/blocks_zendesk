- view: organizations        ## INLUDE ONLY IF YOUR ZENDESK APP CATEGORIZES BY ORGANIZATION
  sql_table_name: zendesk._organizations
  fields:

  - dimension: id
    primary_key: true
    type: int
    sql: ${TABLE}.id

  - dimension_group: created
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.created_at

  - dimension: details
    sql: ${TABLE}.details

  - dimension: external_id
    sql: ${TABLE}.external_id

  - dimension: group_id
    type: int
    sql: ${TABLE}.group_id

  - dimension: name
    sql: ${TABLE}.name

  - dimension: notes
    sql: ${TABLE}.notes

  - dimension: shared_comments
    type: yesno
    sql: ${TABLE}.shared_comments

  - dimension: shared_tickets
    type: yesno
    sql: ${TABLE}.shared_tickets

  - dimension_group: updated
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.updated_at

  - measure: count
    type: count
    drill_fields: [id, name]

