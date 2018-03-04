# vMOCO
A visualization tool for the nondominated points of multi-objective integer programming problems. The underlying motivation behind this application is to provide a ready-to-use visualization tools
for the ones working on multi-criteria decision making problems.

## Getting Started
This application has been built on the Shiny web application framework provided by RStudio. In this repository, we provide the source code
specific to the three-dimensional data. It can also be used for two-dimensional data by creating an artificial additional dimension to your points.
For higher dimensions, the source code can be easily modified by the ones familiar with the R language.

### Prerequisites

In order to be able to get the application running, you need to first download [RStudio](https://www.rstudio.com/products/rstudio/download/). 
You can dowload the free desktop version. Once you installed the RStudio on your computer, you should follow these steps:

```
Create a new project and a new file of type R script.
```

In order to install the required libraries, just comment out the four lines at the top of the file. 
Do this for only the first run of the applciation. You can comment them again after the first run.
Alternatively, you can run the following commands from the console:

```
install.packages("shiny")
install.packages("shinydashboard")
install.packages("plotly")
install.packages("DT")
```

## Deployment

If you would like to deploy your application to the cloud to be able to use it from anywhere, you can sign up a free account
at [Shinyapps.io](https://shiny.rstudio.com/deploy/). In this case, follow the steps at [Shinyapps.io/Getting started](https://shiny.rstudio.com/articles/shinyapps.html)


## Authors

* **Gokhan Ceyhan** 


