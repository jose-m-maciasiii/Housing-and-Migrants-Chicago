library(tidytext)
library(textdata)
library(tidyverse)
library(sentimentr)
library(udpipe)
library(SnowballC)
library(rvest)
library(stargazer)

#Webscrape
#I did 2024 by itself since it only had 2 month and it seemed too much of a hasle to code seperate breaks just for 2024 #sue me

###2024####
##Feb

feb_url <- "https://gov.texas.gov/news/archive/2024/02"
      
response <- read_html(feb_url)

      title <- response %>%
        html_elements("h3.textTransform-none.h5 a") %>%
        html_text(trim = TRUE)
  
      link <- response %>%
        html_elements("a.readMore") %>%
        html_attr("href")
      
      date <- response %>%
        html_elements("div.date.date--horiz") %>%
        html_text() 
      
     
      # Cleaning up and putting into dataframe
      df_02_2024 <- tibble(title, date, link)

##January
      
jan_url <- "https://gov.texas.gov/news/archive/2024/01"

response <- read_html(jan_url)
      
title <- response %>%
  html_elements("h3.textTransform-none.h5 a") %>%
  html_text(trim = TRUE)
      
link <- response %>%
  html_elements("a.readMore") %>%
  html_attr("href")
      
date <- response %>%
  html_elements("div.date.date--horiz") %>%
  html_text() 
      
# Cleaning up and putting into dataframe
df_01_2024 <- tibble(title, date, link)       

df_2024 <- rbind(df_01_2024,df_02_2024)

df_2024 <- df_2024 %>% 
  mutate(year = 2024) %>% 
  select(year,title,date,link)

#### Everything else ####
df_texas <- tibble()

for (i in c(2023,2022,2021)) {
  
base_url <- paste0("https://gov.texas.gov/news/archive/", i, "/")
  
  for (month in 1:12) {
    # Ensure the month is formatted with two digits
    formatted_month <- sprintf("%02d", month)
    
    # Construct the URL with the correctly formatted month
    url <- paste0(base_url, formatted_month)
    
    response <- read_html(url)
    
    title <- response %>%
      html_elements("h3.textTransform-none.h5 a") %>%
      html_text(trim = TRUE)
    
    link <- response %>%
      html_elements("a.readMore") %>%
      html_attr("href")
    
    date <- response %>%
      html_elements("div.date.date--horiz") %>%
      html_text() 
    
    
    # Only create a dataframe if there's data to add
    if (length(title) > 0 && length(date) > 0 && length(link) > 0) {
      temp_df <- tibble(year = rep(i, length(title)), title, date, link)
      df_texas <- bind_rows(df_texas, temp_df)
    }
  }

# Polite scraping: pause between requests
Sys.sleep(time = 1)
}

##write.csv(df_texas,"scrapped_article_list.csv") i wrote this file as proof of the scrappe feel free to run in it just take a minute

df_texas <- rbind(df_2024,df_texas)

filtered_df <- df_texas %>%
  filter(str_detect(title, "Operation Lone Star"))

Operation_lonestar_df <- filtered_df %>% 
  mutate(article_id = 1:103,
         date_string = paste(date, year),
         full_date = mdy(date_string)) %>% 
  select(full_date,article_id,title,link)
  
##write.csv(Operation_lonestar_df,"Operation_lonestar.csv") I use this to extract the date for the text analysis

article_count <- 1


####check####
for(link in filtered_df$link){
  content_page <- read_html(link)
  content <- content_page %>%
    html_elements(".field--name-body.field--type-text-with-summary.field--label-hidden.field--item") %>%
    html_text()
  # Adjust the file path as per your directory structure
  file_name <- paste0("C:/Users/steph/Documents/GitHub/R-DATA-2/problem-set-3-sgarner796/Text_files", "/article_", article_count, ".html") # Update path
  writeLines(content, file_name)
  article_count <- article_count + 1
}


