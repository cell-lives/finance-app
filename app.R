# app.R
library(shiny)
library(shinydashboard) # 新增必要的包
library(DT)
library(ggplot2)
library(dplyr)
library(lubridate)

# 初始化数据存储
if (!file.exists("/app/data/data.csv")) {
  data.frame(
    Date = as.Date(character()),
    Type = character(),
    Category = character(),
    Amount = numeric(),
    Description = character(),
    stringsAsFactors = FALSE
  ) %>% write.csv("/app/data/data.csv", row.names = FALSE)
}

# UI 界面
ui <- fluidPage(
  titlePanel("智能记账系统 v1.0"),
  tags$style(
    type = "text/css",
    ".dt-button { margin: 5px; }",
    ".shiny-output-error { visibility: hidden; }"
  ), # 错误信息隐藏

  sidebarLayout(
    sidebarPanel( # 左侧输入面板
      width = 3,
      h4("新增记录"),
      dateInput("date", "日期", value = Sys.Date()),
      selectInput("type", "类型",
        choices = c("支出" = "expense", "收入" = "income")
      ),
      selectInput("category", "分类",
        choices = list(
          "支出" = c("餐饮", "购物", "住房", "交通", "娱乐"),
          "收入" = c("工资", "投资", "奖金", "其他收入")
        )
      ),
      numericInput("amount", "金额（元）", value = 0, min = 0),
      textAreaInput("desc", "备注", rows = 3),
      actionButton("submit", "提交记录", class = "btn-primary"),
      hr(),
      downloadButton("download", "导出数据")
    ),
    mainPanel( # 右侧展示面板
      width = 9,
      tabsetPanel(
        tabPanel(
          "记录管理",
          DTOutput("records_table"),
          actionButton("delete", "删除选中记录", class = "btn-danger")
        ),
        tabPanel(
          "统计分析",
          plotOutput("category_plot"),
          h4("财务概览"),
          fluidRow(
            shinydashboard::valueBoxOutput("total_income", width = 4), # 全限定调用
            shinydashboard::valueBoxOutput("total_expense", width = 4),
            shinydashboard::valueBoxOutput("balance", width = 4)
          )
        )
      )
    )
  )
)

# Server 逻辑
server <- function(input, output, session) {
  # 响应式数据
  records <- reactiveVal({
    read.csv("data.csv") %>%
      mutate(Date = as.Date(Date)) %>%
      arrange(desc(Date))
  })

  # 类别选择联动
  observe({
    updateSelectInput(session, "category",
      choices = switch(input$type,
        "expense" = c("餐饮", "购物", "住房", "交通", "娱乐"),
        "income" = c("工资", "投资", "奖金", "其他收入")
      )
    )
  })

  # 提交新记录
  observeEvent(input$submit, {
    req(input$amount > 0) # 必须输入有效金额

    new_entry <- data.frame(
      Date = input$date,
      Type = input$type,
      Category = input$category,
      Amount = ifelse(input$type == "expense", -abs(input$amount), abs(input$amount)),
      Description = input$desc
    )

    updated_data <- rbind(new_entry, records())
    write.csv(updated_data, "data.csv", row.names = FALSE)
    records(updated_data)

    showNotification("记录已保存！", type = "message")
  })

  # 显示记录表格
  output$records_table <- renderDT({
    req(records())
    datatable(
      records() %>%
        mutate(Amount = ifelse(Type == "expense", -Amount, Amount)) %>%
        mutate(Amount = sprintf("¥%.2f", Amount)),
      selection = "multiple",
      options = list(pageLength = 10, autoWidth = TRUE),
      rownames = FALSE
    ) %>%
      formatStyle("Amount", color = JS("value.startsWith('¥-') ? 'red' : 'darkgreen'"))
  })

  # 删除记录
  observeEvent(input$delete, {
    if (!is.null(input$records_table_rows_selected)) {
      updated <- records()[-input$records_table_rows_selected, ]
      write.csv(updated, "data.csv", row.names = FALSE)
      records(updated)
    }
  })

  # 数据导出
  output$download <- downloadHandler(
    filename = function() {
      paste0("finance_records_", Sys.Date(), ".csv")
    },
    content = function(file) {
      write.csv(records(), file, row.names = FALSE)
    }
  )

  # 财务概览指标
  output$total_income <- shinydashboard::renderValueBox({ # 全限定调用
    total <- sum(records()$Amount[records()$Type == "income"])
    shinydashboard::valueBox(
      value = sprintf("¥%.2f", total),
      subtitle = "累计收入",
      icon = icon("hand-holding-usd"),
      color = "green"
    )
  })

  output$total_expense <- shinydashboard::renderValueBox({
    total <- abs(sum(records()$Amount[records()$Type == "expense"]))
    shinydashboard::valueBox(
      value = sprintf("¥%.2f", total),
      subtitle = "累计支出",
      icon = icon("credit-card"),
      color = "red"
    )
  })

  output$balance <- shinydashboard::renderValueBox({
    total <- sum(records()$Amount)
    shinydashboard::valueBox(
      value = sprintf("¥%.2f", total),
      subtitle = "当前结余",
      icon = icon("balance-scale"),
      color = ifelse(total >= 0, "blue", "orange")
    )
  })

  # 分类统计图表（保留原功能）
  output$category_plot <- renderPlot({
    df <- records() %>%
      group_by(Type, Category) %>%
      summarise(Amount = sum(abs(Amount)), .groups = "drop")

    ggplot(df, aes(x = reorder(Category, Amount), y = Amount, fill = Type)) +
      geom_col() +
      scale_fill_manual(values = c("income" = "#4CAF50", "expense" = "#F44336")) +
      labs(title = "分类统计", x = "分类", y = "金额（元）") +
      theme_minimal(base_size = 14) +
      coord_flip()
  })
}

# 运行应用
shinyApp(ui = ui, server = server)
