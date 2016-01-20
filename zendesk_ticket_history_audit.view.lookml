- explore: ticket_history_audit
- view: ticket_history_audit
  derived_table:
    sql: |
      select ticket_id,
             Count(*) as ticket_action,
             LAST_VALUE(new_value IGNORE NULLS) OVER (PARTITION BY ticket_id ORDER BY timestamp ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as last_value
             from zendesk._ticket_history
             group by 1, new_value, timestamp
             order by 2
            

  fields:
  - measure: count
    type: count
    drill_fields: detail*

  - dimension: ticket_id
    type: int
    sql: ${TABLE}.ticket_id

  - dimension: ticket_action
    type: int
    sql: ${TABLE}.ticket_action

  - dimension: last_value
    type: string
    sql: ${TABLE}.last_value
    
  - dimension: is_last_history_entry
    type: yesno
    sql: ${last_value} = 'closed'

  sets:
    detail:
      - ticket_id
      - ticket_action
      - last_value


