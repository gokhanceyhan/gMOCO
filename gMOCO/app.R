#install.packages("shiny")
#install.packages("shinydashboard")
#install.packages("plotly")


library(shiny)
library(shinydashboard)
library(plotly)




ui <- dashboardPage(
  dashboardHeader(title = "onlinemoco visualizer"),
  dashboardSidebar(
    sidebarMenu(id = "sidebar",
                menuItem("Data", tabName = "data", icon = icon("th")),
                menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
                fileInput("file1", "Choose CSV File",
                          accept = c(
                            "text/csv",
                            "text/comma-separated-values,text/plain",
                            ".csv")
                )
    )
  ),
  dashboardBody(
    tabItems(
      tabItem(tabName = "dashboard",
              fluidRow(
                valueBoxOutput("numOfObjectives"),
                valueBoxOutput("numOfPoints"),
                valueBoxOutput("coverage")
              ),
              fluidRow(
                tabBox(
                  title = "Inputs", width = 4,
                  # The id lets us use input$tabset1 on the server to find the current tab
                  id = "tabset1", height = "250px",
                  tabPanel("z1",
                           "Select a range for criterion values:",
                           sliderInput("slider1", "z1:", 1, 100, value = c(1,100), dragRange = TRUE)
                  ),
                  tabPanel("z2",
                           "Select a range for criterion values:",
                           sliderInput("slider2", "z1:", 1, 100, value = c(1,100), dragRange = TRUE)
                  ),
                  tabPanel("z3",
                           "Select a range for criterion values:",
                           sliderInput("slider3", "z1:", 1, 100, value = c(1,100), dragRange = TRUE)
                  )
                )
              ),
              fluidRow(
                box(
                  title = "Scatter Plot", status = "success", solidHeader = TRUE,
                  collapsible = TRUE,
                  selectInput("scatterPlotSelect1", "Select 2 or 3 criteria:",
                              c("z1", "z2", "z3"), selected = c("z1", "z2", "z3"), multiple = TRUE
                  ),
                  plotlyOutput("plot1")
                ),
                box(
                  title = "Parallel Coordinates Plot", status = "warning", solidHeader = TRUE,
                  collapsible = TRUE,
                  plotlyOutput("plot2")
                )
              )
      ),
      tabItem(tabName = "data",
              tableOutput("contents")
              
      )
    )
  )
)

server <- function(input, output, session) {
  output$contents <- renderTable({
    inFile <- input$file1
    
    if (is.null(inFile))
      return(NULL)
    
    ndpoints <-read.csv(inFile$datapath, header = TRUE, sep = ",")
    
    # render value boxes
    nobj = ncol(ndpoints)
    npoints = nrow(ndpoints)
    
    output$numOfObjectives <- renderValueBox({
      valueBox(nobj, "criteria", icon = icon("arrows"), color = "blue")
    })
    output$numOfPoints <- renderValueBox({
      valueBox(npoints, "nondominated points", icon = icon("archive"), color = "olive")
    })
    output$coverage <- renderValueBox({
      valueBox(10, " % coverage gap", icon = icon("pie-chart"), color = "orange")
    })
    
    # update the slider input box
    updateSliderInput(session, "slider1", 
                      min = min(ndpoints$z1, na.rm = TRUE),
                      max = max(ndpoints$z1, na.rm = TRUE),
                      value = c(min,max)
    )
    updateSliderInput(session, "slider2", 
                      min = min(ndpoints$z2, na.rm = TRUE),
                      max = max(ndpoints$z2, na.rm = TRUE),
                      value = c(min,max)
    )
    updateSliderInput(session, "slider3", 
                      min = min(ndpoints$z3, na.rm = TRUE),
                      max = max(ndpoints$z3, na.rm = TRUE),
                      value = c(min,max)
    )
    
    
    # render scatter plot
    output$plot1 <- renderPlotly({
      filtered_points <- ndpoints[which(ndpoints$z1 >= input$slider1[1]
                                        & ndpoints$z1 <= input$slider1[2]
                                        & ndpoints$z2 >= input$slider2[1]
                                        & ndpoints$z2 <= input$slider2[2]
                                        & ndpoints$z3 >= input$slider3[1]
                                        & ndpoints$z3 <= input$slider3[2]),]
      if(NROW(input$scatterPlotSelect1) < 2 | NROW(input$scatterPlotSelect1) > 3  )
        return (NULL)
      else if(NROW(input$scatterPlotSelect1) ==2){
        if((input$scatterPlotSelect1[1]=="z1" & input$scatterPlotSelect1[2]=="z2")|
           (input$scatterPlotSelect1[1]=="z2" & input$scatterPlotSelect1[2]=="z1")){
          p <- plot_ly(filtered_points, x = ~z1, y = ~z2) %>%
            add_markers() %>%
            layout(scene = list(xaxis = list(title = 'z1'),
                                yaxis = list(title = 'z2')))
          return (p)
        }
        if((input$scatterPlotSelect1[1]=="z1" & input$scatterPlotSelect1[2]=="z3")|
           (input$scatterPlotSelect1[1]=="z3" & input$scatterPlotSelect1[2]=="z1")){
          p <- plot_ly(filtered_points, x = ~z1, y = ~z3) %>%
            add_markers() %>%
            layout(scene = list(xaxis = list(title = 'z1'),
                                yaxis = list(title = 'z3')))
          return (p)
        }
        if((input$scatterPlotSelect1[1]=="z2" & input$scatterPlotSelect1[2]=="z3")|
           (input$scatterPlotSelect1[1]=="z3" & input$scatterPlotSelect1[2]=="z2")){
          p <- plot_ly(filtered_points, x = ~z2, y = ~z3) %>%
            add_markers() %>%
            layout(scene = list(xaxis = list(title = 'z2'),
                                yaxis = list(title = 'z3')))
          return (p)
        }
      } 
      else {
        p <- plot_ly(filtered_points, x = ~z1, y = ~z2, z = ~z3) %>%
          add_markers() %>%
          layout(scene = list(xaxis = list(title = 'z1'),
                              yaxis = list(title = 'z2'),
                              zaxis = list(title = 'z3')))
        return (p)
      }
    })
    
    # render parallel coordinates plot
    output$plot2 <- renderPlotly({
      filtered_points <- ndpoints[which(ndpoints$z1 >= input$slider1[1]
                                        & ndpoints$z1 <= input$slider1[2]
                                        & ndpoints$z2 >= input$slider2[1]
                                        & ndpoints$z2 <= input$slider2[2]
                                        & ndpoints$z3 >= input$slider3[1]
                                        & ndpoints$z3 <= input$slider3[2]),]
      p <- plot_ly(type = 'parcoords', line = list(color = 'blue'),
                   dimensions = list(
                     list(range = c(input$slider1[1],input$slider1[2]),
                          label = 'z1', values = filtered_points$z1),
                     list(range = c(input$slider2[1],input$slider2[2]),
                          label = 'z2', values = filtered_points$z2),
                     list(range = c(input$slider3[1],input$slider3[2]),
                          label = 'z3', values = filtered_points$z3)
                   )
      )
      return (p)
    })
    
    
    return (ndpoints)
  })
  
}

shinyApp(ui,server)