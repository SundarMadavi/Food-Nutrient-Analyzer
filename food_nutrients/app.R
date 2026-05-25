library(shiny)
library(tidyverse)
library(shinythemes)
library(DT)
library(plotly)

# 1. LOAD AND PREPARE DATA
final_data <- read.csv("FINAL_Nutrient_Analysis_Results.csv")

final_data <- final_data %>%
  rename_with(~ "Fat", contains("lipid")) %>%
  rename_with(~ "Carbs", contains("Carbohydrate")) %>%
  rename_with(~ "Energy", contains("Energy")) %>%
  rename_with(~ "Protein", contains("Protein"))

final_data$description <- sub(",.*", "", final_data$description)
final_data <- final_data %>%
  group_by(description) %>%
  summarise(across(where(is.numeric), mean, na.rm = TRUE), .groups = 'drop')

# 2. UI
ui <- navbarPage(
  title = div(
    img(src = "[cdn-icons-png.flaticon.com](https://cdn-icons-png.flaticon.com/512/3075/3075977.png)", 
        height = "30px", style = "margin-right: 10px;"),
    "NutriAnalyzer Pro"
  ),
  theme = shinytheme("flatly"),
  windowTitle = "NutriAnalyzer Pro",
  
  # ═══════════════════════════════════════════════════════════════
  # TAB 1: HOME / OVERVIEW
  # ═══════════════════════════════════════════════════════════════
  tabPanel(
    title = icon("home"),
    fluidPage(
      br(),
      fluidRow(
        column(12, align = "center",
               h1("Welcome to NutriAnalyzer Pro", style = "color: #2c3e50; font-weight: bold;"),
               h4("Your comprehensive food nutrition analysis tool", style = "color: #7f8c8d;"),
               hr()
        )
      ),
      
      # Quick Stats Cards
      fluidRow(
        column(3,
               wellPanel(
                 style = "background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; text-align: center; border-radius: 15px;",
                 h1(textOutput("total_foods"), style = "font-size: 48px; margin: 10px 0;"),
                 h5("Foods in Database")
               )
        ),
        column(3,
               wellPanel(
                 style = "background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%); color: white; text-align: center; border-radius: 15px;",
                 h1(textOutput("avg_calories"), style = "font-size: 48px; margin: 10px 0;"),
                 h5("Avg Calories (per 100g)")
               )
        ),
        column(3,
               wellPanel(
                 style = "background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%); color: white; text-align: center; border-radius: 15px;",
                 h1(textOutput("avg_protein"), style = "font-size: 48px; margin: 10px 0;"),
                 h5("Avg Protein (g)")
               )
        ),
        column(3,
               wellPanel(
                 style = "background: linear-gradient(135deg, #43e97b 0%, #38f9d7 100%); color: white; text-align: center; border-radius: 15px;",
                 h1("4", style = "font-size: 48px; margin: 10px 0;"),
                 h5("Analysis Tools")
               )
        )
      ),
      
      br(),
      
      # Feature Cards
      fluidRow(
        column(4,
               wellPanel(
                 style = "border-radius: 15px; border-left: 5px solid #3498db;",
                 h4(icon("search"), " Food Lookup", style = "color: #3498db;"),
                 p("Search and explore detailed nutritional information for any food in our database."),
                 actionButton("goto_lookup", "Go to Lookup", class = "btn-primary btn-sm")
               )
        ),
        column(4,
               wellPanel(
                 style = "border-radius: 15px; border-left: 5px solid #e74c3c;",
                 h4(icon("balance-scale"), " Compare Foods", style = "color: #e74c3c;"),
                 p("Compare multiple foods side-by-side to make informed dietary decisions."),
                 actionButton("goto_compare", "Go to Compare", class = "btn-danger btn-sm")
               )
        ),
        column(4,
               wellPanel(
                 style = "border-radius: 15px; border-left: 5px solid #2ecc71;",
                 h4(icon("calculator"), " Meal Calculator", style = "color: #2ecc71;"),
                 p("Calculate total nutrition for your meals with custom portions."),
                 actionButton("goto_calculator", "Go to Calculator", class = "btn-success btn-sm")
               )
        )
      )
    )
  ),
  
  # ═══════════════════════════════════════════════════════════════
  # TAB 2: FOOD LOOKUP (Single Food Details)
  # ═══════════════════════════════════════════════════════════════
  tabPanel(
    title = tagList(icon("search"), "Food Lookup"),
    fluidPage(
      br(),
      fluidRow(
        column(4,
               wellPanel(
                 style = "border-radius: 15px;",
                 h4(icon("utensils"), " Select a Food", style = "color: #2c3e50;"),
                 selectInput("single_food", "Search Food:", 
                             choices = sort(unique(final_data$description)),
                             selected = "Apples"),
                 hr(),
                 numericInput("single_grams", "Portion Size (grams):", value = 100, min = 1),
                 helpText(icon("info-circle"), " Standard serving: 100g")
               ),
               
               # Health Rating Card
               wellPanel(
                 style = "border-radius: 15px; background: #f8f9fa;",
                 h5(icon("heart"), " Health Rating", style = "color: #e74c3c;"),
                 uiOutput("health_rating")
               )
        ),
        
        column(8,
               # Nutrient Cards Row
               fluidRow(
                 column(3,
                        div(style = "background: #fff; border-radius: 15px; padding: 20px; text-align: center; box-shadow: 0 2px 10px rgba(0,0,0,0.1);",
                            icon("fire", style = "font-size: 30px; color: #e74c3c;"),
                            h2(textOutput("single_energy"), style = "margin: 10px 0; color: #2c3e50;"),
                            p("Calories", style = "color: #7f8c8d; margin: 0;")
                        )
                 ),
                 column(3,
                        div(style = "background: #fff; border-radius: 15px; padding: 20px; text-align: center; box-shadow: 0 2px 10px rgba(0,0,0,0.1);",
                            icon("drumstick-bite", style = "font-size: 30px; color: #9b59b6;"),
                            h2(textOutput("single_protein"), style = "margin: 10px 0; color: #2c3e50;"),
                            p("Protein (g)", style = "color: #7f8c8d; margin: 0;")
                        )
                 ),
                 column(3,
                        div(style = "background: #fff; border-radius: 15px; padding: 20px; text-align: center; box-shadow: 0 2px 10px rgba(0,0,0,0.1);",
                            icon("cheese", style = "font-size: 30px; color: #f39c12;"),
                            h2(textOutput("single_fat"), style = "margin: 10px 0; color: #2c3e50;"),
                            p("Fat (g)", style = "color: #7f8c8d; margin: 0;")
                        )
                 ),
                 column(3,
                        div(style = "background: #fff; border-radius: 15px; padding: 20px; text-align: center; box-shadow: 0 2px 10px rgba(0,0,0,0.1);",
                            icon("bread-slice", style = "font-size: 30px; color: #3498db;"),
                            h2(textOutput("single_carbs"), style = "margin: 10px 0; color: #2c3e50;"),
                            p("Carbs (g)", style = "color: #7f8c8d; margin: 0;")
                        )
                 )
               ),
               
               br(),
               
               # Charts
               fluidRow(
                 column(6,
                        wellPanel(
                          style = "border-radius: 15px;",
                          h5(icon("chart-pie"), " Macronutrient Distribution"),
                          plotlyOutput("single_pie", height = "300px")
                        )
                 ),
                 column(6,
                        wellPanel(
                          style = "border-radius: 15px;",
                          h5(icon("chart-bar"), " Nutrient Breakdown"),
                          plotlyOutput("single_bar", height = "300px")
                        )
                 )
               )
        )
      )
    )
  ),
  
  # ═══════════════════════════════════════════════════════════════
  # TAB 3: COMPARISON
  # ═══════════════════════════════════════════════════════════════
  tabPanel(
    title = tagList(icon("balance-scale"), "Compare"),
    fluidPage(
      br(),
      fluidRow(
        column(3,
               wellPanel(
                 style = "border-radius: 15px;",
                 h4(icon("list-check"), " Select Foods to Compare"),
                 selectInput("compare_foods", "Add Foods (max 6):", 
                             choices = sort(unique(final_data$description)), 
                             multiple = TRUE, 
                             selected = c("Apples", "Bananas", "Carrots")),
                 hr(),
                 numericInput("compare_grams", "Portion Size (grams):", value = 100, min = 1),
                 hr(),
                 radioButtons("compare_metric", "Compare By:",
                              choices = c("Energy (kcal)" = "Energy",
                                          "Protein (g)" = "Protein",
                                          "Fat (g)" = "Fat",
                                          "Carbs (g)" = "Carbs"),
                              selected = "Energy")
               )
        ),
        
        column(9,
               fluidRow(
                 column(12,
                        wellPanel(
                          style = "border-radius: 15px;",
                          h5(icon("chart-bar"), " Visual Comparison"),
                          plotlyOutput("compare_bar", height = "350px")
                        )
                 )
               ),
               
               fluidRow(
                 column(6,
                        wellPanel(
                          style = "border-radius: 15px;",
                          h5(icon("chart-line"), " Radar Comparison"),
                          plotlyOutput("compare_radar", height = "300px")
                        )
                 ),
                 column(6,
                        wellPanel(
                          style = "border-radius: 15px;",
                          h5(icon("table"), " Detailed Comparison"),
                          DTOutput("compare_table")
                        )
                 )
               )
        )
      )
    )
  ),
  
  # ═══════════════════════════════════════════════════════════════
  # TAB 4: MEAL CALCULATOR
  # ═══════════════════════════════════════════════════════════════
  tabPanel(
    title = tagList(icon("calculator"), "Meal Calculator"),
    fluidPage(
      br(),
      fluidRow(
        column(4,
               wellPanel(
                 style = "border-radius: 15px;",
                 h4(icon("plus-circle"), " Add Meal Items"),
                 selectInput("meal_food1", "Food Item 1:", choices = sort(unique(final_data$description)), selected = "Rice"),
                 numericInput("meal_grams1", "Grams:", value = 150, min = 0),
                 hr(),
                 selectInput("meal_food2", "Food Item 2:", choices = c("None", sort(unique(final_data$description))), selected = "None"),
                 conditionalPanel(
                   condition = "input.meal_food2 != 'None'",
                   numericInput("meal_grams2", "Grams:", value = 100, min = 0)
                 ),
                 hr(),
                 selectInput("meal_food3", "Food Item 3:", choices = c("None", sort(unique(final_data$description))), selected = "None"),
                 conditionalPanel(
                   condition = "input.meal_food3 != 'None'",
                   numericInput("meal_grams3", "Grams:", value = 100, min = 0)
                 )
               )
        ),
        
        column(8,
               # Total Summary Cards
               fluidRow(
                 column(12,
                        div(style = "background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border-radius: 15px; padding: 20px; color: white; margin-bottom: 20px;",
                            h4(icon("utensils"), " Meal Summary", style = "margin-bottom: 15px;"),
                            fluidRow(
                              column(3, align = "center",
                                     h2(textOutput("meal_total_cal"), style = "margin: 0;"),
                                     p("Total Calories", style = "margin: 0; opacity: 0.8;")
                              ),
                              column(3, align = "center",
                                     h2(textOutput("meal_total_protein"), style = "margin: 0;"),
                                     p("Total Protein (g)", style = "margin: 0; opacity: 0.8;")
                              ),
                              column(3, align = "center",
                                     h2(textOutput("meal_total_fat"), style = "margin: 0;"),
                                     p("Total Fat (g)", style = "margin: 0; opacity: 0.8;")
                              ),
                              column(3, align = "center",
                                     h2(textOutput("meal_total_carbs"), style = "margin: 0;"),
                                     p("Total Carbs (g)", style = "margin: 0; opacity: 0.8;")
                              )
                            )
                        )
                 )
               ),
               
               fluidRow(
                 column(6,
                        wellPanel(
                          style = "border-radius: 15px;",
                          h5(icon("chart-pie"), " Meal Composition"),
                          plotlyOutput("meal_pie", height = "300px")
                        )
                 ),
                 column(6,
                        wellPanel(
                          style = "border-radius: 15px;",
                          h5(icon("list"), " Item Breakdown"),
                          DTOutput("meal_table")
                        )
                 )
               )
        )
      )
    )
  ),
  
  # ═══════════════════════════════════════════════════════════════
  # TAB 5: DATABASE EXPLORER
  # ═══════════════════════════════════════════════════════════════
  tabPanel(
    title = tagList(icon("database"), "Database"),
    fluidPage(
      br(),
      fluidRow(
        column(12,
               wellPanel(
                 style = "border-radius: 15px;",
                 h4(icon("database"), " Complete Food Database"),
                 p("Explore all foods in the database with sorting and filtering capabilities."),
                 DTOutput("full_database")
               )
        )
      )
    )
  )
)

