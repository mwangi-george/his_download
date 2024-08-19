## UI building ----------------------------------------------
ui <- fluidPage(
  useShinyjs(),
  tags$style(
    HTML(
      # accessed from global
      loginPageStyle
    )
  ),
  div(
    id = "login-page",
    h3("Welcome", class = "login-header"),
    textInput("his_user", label = "DHIS2 Username", value = "mikonya",width = "100%"),
    passwordInput("his_pass", "DHIS2 Password", width = "100%"),
    actionButton("login", "Login", class = "btn-primary", style = "width: 100%;")
  ),
  div(
    id = "data-page", hidden = TRUE,
    fluidRow(dashboardPage(header, sidebar, body))
  )
)
