server <- function(input, output, session) {
  # Main Server file --------------------------------------

  # User Authentication ----------------------------------------------
  observeEvent(input$login, {
    tryCatch(
      expr = {
        url <- "https://hiskenya.org/api/me"
        username <- input$his_user
        password <- input$his_pass
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
          shinyjs::toggle("login-page")  # -- to be removed when access is back
          shinyjs::toggle("data-page")
        }
      },
      error = function(e) {
        print(e)
        notifyUser("An Error occured", e)
      }
    )
  })

    # Logout User
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

    observeEvent(input$logoutbtn, {
        shinyjs::toggle("data-page")
        shinyjs::toggle("login-page")
    })
}
