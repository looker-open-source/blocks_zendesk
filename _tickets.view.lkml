view: _tickets {
  sql_table_name: zendesk._tickets ;;
  ### DEFAULT FIELDS ###

  dimension: id {
    primary_key: yes
    sql: ${TABLE}.id ;;
  }

  ## a ticket can only be assigned to one assignee at a time
  dimension: assignee_id {
    ## assignees may be a group of agents (represented as one entity), or one specific agent
    type: number
    value_format_name: id
    sql: ${TABLE}.assignee_id ;;
  }

  dimension: bug {
    type: yesno
    sql: ${TABLE}.bug ;;
  }

  dimension_group: created {
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.created_at ;;
  }

  dimension: description {
    sql: ${TABLE}.description ;;
  }

  dimension_group: due {
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.due_at ;;
  }

  dimension: external_id {
    sql: ${TABLE}.external_id ;;
  }

  dimension: forum_topic_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.forum_topic_id ;;
  }

  dimension: group_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.group_id ;;
  }

  dimension: has_incidents {
    type: yesno
    sql: ${TABLE}.has_incidents ;;
  }

  dimension: organization_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.organization_id ;;
  }

  dimension: priority {
    sql: ${TABLE}.priority ;;
  }

  dimension: problem_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.problem_id ;;
  }

  dimension: recipient {
    sql: ${TABLE}.recipient ;;
  }

  dimension: requester_email {
    description: "the requester is the customer who initiated the ticket"
    sql: ${TABLE}.requester_email ;;
  }

  dimension: requester_id {
    description: "the requester is the customer who initiated the ticket"
    type: number
    value_format_name: id
    sql: ${TABLE}.requester_id ;;
  }

  dimension: requester_locale_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.requester_locale_id ;;
  }

  dimension: requester_name {
    description: "the requester is the customer who initiated the ticket"
    sql: ${TABLE}.requester_name ;;
  }

  dimension: status {
    sql: ${TABLE}.status ;;
  }

  ## depending on use, either this field or "via_channel" will represent the channel the ticket came through
  dimension: subject {
    sql: ${TABLE}.subject ;;
  }

  ## The submitter is always the first to comment on a ticket
  dimension: submitter_id {
    description: "a submitter is either a customer or an agent submitting on behalf of a customer"
    type: number
    value_format_name: id
    sql: ${TABLE}.submitter_id ;;
  }

  dimension: ticket_form_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.ticket_form_id ;;
  }

  dimension: type {
    sql: ${TABLE}.type ;;
  }

  dimension_group: updated {
    type: time
    timeframes: [time, date, week, month]
    sql: ${TABLE}.updated_at ;;
  }

  dimension: url {
    sql: ${TABLE}.url ;;
  }

  dimension: via_channel {
    sql: ${TABLE}.via_channel ;;
  }

  measure: count {
    type: count
    drill_fields: [id, requester_name]
  }
}

#   - dimension: assignee_name        ## include only if your Zendesk application utilizes the assignee_name field
#     sql: ${TABLE}.assignee_name

#   - dimension: brand_id      ## include only if your Zendesk application utilizes the brand field
#     value_format_name: id                ## only associated with Zendesk Enterprise Accounts
#     type: number
#     sql: ${TABLE}.brand_id


## include below dimension only if your Zendesk application utilizes the collaborator field

#   - dimension: collaborator_ids    ## a ticket may have a collaborator as well, either a single group or one specific agent
#     type: number    value_format_name: id
#     sql: ${TABLE}.collaborator_ids

#   - dimension: tags    ## include only if your Zendesk application utilizes the tags feature
#     description: an array of all tags applied to this ticket
#     sql: ${TABLE}.tags

#   - dimension: priority           ## include only if your Zendesk application utilizes the priority field
#     sql: ${TABLE}.priority