# 3. SERVER
server <- function(input, output, session) {
  
  # ═══════════════════════════════════════════════════════════════
  # HOME TAB OUTPUTS
  # ═══════════════════════════════════════════════════════════════
  output$total_foods <- renderText({ nrow(final_data) })
  output$avg_calories <- renderText({ round(mean(final_data$Energy, na.rm = TRUE), 0) })
  output$avg_protein <- renderText({ round(mean(final_data$Protein, na.rm = TRUE), 1) })
  
  # Navigation buttons
  observeEvent(input$goto_lookup, { updateNavbarPage(session, "Food Lookup") })
  observeEvent(input$goto_compare, { updateNavbarPage(session, "Compare") })
  observeEvent(input$goto_calculator, { updateNavbarPage(session, "Meal Calculator") })
  
  # ═══════════════════════════════════════════════════════════════
  # FOOD LOOKUP TAB
  # ═══════════════════════════════════════════════════════════════
  single_food_data <- reactive({
    req(input$single_food)
    multiplier <- input$single_grams / 100
    
    final_data %>%
      filter(description == input$single_food) %>%
      mutate(
        Energy = Energy * multiplier,
        Protein = Protein * multiplier,
        Fat = Fat * multiplier,
        Carbs = Carbs * multiplier
      )
  })
  
  output$single_energy <- renderText({ 
    round(single_food_data()$Energy, 1) 
  })
  output$single_protein <- renderText({ 
    round(single_food_data()$Protein, 1) 
  })
  output$single_fat <- renderText({ 
    round(single_food_data()$Fat, 1) 
  })
  output$single_carbs <- renderText({ 
    round(single_food_data()$Carbs, 1) 
  })
  
  output$health_rating <- renderUI({
    cal <- single_food_data()$Energy
    cal_per_100 <- cal / (input$single_grams / 100)
    
    if (cal_per_100 < 100) {
      div(style = "color: #2ecc71; font-size: 18px; font-weight: bold;",
          icon("leaf"), " Low Calorie Food",
          p(style = "font-size: 12px; color: #7f8c8d;", "Great for weight management"))
    } else if (cal_per_100 < 300) {
      div(style = "color: #f39c12; font-size: 18px; font-weight: bold;",
          icon("balance-scale"), " Moderate Calorie Food",
          p(style = "font-size: 12px; color: #7f8c8d;", "Good for balanced diet"))
    } else {
      div(style = "color: #e74c3c; font-size: 18px; font-weight: bold;",
          icon("fire"), " High Calorie Food",
          p(style = "font-size: 12px; color: #7f8c8d;", "Consume in moderation"))
    }
  })
  
  output$single_pie <- renderPlotly({
    df <- single_food_data()
    
    plot_ly(
      labels = c("Protein", "Fat", "Carbs"),
      values = c(df$Protein, df$Fat, df$Carbs),
      type = "pie",
      marker = list(colors = c("#9b59b6", "#f39c12", "#3498db")),
      textinfo = "label+percent",
      hole = 0.4
    ) %>%
      layout(showlegend = FALSE)
  })
  
  output$single_bar <- renderPlotly({
    df <- single_food_data()
    
    plot_ly(
      x = c("Energy", "Protein", "Fat", "Carbs"),
      y = c(df$Energy, df$Protein, df$Fat, df$Carbs),
      type = "bar",
      marker = list(color = c("#e74c3c", "#9b59b6", "#f39c12", "#3498db"))
    ) %>%
      layout(
        xaxis = list(title = ""),
        yaxis = list(title = "Amount")
      )
  })
  
  # ═══════════════════════════════════════════════════════════════
  # COMPARISON TAB
  # ═══════════════════════════════════════════════════════════════
  compare_data <- reactive({
    req(input$compare_foods)
    multiplier <- input$compare_grams / 100
    
    final_data %>%
      filter(description %in% input$compare_foods) %>%
      mutate(
        Energy = Energy * multiplier,
        Protein = Protein * multiplier,
        Fat = Fat * multiplier,
        Carbs = Carbs * multiplier
      )
  })
  
  output$compare_bar <- renderPlotly({
    df <- compare_data()
    metric <- input$compare_metric
    
    plot_ly(
      data = df,
      x = ~reorder(description, .data[[metric]]),
      y = ~.data[[metric]],
      type = "bar",
      marker = list(
        color = ~.data[[metric]],
        colorscale = list(c(0, "#2ecc71"), c(0.5, "#f1c40f"), c(1, "#e74c3c"))
      ),
      text = ~round(.data[[metric]], 1),
      textposition = "outside"
    ) %>%
      layout(
        xaxis = list(title = ""),
        yaxis = list(title = metric),
        showlegend = FALSE
      )
  })
  
  output$compare_radar <- renderPlotly({
    df <- compare_data()
    
    plot_ly(type = "scatterpolar", mode = "lines+markers", fill = "toself") %>%
      {
        p <- .
        for (i in 1:nrow(df)) {
          p <- add_trace(p,
                         r = c(df$Energy[i]/10, df$Protein[i], df$Fat[i], df$Carbs[i], df$Energy[i]/10),
                         theta = c("Energy/10", "Protein", "Fat", "Carbs", "Energy/10"),
                         name = df$description[i]
          )
        }
        p
      } %>%
      layout(polar = list(radialaxis = list(visible = TRUE)))
  })
  
  output$compare_table <- renderDT({
    compare_data() %>%
      mutate(across(where(is.numeric), ~round(., 1))) %>%
      datatable(
        options = list(pageLength = 5, dom = 't'),
        rownames = FALSE
      )
  })
  
  # ═══════════════════════════════════════════════════════════════
  # MEAL CALCULATOR TAB
  # ═══════════════════════════════════════════════════════════════
  meal_data <- reactive({
    items <- list()
    
    # Item 1 (always included)
    if (!is.null(input$meal_food1)) {
      item1 <- final_data %>% filter(description == input$meal_food1)
      if (nrow(item1) > 0) {
        mult1 <- input$meal_grams1 / 100
        items[[1]] <- item1 %>%
          mutate(Grams = input$meal_grams1,
                 Energy = Energy * mult1,
                 Protein = Protein * mult1,
                 Fat = Fat * mult1,
                 Carbs = Carbs * mult1)
      }
    }
    
    # Item 2
    if (!is.null(input$meal_food2) && input$meal_food2 != "None") {
      item2 <- final_data %>% filter(description == input$meal_food2)
      if (nrow(item2) > 0) {
        mult2 <- input$meal_grams2 / 100
        items[[length(items) + 1]] <- item2 %>%
          mutate(Grams = input$meal_grams2,
                 Energy = Energy * mult2,
                 Protein = Protein * mult2,
                 Fat = Fat * mult2,
                 Carbs = Carbs * mult2)
      }
    }
    
    # Item 3
    if (!is.null(input$meal_food3) && input$meal_food3 != "None") {
      item3 <- final_data %>% filter(description == input$meal_food3)
      if (nrow(item3) > 0) {
        mult3 <- input$meal_grams3 / 100
        items[[length(items) + 1]] <- item3 %>%
          mutate(Grams = input$meal_grams3,
                 Energy = Energy * mult3,
                 Protein = Protein * mult3,
                 Fat = Fat * mult3,
                 Carbs = Carbs * mult3)
      }
    }
    
    if (length(items) > 0) bind_rows(items) else NULL
  })
  
  output$meal_total_cal <- renderText({
    df <- meal_data()
    if (is.null(df)) return("0")
    round(sum(df$Energy, na.rm = TRUE), 0)
  })
  
  output$meal_total_protein <- renderText({
    df <- meal_data()
    if (is.null(df)) return("0")
    round(sum(df$Protein, na.rm = TRUE), 1)
  })
  
  output$meal_total_fat <- renderText({
    df <- meal_data()
    if (is.null(df)) return("0")
    round(sum(df$Fat, na.rm = TRUE), 1)
  })
  
  output$meal_total_carbs <- renderText({
    df <- meal_data()
    if (is.null(df)) return("0")
    round(sum(df$Carbs, na.rm = TRUE), 1)
  })
  
  output$meal_pie <- renderPlotly({
    df <- meal_data()
    if (is.null(df)) return(NULL)
    
    plot_ly(
      labels = df$description,
      values = df$Energy,
      type = "pie",
      textinfo = "label+percent",
      hole = 0.3
    ) %>%
      layout(showlegend = TRUE)
  })
  
  output$meal_table <- renderDT({
    df <- meal_data()
    if (is.null(df)) return(NULL)
    
    df %>%
      select(Food = description, Grams, Energy, Protein, Fat, Carbs) %>%
      mutate(across(where(is.numeric), ~round(., 1))) %>%
      datatable(options = list(dom = 't', pageLength = 5), rownames = FALSE)
  })
  
  # ═══════════════════════════════════════════════════════════════
  # DATABASE TAB
  # ═══════════════════════════════════════════════════════════════
  output$full_database <- renderDT({
    final_data %>%
      mutate(across(where(is.numeric), ~round(., 1))) %>%
      datatable(
        options = list(
          pageLength = 15,
          searchHighlight = TRUE
        ),
        filter = "top",
        rownames = FALSE
      )
  })
}

shinyApp(ui, server)
