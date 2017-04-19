library(shiny)
library(shinydashboard)
library(rCharts)
library(httr)
library(twitteR)
library(tm)# for text mining & computing word frequency
require(xts)
require(stringr)
library(rvest)
library(dplyr)
library(SnowballC) # for stemming of words
library(wordcloud) # generating word cloud
library(RColorBrewer) # for creating a cloud of multiple colors instead of having one single colour
library(leaflet)
library(markdown)

dheader <- dashboardHeader(title = "Sentiment Analysis of Twitter Data",
                           titleWidth = 500)
dsidebar <- dashboardSidebar(
  sidebarMenu(
    menuItem("Search Twitter", tabName="plot", icon=icon("bar-chart"),selected = TRUE),
    menuItem("Opinions about the word", tabName="opinions", icon=icon("pie-chart",lib="font-awesome")),
    menuItem("Frequency of words", tabName = "wc", icon = icon("cloud", lib="font-awesome")),
    menuItem("Top Most 10 words in analysis", tabName = "words", icon = icon("bar-chart", lib="font-awesome")),
    menuItem("Location of Tweets", tabName="loc",icon = icon("street-view", lib="font-awesome"))
    ))
    
    dbody <- dashboardBody(
      tabItems(
        tabItem(tabName = "plot",
                fluidRow(
                  column(width = 2, 
                         tabBox( width = NULL,
                                 tabPanel(h4("INPUTS"), 
                                          textInput("searchkw","Search the word:",value = "", placeholder = "Ex: #Awesome"),
                                          tags$div(
                                            HTML("Note: Ensure the word is in trends on Twitter to fetch more number of tweets")
                                          ),
                                          sliderInput("nt","Number of tweets to be fetched:", value = 100,min = 50, max = 1000, step = 10),
                                          selectInput("lang","Language:", choices = list("English" = 1), selected = 1),
                                          actionButton(inputId='actb',icon =icon("twitter"), label="Hit it!")))),
                  verbatimTextOutput("n1Text"),
                  verbatimTextOutput("n2Text"),
                  
                  box(status = "primary", width = 10, showOutput("Chart1", "nvd3"), 
                      title = "How do tweeple feel about the word?", solidHeader = TRUE,
                      collapsible = TRUE))
                ),
        tabItem(tabName = "opinions",
                fluidRow(
                  column(width = 4, 
                         tabBox( width = NULL,
                                 tabPanel(h4("Note!"), 
                                          
                                          tags$div(
                                            HTML("<h5>You're viewing the opinions about the word for which you searched.</h5></br>")
                                          ),
                                          tags$div(
                                            HTML("<h5>This chart will give you a cumulative opinion about 
                                               the word!</h5>")
                                          )
                                 )
                         )
                  ),
                  box(width = 8, showOutput("Chart2", "nvd3"), 
                      title = "What is the overall opinion towards the word?", solidHeader = TRUE,
                      collapsible = TRUE,status = "primary")
                )),
        
        tabItem(tabName = "wc",
                fluidRow(
                  column(width = 4,
                         tabBox( width = NULL,
                                 tabPanel(h4("Inputs"),
                                          sliderInput("minf","Minimum frequency of words:", value = 4 ,min = 1, max = 50, step = 1),
                                          sliderInput("maxnw","Maximum number of words:", value = 100, min = 10, max = 300, step = 1)
                                 )
                         )
                  ),
                  column(width = 8,
                         box(width = NULL, plotOutput("plotwc",height="500px"), collapsible = TRUE,
                             title = "Words frequently used in the tweets", status = "primary", solidHeader = TRUE)
                        )
                )),
        
        tabItem(tabName = "words",
                fluidRow(
                  box(width = 12, showOutput("Chart3", "nvd3"), 
                      title = "Visualizing the Top Most 10 frequency of occurrences of the words in the tweets", solidHeader = TRUE,
                      collapsible = TRUE,status = "primary")
                  
                  )),
        tabItem(tabName = "loc",
                fluidRow(
                  column(width = 3,
                         tabBox(width = NULL,
                                tabPanel(h4("Inputs"),
                                         
                                         textInput("k","Word to search:",value = "", placeholder = "#Awesome"),
                                         tags$div(
                                           HTML("Note: Tweets returned from Twitter API might be much lesser than asked. For better results, search a popular word! ")
                                         ),
                                         sliderInput("n","Number of tweets to be fetched:", value = 100, min = 500, max = 100000, step = 1),
                                         selectInput("lang","Language:", choices = list("English" = 1), selected = 1),
                                         textInput("lat","Latitude:",value = "39.952583", placeholder = "Ex: 39.952583"),
                                         textInput("long","Longitude:",value = "-75.165222", placeholder = "Ex: -75.165222"),
                                         
                                         numericInput("rad","Radius(in miles):",value = 500, min=100, max = 1000, step = 100),
                                         tags$div(
                                           HTML("Note: Use Up and Down Arrow keys to change values in steps of 100")
                                         ),
                                         actionButton("mapit","Map It!", icon = icon("map-marker"))
                                ))),
                  
                  column(width = 9,
                         box(width = NULL, solidHeader = TRUE,
                             leafletOutput("mymap", height = 500), title = "Visualize where the tweets from", status = "primary"
                         ))
                ))
        ))

dashboardPage(
  skin = "blue",
  dheader,
  dsidebar,
  dbody
)

