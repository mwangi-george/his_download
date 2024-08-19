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
    style = "width: 500px;",
    h3("Welcome", class = "login-header"),
    textInput(
      "his_base_url",
      label = "A valid DHIS2 instance",
      placeholder = "Example: https://hiskenya.org",
      value = "https://hiskenya.org",
      width = "100%"
      ),
    textInput("his_user", label = "DHIS2 Username", value = "mikonya", width = "100%"), # --- remove value
    passwordInput("his_pass", "DHIS2 Password", value = "Kenya2030", width = "100%"),
    actionButton("login", "Login", class = "btn-primary", style = "width: 100%;")
  ),
  div(
    id = "data-page", hidden = TRUE,
    fluidRow(dashboardPage(header, sidebar, body))
  )
)
