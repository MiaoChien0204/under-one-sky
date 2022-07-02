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
    navbarMenu(
        "MAP", icon = icon("map"),
        tabPanel(
            title = "India",
            ##### MAP CONTENT #####
            fluidPage(class="main-page",
                        column(width = 4, class="left-control-panel col-md-4 col-sm-12", 
                               div(class="theMap",
                                   leafletOutput("main_map")
                                   )
                               ),
                        column(width = 8, class="right-control-panel col-md-8 col-sm-12", 
                               "圖表區"
                               )
                      
                      )
            
        ),
        tabPanel(
            title = "Malaysia"
        )
    ),
    navbarMenu(
        "DATASET"
    )
    
    
    
)

