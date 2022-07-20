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
                                                      "PM2.5 pollution"="PM2.5",       
                                                      "AQM station"="AQ Station"
                                                             ),
                                                  justified = TRUE
                                              ),
                                              pickerInput(
                                                  inputId = "pop_selector",
                                                  label = "select population ",
                                                  choices = c("All Population"="all", 
                                                              "Infant (0-4)" ="child", 
                                                              "Elderlies (65+)" = "old", 
                                                              "Pregnant Woman" = "pregs"
                                                              )
                                              )

                                          )
                                          )
                               ), 
                               fluidRow(
                                   tabsetPanel(type = "tabs",
                                               tabPanel("Rank 20 Cities",
                                                        
                                                        div(class="rank20_selector", style="display:inline",
                                                            wellPanel(
                                                                pickerInput(
                                                                    inputId = "brk_selector",
                                                                    label = "select break point",
                                                                    choices = c("5 km"="5km", 
                                                                                "10 km" ="10km", 
                                                                                "25 km" = "25km"
                                                                    )
                                                                ),
                                                                pickerInput(
                                                                    inputId = "number_selector",
                                                                    label = "select display number",
                                                                    choices = c("number of people"="main_count", 
                                                                                "% of all people" ="main_all_perc", 
                                                                                "% of this population" = "main_group_perc"
                                                                    )
                                                                )    
                                                            )
                                                        ),
                                                        
                                                        navlistPanel(widths = c(2, 10),
                                                            tabPanel("Plot", plotlyOutput("rank20_chart")),
                                                            tabPanel("Table", DT::dataTableOutput("rank20_table"))
                                                            
                                                        )
                                                        
                                                        ),
                                               tabPanel("City Situation")
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

