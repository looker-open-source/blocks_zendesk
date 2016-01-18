- view: ticket_history
  sql_table_name: zendesk._ticket_history
  fields:

  - dimension: id
    primary_key: true
    type: int
    sql: ${TABLE}.id

  - dimension: new_value      ## the types of actions that can be taken vary from case to case, customize this portion to match your specific business needs
    description: Once a ticket is "closed", it cannot be re-opened  ## Zendesk auto-closes by default after 14 days of being marked as solved
    sql: ${TABLE}.new_value

  - dimension: property
    sql: ${TABLE}.property

  - dimension: ticket_id
    type: int
    sql: ${TABLE}.ticket_id

  - dimension_group: timestamp
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.timestamp

  - dimension: updater_id
    type: int
    sql: ${TABLE}.updater_id

  - dimension: via
    sql: ${TABLE}.via

  - measure: count
    type: count
    drill_fields: [id]
    
  - measure: count_unique_tickets
    type: count_distinct
    sql: ${ticket_id}


###  AGENT TOUCHES

  - dimension: number_of_agent_touches  ## The SQL in this dimensions should be updated to reflect whatever you business
    type: number                        ## considers and "agent touch"
    hidden: true
    sql: |
         CASE 
         WHEN ${new_value} IN ('true','false','incident') THEN 1 
         ELSE 0
         END
         
  - measure: total_agent_touches
    type: sum
    sql: ${number_of_agent_touches}
    
  - measure: average_agents_touches
    type: avg
    sql: ${number_of_agent_touches}




