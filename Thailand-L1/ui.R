library(shiny)
source("funcs.R")

shinyUI(
    fluidPage(
        
        navbarPage(
            id = "navbar",
            
            theme = shinytheme("readable"), #Theme of the app (blue navbar)
            collapsible = FALSE, #tab panels collapse into menu in small screens
            header = tags$head(
                HTML("<title>Different air under one sky</title>"),
                HTML("<link rel='icon', href='favicon.png', type='image/png' />"),
                tags$link(rel = "stylesheet", type = "text/css", href = cssFile),
                tags$meta(charset="UTF-8"),
                tags$meta(`http-equiv`="pragma", content="no-cache"),
                tags$meta(`http-equiv`="Cache-Control", content="no-cache, must-revalidate"),
                tags$meta(`http-equiv`="expires", content="0"),
                
                #Including Google analytics
                #includeScript("google-analytics.js"),
                tags$meta(name="title", content="Different air under one sky"),
                tags$meta(name="description", content="Different air under one sky"),
                tags$meta(property="og:type", content="website"),
                tags$meta(property="og:title", content="Different air under one sky"),
                tags$meta(property="og:description", content="Different air under one sky"),
                tags$meta(property="og:image", href = "preview.jpg", type="image/png"),
                tags$meta(name="viewport", content="width=device-width, initial-scale=1.0"),
                HTML("<base target='_blank'>"),
                tags$script("
                  Shiny.addCustomMessageHandler('changetitle', function(title) {
                    document.title = title
                  });
                ")
            ),
            title = div(img(src="title.jpg", style="width: 20vw;")),
            tabPanel(
                withMathJax(),
                title = COUNTRY,
                #### 
                div(class="nav-logo",
                    img(src="logo.png", style="width: 8vw;")
                    ),
                div(class="nav-icon",
                    actionButton(
                        inputId = "btn_disclaimer",
                        label = NULL, 
                        icon = icon("info")
                    ),
                    actionButton(
                                inputId = "btn_link",
                                label = NULL,
                                icon = icon("book-open"),
                                onclick = "window.open('https://www.greenpeace.org/india/en/?p=14159&preview=true/', '_blank')"
                            )
                ),
               
                fluidPage(class="main-page",
                          column(width = 7, class="left-control-panel col-md-7 col-sm-12",
                                 ##### MAP CONTENT #####
                                 div(class="theMap",
                                     withSpinner(leafletOutput("main_map"), type=4, size=1.5)
                                 )
                          ),
                          column(width = 5, class="right-control-panel col-md-5 col-sm-12",
                                 
                                 #### 2 row type ####
                                 fluidRow(
                                     column( width = 12,
                                             fluidRow(
                                                 column(width=6,
                                                        radioGroupButtons(
                                                            inputId = "theme_selector",
                                                            label = "Select theme:",
                                                            choices = c(
                                                                "AQ Station" = "AQ Station",
                                                                'PM\\(_{2.5} \\)' = "PM2.5"
                                                            ),
                                                            justified = TRUE,
                                                            checkIcon = list(yes = icon("ok", lib = "glyphicon"))
                                                        )
                                                 ),
                                                 column(width = 6,
                                                        pickerInput(
                                                            inputId = "pop_selector",
                                                            label = "Select group population ",
                                                            choices = c("All Population"="all",
                                                                        "Infants (under 5)" ="child",
                                                                        "Older adults (over 65)" = "old",
                                                                        "Pregnant people" = "pregs"
                                                            )
                                                        )
                                                 )
                                             ),
                                             fluidRow(
                                                 uiOutput("ui_desc"),
                                             )
                                     )
                                     
                                 ), 
                                 fluidRow(
                                     tabsetPanel(
                                         id = "tabs_viewType",
                                         type = "tabs",
                                         tabPanel("Selected Area",
                                                  uiOutput("ui_city_situaion"),
                                                  plotlyOutput("plot_city_propotion", width = "100%", height = "30vh")
                                         ),
                                         tabPanel("Ranking Plot",
                                                  
                                                  ##### 2 row style ######
                                                  fluidRow(
                                                      plotlyOutput("rank_stacked_chart", width = "100%", height = "40vh")
                                                  ),
                                                  fluidRow(
                                                      column(width=2),
                                                      column(width=8,
                                                             conditionalPanel(
                                                                 condition = "input.theme_selector=='PM2.5'",
                                                                 radioGroupButtons(
                                                                     inputId = "select_pm25_rank_order",
                                                                     label = "Choose ranking method",
                                                                     choices = c("Lowest exposure"="group_a_prec",
                                                                                 "Highest exposure"="group_c_prec"
                                                                     ),
                                                                     checkIcon = list(yes = icon("ok", lib = "glyphicon")),
                                                                     justified = TRUE
                                                                 )
                                                             )
                                                      ),
                                                      column(width=2),
                                                      
                                                      
                                                  )
                                                  
                                         )
                                         
                                         
                                     )
                                     
                                 )
                                 
                          )
                          
                )
            ),
            navbarMenu(
                title = "Select country",
                HTML(
                '<a href="../Colombia/" target="_self">Colombia</a>
                 <a href="../India/" target="_self">India</a>
                 <a href="../Indonesia/" target="_self">Indonesia</a>
                 <a href="../Malaysia/" target="_self">Malaysia</a>
                 <a href="../Philippines/" target="_self">Philippines</a>
                 <a href="../SouthAfrica/" target="_self">South Africa</a>
                 <a href="../Thailand/" target="_self">Thailand</a>
                 <a href="../Turkey/" target="_self">Turkey</a>
                ')
                
            )
            
        )
        
        
    )
    
)
    