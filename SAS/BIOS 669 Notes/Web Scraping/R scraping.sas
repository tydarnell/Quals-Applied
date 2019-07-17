proc iml;
    submit / R;
            # reminder: pound sign makes a comment in R
            library(XML)
            url <- "http://www.basketball-reference.com/draft/NBA_2000.html"      
            page <- htmlTreeParse(readLines(url), useInternalNodes=T)
            # table1 <- readHTMLTable(page)
            # typeof(table1)
            # names(table1)
            table <- readHTMLTable(page)$stats  
            # typeof(table)
            # names(table)
            players <- subset(table, Player!="Player" & Yrs !="Totals")       
            players$Draft_Yr <- 2000  
            # typeof(players)
    endsubmit;

    Call ImportDatasetFromR("Work.NBA_Draft_2000", "players");
quit;


proc iml;
    submit / R;
        library(XML)

        years <- 2000:2018
        rdata <- NULL    

        for (i in years) {
            url <- paste("http://www.basketball-reference.com/draft/NBA_", i, ".html", sep="")      
            page <- htmlTreeParse(readLines(url), useInternalNodes=T)
            table <- readHTMLTable(page)$stats      
            players <- subset(table, Player!="Player" & Yrs !="Totals")       
            players$Draft_Yr <- i     
            rdata <- rbind(rdata, players)      
        }

    endsubmit;

    call ImportDatasetFromR("Work.NBA_Draft", "rdata");

quit;
