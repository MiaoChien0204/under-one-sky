library(shiny)
source("funcs.R")

navbarPage(
    id = "navbar",
    title = "APU Dashboard",
    windowTitle = "APU Dashboard", #title for browser tab
    theme = shinytheme("cerulean"), #Theme of the app (blue navbar)
    collapsible = TRUE, #tab panels collapse into menu in small screens
    header = tags$head(
        tags$link(rel = "stylesheet", type = "text/css", href = cssFile),
        # HTML("<html lang='en'>"),
        # tags$link(rel="shortcut icon", href="favicon_scotpho.ico"), #Icon for browser tab
        #Including Google analytics
        #includeScript("google-analytics.js"),
        HTML("<base target='_blank'>")
    ),
    
        tabPanel(
            title = "India",
            fluidPage(class="main-page",
                        column(width = 7, class="left-control-panel col-md-7 col-sm-12",
                               ##### MAP CONTENT #####
                               div(class="theMap",
                                   withSpinner(leafletOutput("main_map"), type=4, size=1.5)
                                   )
                               ),
                        column(width = 5, class="right-control-panel col-md-5 col-sm-12",
                               ##### CHARTS CONTENT #####
                               fluidRow(
                                   column(width=6,
                                          wellPanel(
                                              radioGroupButtons(
                                                  inputId = "theme_selector",
                                                  label = "select theme:",
                                                  choices = c(
                                                      "AQM station"="AQ Station",
                                                      "PM2.5 pollution"="PM2.5"       
                                                             ),
                                                  justified = TRUE,
                                                  checkIcon = list(yes = icon("ok", lib = "glyphicon"))
                                              ),
                                              pickerInput(
                                                  inputId = "pop_selector",
                                                  label = "select group population ",
                                                  choices = c("All Population"="all", 
                                                              "Infants (0-4)" ="child", 
                                                              "Elderlies (65+)" = "old", 
                                                              "Pregnant Woman" = "pregs"
                                                              )
                                              )

                                          )
                                          )
                               ), 
                               fluidRow(
                                   tabsetPanel(type = "tabs",
                                               tabPanel("Cities Rank",
                                                        navlistPanel(widths = c(2, 10),
                                                            tabPanel("Plot", 
                                                                     conditionalPanel(
                                                                         condition = "input.theme_selector=='PM2.5'",
                                                                             wellPanel(
                                                                                 radioGroupButtons(
                                                                                     inputId = "select_pm25_rank_order",
                                                                                     label = "select rank order",
                                                                                     choices = c("good AQ"="group_a_prec", 
                                                                                                 "bad AQ"="group_c_prec"
                                                                                     ),
                                                                                     justified = TRUE
                                                                                 )
                                                                             )
                                                                     ),
                                                                     plotlyOutput("rank_stacked_chart", width = "500px", height = "1600px")
                                                            ),
                                                            tabPanel("Table", 
                                                                     DT::dataTableOutput("rank_table"),
                                                                     div(class="btn", style="margin-top:10px;",
                                                                         actionButton("btn_cleanMap", "Clean Map")
                                                                         )
                                                                     
                                                                     )
                                                            
                                                        )
                                                        
                                                        ),
                                               tabPanel("Inspect City",
                                                        uiOutput("ui_city_situaion"),
                                                        plotlyOutput("plot_city_propotion")
                                               )
                                               
                                   )
                                   
                               )

                               )

                      )
        )
        # ,
        # tabPanel(
        #     title = "Malaysia"
        # ),
        # tabPanel(
        #     title = "Tailand"
        # ),
        # tabPanel(
        #     title = "Philippines"
        # ),
        # tabPanel(
        #     title = "Indonesia"
        # ),
        # tabPanel(
        #     title = "Turkey"
        # ),
        # tabPanel(
        #     title = "South Africa"
        # ),
        # tabPanel(
        #     title = "Colombia"
        # )
    
    
    
)

