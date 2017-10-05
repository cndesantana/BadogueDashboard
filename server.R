function(input, output, session) {

  # pkgStream is a reactive expression that represents a stream of
  # new package download data; up to once a second it may return a
  # data frame of new downloads since the last update.
  pkgStream <- packageStream(session)

  # Max age of data (5 minutes)
  maxAgeSecs <- 60 * 5

  # pkgData is a reactive expression that accumulates previous
  # values of pkgStream, discarding any that are older than
  # maxAgeSecs.
  pkgData <- packageData(pkgStream, maxAgeSecs)

  # dlCount is a reactive expression that keeps track of the total
  # number of rows that have ever appeared through pkgStream.
  dlCount <- downloadCount(pkgStream)

  # usrCount is a reactive expression that keeps an approximate
  # count of all of the unique users that have been seen since the
  # app started.
  usrCount <- userCount(pkgStream)

  # Record the time that the session started.
  startTime <- as.numeric(Sys.time())

  output$rate <- renderValueBox({
    # The downloadRate is the number of rows in pkgData since
    # either startTime or maxAgeSecs ago, whichever is later.
    elapsed <- as.numeric(Sys.time()) - startTime
    downloadRate <- nrow(pkgData()) / min(maxAgeSecs, elapsed)

    valueBox(
      value = formatC(downloadRate, digits = 1, format = "f"),
      subtitle = "Downloads per sec (last 5 min)",
      icon = icon("area-chart"),
      color = if (downloadRate >= input$rateThreshold) "yellow" else "aqua"
    )
  })

  output$count <- renderValueBox({
    valueBox(
      value = dlCount(),
      subtitle = "Total downloads",
      icon = icon("download")
    )
  })

  output$users <- renderValueBox({
    valueBox(
      usrCount(),
      "Unique users",
      icon = icon("users")
    )
  })

  plotWordcloud = function(){
     url <- input$urlpost
     #     id_pagina <- input$fbid 
     id_pagina <- getFBID(url)
     data <- input$date
     
     # command file.path already controls for the OS
#     load(paste(workdir,"/fb_oauth",sep=""));

     load("/home/cdesantana/DataSCOUT/Objectiva/PapoCorreria/dashboard/fb_oauth")     
     data_inicio <- ymd(as.character(data)) + days(-2);
     data_final <- ymd(as.character(data)) + days(2);
     
     mypage <- getPage(id_pagina, token = fb_oauth, feed=TRUE, since= as.character(data_inicio), until=as.character(data_final))
     id_post <- mypage$id[which(as.character(mypage$link)%in%url)]
     
     post_dados <- getPost(id_post, token=fb_oauth, n= 10000)
     text <- post_dados$comments$message
     mydfm <- getDFMatrix(text);
     set.seed(100)
     textplot_wordcloud(mydfm, min.freq = 3, random.order = FALSE,
                        rot.per = .25, 
                        colors = RColorBrewer::brewer.pal(8,"Dark2"))
  }

  output$commentsPlot <- renderPlot({
     url <- input$urlpost
     #     id_pagina <- input$fbid 
     id_pagina <- getFBID(url)
     data <- input$date
     
     # command file.path already controls for the OS
     #     load(paste(workdir,"/fb_oauth",sep=""));
     load("/home/cdesantana/DataSCOUT/Objectiva/PapoCorreria/dashboard/fb_oauth")     
     
     data_inicio <- ymd(as.character(data)) + days(-2);
     data_final <- ymd(as.character(data)) + days(2);
     
     mypage <- getPage(id_pagina, token = fb_oauth, feed=TRUE, since= as.character(data_inicio), until=as.character(data_final))
     id_post <- mypage$id[which(as.character(mypage$link)%in%url)]
     
     post_dados <- getPost(id_post, token=fb_oauth, n= 10000)
     timeseries <- post_dados$comments %>% mutate(
        day = ymd_hms(created_time) %>%
           as.Date() %>%
           format("%d"), 
        month = ymd_hms(created_time) %>%
           as.Date() %>%
           format("%m"), 
        year = ymd_hms(created_time) %>%
           as.Date() %>%
           format("%Y"), 
        hour = ymd_hms(created_time) %>%
           format("%H"), 
        min = ymd_hms(created_time) %>%
           format("%M")
     ) %>%
        group_by(year,month,day,hour,min) %>%
        summarise(total = n())
     
     timeseries$hour <- as.numeric(timeseries$hour) - 3
     timeseries$hour <- as.character(timeseries$hour)
     
     dates <- paste(timeseries$day,timeseries$month,timeseries$year,sep="/");
     times <- paste(timeseries$hour,timeseries$min,sep=":");
     myx <- paste(dates, times)
     mydate <- strptime(myx, "%d/%m/%Y %H:%M")
     myy <- timeseries$total
     
     ggplot() + geom_line(stat = "identity", aes(x = mydate, y = myy)) + ylab("Audiência") + xlab("Tempo")
   })
    
  output$reactionsPlot <- renderPlot({
     url <- input$urlpost
     #     id_pagina <- input$fbid 
     id_pagina <- getFBID(url)
     data <- input$date
     
     # command file.path already controls for the OS
     #     load(paste(workdir,"/fb_oauth",sep=""));
     load("/home/cdesantana/DataSCOUT/Objectiva/PapoCorreria/dashboard/fb_oauth")     
     
     data_inicio <- ymd(as.character(data)) + days(-2);
     data_final <- ymd(as.character(data)) + days(2);
     
     mypage <- getPage(id_pagina, token = fb_oauth, feed=TRUE, since= as.character(data_inicio), until=as.character(data_final))
     id_post <- mypage$id[which(as.character(mypage$link)%in%url)]
     
     post_reactions <- getReactions(id_post, token=fb_oauth)
     counts <- as.numeric(post_reactions[,-1])
     reactions <- c("Likes","Loves","Haha","Wow","Sad", "Angry")
     percent <- signif(100*(counts/sum(counts)),1)
     ggplot() + 
        geom_bar(stat="identity", aes(x=reactions, y = counts)) + 
        xlab("Reações") + 
        ylab("Número de Ocorrências") + 
        coord_flip()
     
  })
  
  output$wordcloudPlot <- renderPlot({
     url <- input$urlpost
     #     id_pagina <- input$fbid 
     id_pagina <- getFBID(url)
     data <- input$date
     
     # command file.path already controls for the OS
#     load(paste(workdir,"/fb_oauth",sep=""));
     load("/home/cdesantana/DataSCOUT/Objectiva/PapoCorreria/dashboard/fb_oauth")     
     
     data_inicio <- ymd(as.character(data)) + days(-2);
     data_final <- ymd(as.character(data)) + days(2);
     
     mypage <- getPage(id_pagina, token = fb_oauth, feed=TRUE, since= as.character(data_inicio), until=as.character(data_final))
     id_post <- mypage$id[which(as.character(mypage$link)%in%url)]
     
     post_dados <- getPost(id_post, token=fb_oauth, n= 10000)
     text <- post_dados$comments$message
     mydfm <- getDFMatrix(text);
     set.seed(100)
     textplot_wordcloud(mydfm, min.freq = 3, random.order = FALSE,
                        rot.per = .25, 
                        colors = RColorBrewer::brewer.pal(8,"Dark2"))
     
   })
  
  output$packagePlot <- renderBubbles({
    if (nrow(pkgData()) == 0)
      return()

    order <- unique(pkgData()$package)
    df <- pkgData() %>%
      group_by(package) %>%
      tally() %>%
      arrange(desc(n), tolower(package)) %>%
      # Just show the top 60, otherwise it gets hard to see
      head(60)
    
    bubbles(df$n, df$package, key = df$package)
  })

  output$packageTable <- renderTable({
    pkgData() %>%
      group_by(package) %>%
      tally() %>%
      arrange(desc(n), tolower(package)) %>%
      mutate(percentage = n / nrow(pkgData()) * 100) %>%
      select("Package name" = package, "% of downloads" = percentage) %>%
      as.data.frame() %>%
      head(15)
  }, digits = 1)

  output$downloadCsv <- downloadHandler(
    filename = "cranlog.csv",
    content = function(file) {
      write.csv(pkgData(), file)
    },
    contentType = "text/csv"
  )

  output$rawtable <- renderPrint({
    orig <- options(width = 1000)
    print(tail(pkgData(), input$maxrows))
    options(orig)
  })
}


