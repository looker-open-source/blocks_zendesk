- connection: production

- include: "*.view.lookml"       # include all the views
- include: "*.dashboard.lookml"  # include all the dashboards



- explore: tickets
  conditionally_filter:
#       created_date: 30 days      ## Add a conditional filter to set a default time period to display from the Explore view
#       unless: created_date
  joins:
  
      - join: category
        type: left_outer
        sql_on: ${tickets.group_id} = ${category.id}
        relationship: many_to_one
 
      - join: category_memberships
        type: left_outer
        sql_on: ${category_memberships.category_id} = ${category.id}
        relationship: one_to_many
 
      - join: users
        type: left_outer
        sql_on: ${category_memberships.user_id} = ${users.id}
        relationship: many_to_one
        
#       - join: organizations        ## include only if an organization is brought in
#         type: left_outer
#         sql_on: ${tickets.organization_id} = ${organizations.id}
#         relationship: many_to_one       
        
      - join: ticket_assignee_facts
        type: left_outer
        sql_on: ${tickets.assignee_id} = ${ticket_assignee_facts.assignee_id}
        relationship: many_to_one
        
      - join: ticket_history
        view_label: 'Tickets'        ## a view_label parameter changes the name of the view in the Explore section
        type: left_outer
        sql_on: ${ticket_history.ticket_id} = ${tickets.id}
        relationship: one_to_many     ## using one_to_one to force a fanout on tickets
        fields: [ticket_id, new_value, total_agent_touches]
        
        
- explore: ticket_history           ## Create "ticket_history" as new explore, because not all tickets have a history, so left_joining 
  joins: 
  
      - join: tickets
        type: left_outer
        sql_on: ${ticket_history.ticket_id} = ${tickets.id}
        relationship: many_to_one
  