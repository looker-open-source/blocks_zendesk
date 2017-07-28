- dashboard: main
  title: Main
  layout: tile
  tile_size: 100

#   filters:

  elements:

  - name: tickets_by_assignee
    title: 'Tickets by Assignee'
    type: looker_column
    model: zendesk
    explore: tickets
    dimensions: [assignee.name,tickets.created_day_of_week,
      tickets.created_date]
    pivots: [assignee.name]
    measures: [tickets.count]
    hidden_fields: [tickets.created_date]
    filters:
      tickets.created_date: 7 days
      tickets.created_day_of_week: -"Saturday",-"Sunday"
    sorts: [tickets.created_date]
    limit: 500
    column_limit: 50
    stacking: normal
    colors: ['#353b49', '#635189', '#b3a0dd', '#776fdf', '#1ea8df', '#a2dcf3', '#49cec1',
      '#76e0a1', '#a8e6ae']
    show_value_labels: false
    label_density: 25
    legend_position: center
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    hidden_series: [tickets.count]
    y_axis_combined: true
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_tick_density: default
    show_x_axis_label: false
    show_x_axis_ticks: true
    x_axis_scale: auto
    y_axis_orientation: [left, right]
    ordering: none
    show_null_labels: false
    
  - name: chat_length_by_assignee
    title: 'Chat Length by Assignee'
    type: looker_column
    model: zendesk
    explore: tickets
    dimensions: [assignee.name]
    measures: [tickets.total_chat_duration_minutes, tickets.average_chat_duration_minutes,
      tickets.count_chats]
    filters:
      tickets.created_date: 7 days
    sorts: [assignee.name]
    limit: 500
    stacking: ''
    colors: ['#fec280', '#fee592', '#FFA06D', '#fdae95']
    show_value_labels: false
    label_density: 25
    legend_position: center
    x_axis_gridlines: false
    y_axis_gridlines: true
    show_view_names: false
    series_labels:
      tickets.total_chat_duration_minutes: Total Minutes
      tickets.average_chat_duration_minutes: Average Minutes
      tickets.count_chats: Number of Chats
    hidden_series: [tickets.count_chats]
    y_axis_combined: false
    show_y_axis_labels: true
    show_y_axis_ticks: true
    y_axis_labels: [Total Minutes, Average Minutes, Number of Chats]
    y_axis_tick_density: default
    show_x_axis_label: false
    show_x_axis_ticks: true
    x_axis_scale: auto
    y_axis_orientation: [left, right]
    x_axis_label_rotation: 0
    show_null_labels: false
        
  - name: this_weeks_non_chats
    title: "This week's non-chats"
    type: single_value
    model: zendesk
    explore: tickets
    dimensions: [tickets.created_week]
    measures: [tickets.count_non_chats]
    dynamic_fields:
    - table_calculation: average_weekly_chats
      label: Average Weekly Chats
      expression: |-
        if(row() = 1,
        sum(offset_list(${tickets.count_non_chats}, 1, 12)) / 12,
        null)
      value_format: '0'
    - table_calculation: this_week_compared_to_average
      label: This week compared to average
      expression: |
        concat(round(100 * (${tickets.count_non_chats} - ${average_weekly_chats}) /${average_weekly_chats},0), "%")
      value_format: ''
    - table_calculation: with_arrows
      label: with arrows
      expression: "if(${tickets.count_non_chats} - ${average_weekly_chats}\
        \ > 0, \nconcat(\"⬆\", ${this_week_compared_to_average}),\nreplace(${this_week_compared_to_average},\"\
        -\",\"⬇\")\n)\n\n"
    - table_calculation: final
      label: final!
      expression: concat(${tickets.count_non_chats}, " ",${with_arrows})
    hidden_fields: [tickets.created_week, average_weekly_chats, this_week_compared_to_average,
      with_arrows, tickets.count_non_chats]
    filters:
      tickets.created_date: 13 weeks
    sorts: [tickets.created_week desc]
    limit: 500
    font_size: fit
    text_color: black
  