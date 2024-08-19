
generate_url <- memoise(
    function(dx, ou, pe) {
    url <- paste0(
        "https://hiskenya.org/api/analytics/dataValueSet.csv?",
        "dimension=dx%3A", paste(dx, collapse = "%3B"),
        "&dimension=ou%3A", paste(ou, collapse = "%3B"),
        "&dimension=pe%3A", paste(pe, collapse = "%3B"),
        "%3BLEVEL-JwTgQwgnl8h&showHierarchy=false&hierarchyMeta=false&includeMetadataDetails=false&includeNumDen=true&skipRounding=false&completedOnly=false&outputIdScheme=NAME"
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


# Implement modals for notifications
notifyUser <- function(notificationTitle, notificationText, error = NULL) {
    showModal(modalDialog(
        title = paste(ji("bell"), notificationTitle),
        paste(notificationText),
        footer = modalButton("Close", icon = icon("circle-xmark")),
        easyClose = T,
        class = "custom-modal", # Add a custom class for additional styling
        tags$style(global_modal_style)
    ))
}
