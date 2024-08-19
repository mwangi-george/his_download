downloadUI <- function(id) {
  ns <- NS(id)

  tagList(
    box(
      width = 3,
      title = "Controls",
      height = 570,
      solidHeader = TRUE,
      status = "info",
      pickerInput(
        ns("analytic"),
        label = "Select Data Element",
        choices = data_elements(),
        width = "100%",
        multiple = TRUE,
        options = pickerOptions(actionsBox = TRUE, `live-search` = TRUE)
      ),
      hr(),
      pickerInput(
        ns("org_unit"),
        "Select Org Unit",
        choices = org_units_query(),
        multiple = TRUE,
        width = "100%",
        selected = "HfVjCurKxh2",
        options = pickerOptions(actionsBox = TRUE, `live-search` = TRUE)
      ),
      hr(),
      dateRangeInput(ns("date_range"), "Period", start = as.Date("2024-01-01"), end = today(), min = as.Date("2020-01-01"), max = today()),
      actionButton(ns("trigger_download"), "Extract", icon = icon("cloud-arrow-down"), style = buttonStyle(150))
    ),
    box(
      width = 9,
      title = "Output",
      height = 570,
      solidHeader = TRUE,
      status = "info",
      downloadButton(ns("download_results"), "Download Results", style = buttonStyle(160)),
      gt_output(ns("his_data_table")) %>% shinycssloaders::withSpinner(type = 4, size = 0.5)
    )
  )
}

downloadServer <- function(id, connection_to_his) {
  moduleServer(id, function(input, output, session) {


    # observe({
    #     req(connection_to_his)
    #
    #     updateSelectizeInput(session, "analytic", choices = extract_dx_metadata(connection_to_his))
    #
    # })

    his_output <- eventReactive(input$trigger_download, {
      # download requires connection
      req(connection_to_his)

      # format date range from user interface
      start_date <- format(as.Date(input$date_range[1]), "%Y%m")
      end_date <- format(as.Date(input$date_range[2]), "%Y%m")
      period_formatted <- c(start_date:end_date)

      # An error handler to avoid app from breaking if there are errors during extraction
      tryCatch(
        expr = {
          # extract
          response <- extract_data_from_his(
              con = connection_to_his, analytic = input$analytic,
              org_unit = input$org_unit, date_range = period_formatted
          )
          return(response)
        },
        error = function(e) {
          # print error
          print(e)
          notifyUser("An Error occurred extraction!", e$message)
          return()
        }
      )
    })

    if (!is.null(his_output())) {
      # Rendering Results from the extraxtion
      output$his_data_table <- render_gt({
        his_output() %>%
          gt() %>%
          cols_width(
            starts_with("analytic") ~ px(200),
            starts_with("org") ~ px(200),
            starts_with("period") ~ px(100),
            starts_with("value") ~ px(100)
          ) %>%
          style_gt_table(sub_title = "Results", container_height = 480)
      })

      # Download Functionality
      output$download_results <- downloadHandler(
        filename = function() {
          str_c("data", ".xlsx")
        },
        content = function(file) {
          openxlsx::write.xlsx(his_output(), file)
        }
      )
    } else {
      output$his_data_table <- render_gt({NULL})
    }
  })
}
