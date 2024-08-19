download_tab <- tabItem(
    tabName = "data_download",
    fluidRow(
        downloadUI("download_module")
    )
)


body <- dashboardBody(
    tabItems(
        download_tab
    )
)
