view: organizations {
  extends: [_organizations]
}

view: category {
  extends: [_groups]
}

view: category_memberships {
  extends: [_group_memberships]
}

view: users {
  extends: [_users]
}

view: ticket_history {
  extends: [_ticket_history]
  ## The SQL in this dimensions should be updated to reflect whatever your business
  dimension: number_of_agent_touches {
    ## considers and "agent touch"
    type: number
    hidden: yes
    sql: CASE
      WHEN ${new_value} IN ('true','false','incident') THEN 1
      ELSE 0
      END

       ;;
  }

  measure: total_agent_touches {
    type: sum
    sql: ${number_of_agent_touches} ;;
  }

  measure: count_unique_tickets {
    type: count_distinct
    sql: ${ticket_id} ;;
  }

  measure: average_agents_touches {
    type: average
    sql: ${number_of_agent_touches} ;;
  }
}

view: tickets {
  extends: [_tickets]

  dimension: is_backlogged {
    type: yesno
    sql: ${status} = 'pending' ;;
  }

  dimension: is_new {
    type: yesno
    sql: ${status} = 'new' ;;
  }

  dimension: is_open {
    type: yesno
    sql: ${status} = 'open' ;;
  }

  ### THIS ASSUMES NO DISTINCTION BETWEEN SOLVED AND CLOSED
  dimension: is_solved {
    type: yesno
    sql: ${status} = 'solved' OR ${status} = 'closed' ;;
  }

  dimension: subject_category {
    sql: CASE
      WHEN ${subject} LIKE 'Chat%' THEN 'Chat'
      WHEN ${subject} LIKE 'Offline message%' THEN 'Offline Message'
      WHEN ${subject} LIKE 'Phone%' THEN 'Phone Call'
      ELSE 'Other'
      END
       ;;
  }

  measure: count_backlogged_tickets {
    type: count

    filters: {
      field: is_backlogged
      value: "Yes"
    }
  }

  measure: count_new_tickets {
    type: count

    filters: {
      field: is_new
      value: "Yes"
    }
  }

  measure: count_open_tickets {
    type: count

    filters: {
      field: is_open
      value: "Yes"
    }
  }

  measure: count_solved_tickets {
    type: count

    filters: {
      field: is_solved
      value: "Yes"
    }
  }

  ############ TIME FIELDS ###########

  dimension_group: hidden_created {
    hidden: yes
    type: time
    ###   use day_of_week
    timeframes: [day_of_week_index]
    sql: ${TABLE}.created_at ;;
  }

  dimension: created_day_of_week {
    case: {
      when: {
        sql: ${hidden_created_day_of_week_index} = 6 ;;
        label: "Sunday"
      }

      when: {
        sql: ${hidden_created_day_of_week_index} = 0 ;;
        label: "Monday"
      }

      when: {
        sql: ${hidden_created_day_of_week_index} = 1 ;;
        label: "Tuesday"
      }

      when: {
        sql: ${hidden_created_day_of_week_index} = 2 ;;
        label: "Wednesday"
      }

      when: {
        sql: ${hidden_created_day_of_week_index} = 3 ;;
        label: "Thursday"
      }

      when: {
        sql: ${hidden_created_day_of_week_index} = 4 ;;
        label: "Friday"
      }

      when: {
        sql: ${hidden_created_day_of_week_index} = 5 ;;
        label: "Saturday"
      }
    }
  }

  dimension_group: time {
    type: time
    timeframes: [hour_of_day]
    sql: ${TABLE}.created_at ;;
  }

  ############ CHAT FIELDS: INCLUDE ONLY IF YOUR ZENDESK APP UTILIZES CHAT ###########

  # Chat times are based off the 'description' column until Zopim's integration is updated. This is because
  # the timestamps Zopim uses are inconsistent w/r/t data structure and timezone conversions

  dimension: is_chat {
    type: yesno
    sql: POSITION('Chat started on ' IN ${description}) > 0

       ;;
  }

  dimension: chat_start_time_string {
    hidden: yes
    sql: CASE
        WHEN POSITION('Chat started on ' IN ${description}) > 0
          THEN SUBSTRING(${description}, POSITION('Chat started on ' IN ${description}) + 16, 19)
      END
       ;;
  }

  dimension: chat_start_date_no_tz_convert {
    type: date
    hidden: yes
    convert_tz: no
    sql: CASE
        WHEN POSITION('PM' IN ${chat_start_time_string}) > 0 OR POSITION('AM' IN ${chat_start_time_string}) > 0
        THEN ${chat_start_time_string}::timestamp
      END
       ;;
  }

  dimension_group: chat_start {
    type: time
    timeframes: [
      date,
      week,
      month,
      time,
      day_of_week,
      hour_of_day
    ]
    sql: CASE
        WHEN POSITION('PM' IN ${chat_start_time_string}) > 0 OR POSITION('AM' IN ${chat_start_time_string}) > 0
        THEN ${chat_start_time_string}::timestamp
      END
       ;;
  }

  ## runs off the last time a comment was made by either a customer or an internal user
  # can be thrown off if customers stay on between separate chats
  dimension: chat_end_time_string {
    hidden: yes
    sql: CONCAT(${chat_start_date_no_tz_convert}, CONCAT(' ',
        LEFT(RIGHT(${description}, POSITION(')M' IN SUBSTRING(REVERSE(${description}),
            POSITION(')M' IN SUBSTRING(REVERSE(${description}), POSITION(')M' IN REVERSE(${description})) + 1, 10000)) +
            POSITION(')M' IN REVERSE(${description})) + 1, 10000)) +
                POSITION(')M' IN SUBSTRING(REVERSE(${description}), POSITION(')M' IN REVERSE(${description})) + 1, 10000)) +
                POSITION(')M' IN REVERSE(${description})) + 11), 11)
        )
      )
       ;;
  }

  dimension_group: chat_end {
    type: time
    timeframes: [date, time, hour_of_day]
    description: "As accurate as possible to when the chat \"ended\" but can be thrown off if customers staying on between separate chats."
    # assumes chats will not run from AM day 1 to AM day 2
    sql: CASE
        WHEN POSITION('PM' IN ${chat_start_time_string}) > 0  AND POSITION('AM' IN ${chat_end_time_string}) > 0
        THEN DATEADD(hour, 24, ${chat_end_time_string}::timestamp)
        ELSE ${chat_end_time_string}::timestamp
      END
       ;;
  }

  dimension: chat_duration_seconds {
    type: number
    #     hidden: true
    sql: DATEDIFF(second, ${chat_start_time}::timestamp, ${chat_end_time}::timestamp) ;;
  }

  dimension: chat_duration_minutes {
    description: "As accurate as possible to when the chat \"ended\" but can be thrown off if customers staying on between separate chats."
    type: number
    sql: ${chat_duration_seconds}/60 ;;
  }

  dimension: chat_duration_minutes_tier {
    #     hidden: true
    type: tier
    tiers: [
      0,
      5,
      10,
      20,
      40,
      60,
      80,
      100,
      120,
      140,
      160,
      180,
      200,
      300,
      400,
      500,
      600
    ]
    sql: ${chat_duration_minutes} ;;
  }

  ## Assumes working chat hours from 8am-6pm
  dimension: first_reply_time_chat {
    label: "First Reply Time (Chat)"
    description: "Time to first reponse; assumes chat does not last longer than 2 days or chat becomes null"
    ## does not account for chats lasting longer than 2 days
    type: number
    sql: CASE
      WHEN ${via_channel} = 'chat' AND DATEDIFF(day, ${chat_start_time}::timestamp, ${chat_end_time}::timestamp) < 1 THEN DATEDIFF(minute, ${chat_start_time}::timestamp, ${chat_end_time}::timestamp)
      WHEN ${via_channel} = 'chat' AND DATEDIFF(day, ${chat_start_time}::timestamp, ${chat_end_time}::timestamp) = 1 THEN (DATEDIFF(minute, ${chat_start_time}::timestamp, ${chat_end_time}::timestamp) - 840)
      WHEN ${via_channel} = 'chat' AND DATEDIFF(day, ${chat_start_time}::timestamp, ${chat_end_time}::timestamp) = 2 THEN (DATEDIFF(minute, ${chat_start_time}::timestamp, ${chat_end_time}::timestamp) - 1740)
      ELSE NULL
      END
       ;;
  }

  ## Assumes working  hours from 8am-6pm
  dimension: first_reply_time_email {
    label: "First Reply Time (Email)"
    description: "Time to first reponse; assumes lag not last longer than 2 days or chat becomes null"
    ## does not account for chats lasting longer than 2 days
    type: number
    sql: CASE
      WHEN ${via_channel} = 'email' AND DATEDIFF(day, ${created_date}::timestamp, ${updated_date}::timestamp) < 1 THEN DATEDIFF(minute, ${created_time}::timestamp, ${updated_time}::timestamp)
      WHEN ${via_channel} = 'email' AND DATEDIFF(day, ${created_date}::timestamp, ${updated_date}::timestamp) = 1 THEN (DATEDIFF(minute, ${created_time}::timestamp, ${updated_time}::timestamp) - 840)
      WHEN ${via_channel} = 'email' AND DATEDIFF(day, ${created_date}::timestamp, ${updated_date}::timestamp) = 2 THEN (DATEDIFF(minute, ${created_time}::timestamp, ${updated_time}::timestamp) - 1740)
      ELSE NULL
      END
       ;;
  }

  dimension: first_reply_time_chat_tiers {
    type: tier
    tiers: [
      0,
      5,
      10,
      20,
      40,
      60,
      90,
      120,
      180,
      240,
      300,
      360,
      420
    ]
    sql: ${first_reply_time_chat} ;;
  }

  measure: average_chat_duration_minutes {
    description: "As accurate as possible to when the chat \"ended\" but can be thrown off if customers staying on between separate chats."
    type: average
    sql: ${chat_duration_minutes} ;;
  }

  measure: total_chat_duration_minutes {
    description: "As accurate as possible to when the chat \"ended\" but can be thrown off if customers staying on between separate chats."
    type: sum
    sql: ${chat_duration_minutes} ;;
  }

  measure: average_first_reply_time_chat {
    label: "Average First Reply Time Chat (Minutes)"
    type: average
    sql: ${first_reply_time_chat} ;;
  }

  measure: total_first_reply_time_chat {
    label: "Total First Reply Time Chat (Minutes)"
    description: "Does not make sense to aggregate response time over anything other than ticket number"
    type: sum
    sql: ${first_reply_time_chat} ;;
  }

  measure: count_chats {
    type: count

    filters: {
      field: is_chat
      value: "yes"
    }
  }

  measure: count_non_chats {
    label: "Count Non-Chats"
    type: count

    filters: {
      field: is_chat
      value: "No"
    }
  }

  ############ VOICE FIELDS: INCLUDE ONLY IF YOUR ZENDESK APP UTILIZES VOICE CAPABILITIES  ###########

  dimension: is_incoming_call {
    type: yesno
    sql: ${description} ILIKE '%Call From%' ;;
  }

  dimension: is_outgoing_call {
    type: yesno
    sql: ${description} ILIKE '%Call To%' ;;
  }

  dimension: is_abandoned {
    sql: CASE
      WHEN ${description} ILIKE '%Call FROM%'
      AND ${description} NOT ILIKE '%Answered by:%'
      THEN 'Yes' ELSE 'No'
      END
       ;;
  }

  #   - dimension: weekend_call_time
  #     sql: |
  #          CASE
  #          WHEN EXTRACT(doy FROM ${created_time}::timestamp) < 68 THEN ${created_time}::timestamp

  dimension: weekend_call {
    type: yesno
    sql: ${created_day_of_week} ILIKE 'Sunday' OR ${created_day_of_week}  ILIKE 'Saturday' ;;
  }

  measure: incoming_call_count {
    type: count

    filters: {
      field: is_incoming_call
      value: "Yes"
    }
  }

  measure: outgoing_call_count {
    type: count

    filters: {
      field: is_outgoing_call
      value: "Yes"
    }
  }

  measure: abandoned_call_count {
    type: count

    filters: {
      field: is_abandoned
      value: "Yes"
    }

    filters: {
      field: weekend_call
      value: "No"
    }
  }

  measure: answered_call_count {
    type: count

    filters: {
      field: is_abandoned
      value: "No"
    }

    filters: {
      field: weekend_call
      value: "No"
    }
  }
}

### SATISFACTION FIELDS - TO BE INCLUDED ONLY IF YOUR ZENDESK APP UTILIZES SATISFACTION SCORING ###


#   - dimension: satisfaction_rating_percent_tier
#     type: tier
#     tiers: [10,20,30,40,50,60,70,80,90]
#     sql: ${satisfaction_rating}

#   - measure: average_satisfaction_rating
#     type: avg
#     sql: ${satisfaction_rating}
#     value_format: '#,#00.00%'