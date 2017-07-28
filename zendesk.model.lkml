connection: "zendesk"

# include all the views
include: "*.view"

# include all the dashboards
include: "*.dashboard"

explore: tickets {
  ## Add a filter to set a default time period to display in the Explore Window - this will make the queries run faster
  #   always_filter:
  #     tickets.created_date: 30 days
  join: category {
    sql_on: ${tickets.group_id} = ${category.id} ;;
    relationship: many_to_one
  }

  join: category_memberships {
    sql_on: ${category_memberships.group_id} = ${category.id} ;;
    relationship: one_to_many
  }

  join: organizations {
    sql_on: ${tickets.organization_id} = ${organizations.id} ;;
    relationship: many_to_one
  }

  join: assignee {
    from: users
    sql_on: ${tickets.assignee_id} = ${assignee.id} ;;
    relationship: many_to_one
  }

  join: ticket_assignee_facts {
    sql_on: ${tickets.assignee_id} = ${ticket_assignee_facts.assignee_id} ;;
    relationship: many_to_one
  }

  join: ticket_history {
    ## a view_label parameter changes the name of the view in the Explore section
    view_label: "Tickets"
    sql_on: ${ticket_history.ticket_id} = ${tickets.id} ;;
    ## use one_to_one to force a fanout on tickets
    relationship: one_to_many
    fields: [ticket_id, new_value, total_agent_touches]
  }
}

## Create "ticket_history" as new explore, because not all tickets have a history, so left_joining
explore: ticket_history {
  join: tickets {
    sql_on: ${ticket_history.ticket_id} = ${tickets.id} ;;
    relationship: many_to_one
  }
}

explore: ticket_history_audit {}