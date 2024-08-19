server <- function(input, output, session) {
  # Main Server file --------------------------------------

  # User Authentication ----------------------------------------------
  observeEvent(input$login, {
    tryCatch(
      expr = {
        url <- str_c(input$his_base_url, "/api/me")  # "https://hiskenya.org/api/me"
        username <- input$his_user
        password <- input$his_pass
        if (curl::has_internet()) {
          login <- GET(url, authenticate(username, password))
          # show dashboard if login is successful
          if (login$status == 200L) {
            shinyjs::toggle("login-page")
            shinyjs::toggle("data-page")
            print("Logged in Successfully")
          } else {
            # Show an error message if log in failed
            notifyUser("Login Error", "Invalid username/password. Please try again!")
            print("Login Failed")
          }
        } else {
          notifyUser("Error", "Please check your internet connection")
        }
      },
      error = function(e) {
        print(e)
        notifyUser("An Error occured", e)
      }
    )
  })

  observe({
    input$login

    # dhis2 connection using dhis2r package
    his_con <- Dhis2r$new(
      base_url = input$his_base_url,
      username = input$his_user,
      password = input$his_pass
    )

    # Call download module
    downloadServer("download_module", his_con)
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
