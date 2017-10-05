dashboardPage(
  dashboardHeader(title = "Monitoramento do Papo Correria"),
  dashboardSidebar(
    #sliderInput("rateThreshold", "Warn when rate exceeds",
    #  min = 0, max = 50, value = 3, step = 0.1
    #),
    sidebarMenu(
      menuItem("Dashboard", tabName = "dashboard"),
      #menuItem("Raw data", tabName = "rawdata"),
      textInput("urlpost", 
                "URL do post", 
                value = "https://www.facebook.com/ruicostaoficial/photos/a.343034462495371.1073741828.342905935841557/1158675754264567/?type=3"
      ),
      # textInput("fbid", 
      #           "Escreva o ID da página do Facebook onde foi publicado esse post:", 
      #           value = "acesse http://findmyfbid.com/ para obter o ID..."
      # ),
      dateInput('date',
                label = 'Data do post:',
                value = Sys.Date()
      )
    )
  ),
  dashboardBody(
    tabItems(
      tabItem("dashboard",
        fluidRow(
          valueBoxOutput("rate"),
          valueBoxOutput("count"),
          valueBoxOutput("users")
        ),
        fluidRow(
          #box(
          #  width = 4, status = "info", solidHeader = TRUE,
          #  title = "Popularity by package (last 5 min)",
#            plotOutput("wordcloudPlot", width="100%", height= 600)
          #  bubblesOutput("packagePlot", width = "100%", height = 600)
          #),
          box(
            width = 4, status = "info", solidHeader = TRUE,
            title = "Reações",
            plotOutput("reactionsPlot", width="100%", height= 600)
          ),
          box(
            width = 4, status = "info", solidHeader = TRUE,
            title = "Comentários",
            plotOutput("commentsPlot", width="100%", height= 600)
          ),
          box(
             width = 8, status = "info", solidHeader = TRUE,
             title = "Wordcloud",
             plotOutput("wordcloudPlot", width="100%", height= 600)
          )
          #,
          #box(
          #  width = 4, status = "info",
          #  title = "Top packages (last 5 min)",
          #  tableOutput("packageTable")
          #)
        )
      )#,
      #tabItem("rawdata",
      #  numericInput("maxrows", "Rows to show", 25),
      #  verbatimTextOutput("rawtable"),
      #  downloadButton("downloadCsv", "Download as CSV")
      #)
    )
  )
)

