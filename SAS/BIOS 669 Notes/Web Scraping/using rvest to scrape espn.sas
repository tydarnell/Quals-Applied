proc iml;

    submit / R;
        library(rvest)
        url <- "http://www.espn.com/mens-college-basketball/team/stats/_/id/153"
        web <- read_html(url)
        tab <- html_table(web, fill=TRUE)
        typeof(tab)
        names(tab)
        game_stats <- tab[[1]]
        season_stats <- tab[[2]]
    endsubmit;
    
    call ImportDatasetFromR("work.game_statsUNC201617","game_stats");
    call ImportDatasetFromR("work.season_statsUNC201617","season_stats");

    submit / R;
        library(rvest)
        url <- "http://www.espn.com/mens-college-basketball/team/stats/_/id/153/year/2016"
        web <- read_html(url)
        tab <- html_table(web, fill=T)
        typeof(tab)
        names(tab)
        game_stats <- tab[[1]]
        season_stats <- tab[[2]]
    endsubmit;
    
    call ImportDatasetFromR("work.game_statsUNC201516","game_stats");
    call ImportDatasetFromR("work.season_statsUNC201516","season_stats");

quit;