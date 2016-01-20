- view: users
  sql_table_name: zendesk._users
  fields:

  - dimension: id
    primary_key: true
    type: int
    sql: ${TABLE}.id

  - dimension: active
    type: yesno
    sql: ${TABLE}.active

  - dimension: alias
    sql: ${TABLE}.alias

  - dimension_group: created
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.created_at

  - dimension: custom_role_id
    type: int
    sql: ${TABLE}.custom_role_id

  - dimension: details
    sql: ${TABLE}.details

  - dimension: email
    sql: ${TABLE}.email

  - dimension: external_id
    sql: ${TABLE}.external_id

  - dimension_group: last_login
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.last_login_at

  - dimension: loanid
    sql: ${TABLE}.loanid

  - dimension: locale_id
    type: int
    sql: ${TABLE}.locale_id

  - dimension: moderator
    type: yesno
    sql: ${TABLE}.moderator

  - dimension: name
    sql: ${TABLE}.name

  - dimension: notes
    sql: ${TABLE}.notes

  - dimension: only_private_comments
    type: yesno
    sql: ${TABLE}.only_private_comments

  - dimension: organization_id
    type: int
    sql: ${TABLE}.organization_id

  - dimension: phone
    sql: ${TABLE}.phone

  - dimension: remote_photo_url
    sql: ${TABLE}.remote_photo_url

  - dimension: role
    sql: ${TABLE}.role

  - dimension: shared
    type: yesno
    sql: ${TABLE}.shared

  - dimension: signature
    sql: ${TABLE}.signature

  - dimension: suspended
    type: yesno
    sql: ${TABLE}.suspended

  - dimension: ticket_restriction
    sql: ${TABLE}.ticket_restriction

  - dimension: time_zone
    sql: ${TABLE}.time_zone

  - dimension_group: updated
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.updated_at

  - dimension: url
    sql: ${TABLE}.url

  - dimension: userid
    sql: ${TABLE}.userid

  - dimension: verified
    type: yesno
    sql: ${TABLE}.verified

  - measure: count
    type: count
    drill_fields: [id, name]

