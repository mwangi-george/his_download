server <- function(input, output, session) {
  # Main Server file --------------------------------------

  # User Authentication ----------------------------------------------
  observeEvent(input$login, {
      tryCatch(
          expr = {
              # Construct the URL for the API endpoint
              url <- str_c(input$his_base_url, "/api/me")
              username <- input$his_user
              password <- input$his_pass

              # Check if there's an internet connection and required inputs are not null
              if (curl::has_internet() &&
                  !is.null(input$his_base_url) &&
                  !is.null(input$his_user) &&
                  !is.null(input$his_pass)) {

                  # Perform the login request
                  login <- httr::GET(url, authenticate(username, password))

                  # Check the HTTP status code for success
                  if (status_code(login) == 200L) {
                      # Show dashboard if login is successful
                      shinyjs::toggle("login-page", condition = FALSE)
                      shinyjs::toggle("data-page", condition = TRUE)
                      print("Logged in Successfully")
                  } else {
                      # Show an error message if login failed
                      notifyUser("Login Error", "Invalid username/password. Please try again!")
                      print("Login Failed")
                  }
              } else {
                  # Notify the user if there's no internet connection or missing inputs
                  notifyUser("Error", "Please check your internet connection or ensure all fields are filled.")
              }
          },
          error = function(e) {
              # Handle any errors that occur during the process
              print(e)
              notifyUser("An Error occurred", e$message)
          }
      )

  })

  observe({
    # Call download module
    downloadServer("download_module", input$his_base_url, input$his_user, input$his_pass)
  })

  # Logout button
  output$logoutbtn <- renderUI({
    tags$li(
      a(icon("right-from-bracket"),
        "Logout",
        href = "javascript:window.location.reload(true)"
      ),
      class = "dropdown",
      style = logout_button_style
    )
  })

  # show login page when logout button is clicked
  observeEvent(input$logoutbtn, {
    shinyjs::toggle("data-page")
    shinyjs::toggle("login-page")
  })
}
