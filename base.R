pacman::p_load(
    renv, naniar, tsibble, gt, tidyverse, shiny, shinydashboard,
    trelliscopejs, plotly,  DT, lubridate, dashboardthemes, shinythemes,
    janitor, shinymanager, openxlsx,modelr, prettyunits, httr, devtools, jsonlite,shinyjs
)
#devtools::install_github("amanyiraho/dhis2r")
#renv::restore()
#renv::snapshot()

options(
    shiny.launch.browser = TRUE
)

generate_url <- memoise(
    function(dx, ou, pe) {
        url <- paste0(
            "https://hiskenya.org/api/analytics/dataValueSet.csv?",
            "dimension=dx%3A", paste(dx, collapse = "%3B"),
            "&dimension=ou%3A", paste(ou, collapse = "%3B"),
            "&dimension=pe%3A", paste(pe, collapse = "%3B"),
            "%3BLEVEL-JwTgQwgnl8h&showHierarchy=false&hierarchyMeta=false&includeMetadataDetails=true&includeNumDen=true&skipRounding=false&completedOnly=false&outputIdScheme=NAME"
        )
        print(url)

        tryCatch(
            expr = {
                res <- GET(url, authenticate("mikonya", "Kenya2030")) %>%
                    content("text") %>%
                    read.csv(text = .)
                return(res)
            },
            error = function(e) {
                print(e)
            }
        )
    }
)


ui <- fluidPage(
    useShinyjs(),  # Initialize shinyjs
    titlePanel("DHIS2 Data Downloader"),
    sidebarLayout(
        sidebarPanel(
            textInput("base_url", "DHIS2 Base URL:",  value = "https://hiskenya.org/api"),
            textInput("username", "DHIS2 Username:", value = "mikonya"),
            passwordInput("password", "DHIS2 Password:", value = "Kenya2030"),
            actionButton("login", "Log In"),
            conditionalPanel(
                condition = "output.loggedIn == true",
                selectizeInput("elements", "Select Data Elements:", choices = NULL, multiple = TRUE),
                selectizeInput("org_units", "Select Organization Units:", choices = NULL, multiple = TRUE),
                dateRangeInput("date_range", "Select Date Range:", start = "2019-01-01", end = Sys.Date()),
                actionButton("download", "Download Data")
            )
        ),
        mainPanel(
            downloadButton("download_long", "Download Data"),
            tableOutput("data_long"),
            tableOutput("data_wide")
        )
    )
)

# Define server logic
server <- function(input, output, session) {
    credentials <- reactiveValues(auth = NULL, elements = NULL, org_units = NULL, loggedIn = FALSE)

    observeEvent(input$login, {
        base_url <- input$base_url
        username <- input$username
        password <- input$password

        auth <- authenticate(username, password)
        test_url <- paste0(base_url, "/me")

        response <- GET(test_url, auth)

        if (status_code(response) == 200) {
            credentials$auth <- auth
            credentials$loggedIn <- TRUE
            showModal(modalDialog(
                title = "Login Successful",
                "You are now logged in to DHIS2.",
                easyClose = TRUE
            ))

            # Fetch data elements
            elements_url <- paste0(base_url, "/dataElements?fields=id,name&paging=false")
            elements_response <- GET(elements_url, auth)
            elements_data <- content(elements_response, "parsed")$dataElements
            credentials$elements <- data.frame(
                id = sapply(elements_data, `[[`, "id"),
                name = sapply(elements_data, `[[`, "name"),
                stringsAsFactors = FALSE
            )

            updateSelectizeInput(session, "elements", choices = credentials$elements$name, server = TRUE)

            # Fetch organization units
            org_units_url <- paste0(base_url, "/organisationUnits?fields=id,name,level&paging=false")
            org_units_response <- GET(org_units_url, auth)
            org_units_data <- content(org_units_response, "parsed")$organisationUnits
            sub_national_units <- org_units_data[sapply(org_units_data, `[[`, "level") == 2]
            credentials$org_units <- data.frame(
                id = sapply(sub_national_units, `[[`, "id"),
                name = sapply(sub_national_units, `[[`, "name"),
                stringsAsFactors = FALSE
            )

            updateSelectizeInput(session, "org_units", choices = credentials$org_units$name, server = TRUE)
            shinyjs::enable("download")
        } else {
            showModal(modalDialog(
                title = "Login Failed",
                "Invalid username or password. Please try again.",
                easyClose = TRUE
            ))
        }
    })



    data_long <- eventReactive(input$download, {
        req(credentials$auth, credentials$elements, credentials$org_units)  # Ensure authentication is successful and elements/org units are fetched

        selected_names <- input$elements
        selected_element_ids <- credentials$elements$id[credentials$elements$name %in% selected_names]
        selected_org_units <- input$org_units
        selected_org_ids <- credentials$org_units$id[credentials$org_units$name %in% selected_org_units]

        if (length(selected_element_ids) == 0 || length(selected_org_ids) == 0) {
            showModal(modalDialog(
                title = "Selection Error",
                "Please select at least one data element and one organization unit.",
                easyClose = TRUE
            ))
            return(NULL)
        }

        date_range <- format(seq.Date(as.Date(input$date_range[1]), as.Date(input$date_range[2]), by = "month"), "%Y%m")

        data_long <- generate_url(dx = selected_element_ids, ou = selected_org_ids, pe = date_range) %>%
            transmute(
                data_element,
                period = my(period),
                organisation_unit,
                value
            )


        return(data_long)
    })

    data_wide <- reactive({
        long_data <- data_long() %>%
            pivot_wider(names_from = data_element, values_from = value) %>%
            head(10)
    })

    output$data_long <- renderTable({
        data_long() %>%
            head(10)
    })

    output$download_long <- downloadHandler(
        filename = function() {
            paste("data-", Sys.Date(), ".csv", sep="")
        },
        content = function(file) {
            write.csv(data_long(), file)
        }
    )

    output$data_wide <- renderTable({
        data_wide()
    })

    output$loggedIn <- reactive({
        credentials$loggedIn
    })

    outputOptions(output, "loggedIn", suspendWhenHidden = FALSE)
}

# Run the application
shinyApp(ui = ui, server = server)


#https://hiskenya.org/api

