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



# connection to sqlite db
sqlite_conn <- function(db_name) {
  conn <- DBI::dbConnect(RSQLite::SQLite(), glue::glue("{db_name}.db"))
  return(conn)
}

lite_conn <- sqlite_conn("metadata")

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


org_units_query <- function() {
  county_ids <- dbGetQuery(lite_conn, "SELECT DISTINCT county_id AS org_id, county_name AS org_name FROM org_units")
  country_id <- dbGetQuery(lite_conn, "SELECT DISTINCT country_id AS org_id, country_name AS org_name FROM org_units")
  merged_orgs <- bind_rows(county_ids, country_id) %>% arrange(org_name)

  named_orgs_vector <- set_names(merged_orgs$org_id, merged_orgs$org_name)
  return(named_orgs_vector)
}

data_elements <- function() {
  query_res <- dbGetQuery(
    lite_conn,
    "SELECT name, id FROM data_elements WHERE name IN ('MOH 747A_DMPA-IM', 'MOH 747A_DMPA-SC');"
  )

  named_elements_vector <- set_names(query_res$id, query_res$name)
  return(named_elements_vector)
}


style_gt_table <- function(gt_table, title = NULL, sub_title = NULL, container_height = NULL, activate_html = TRUE) {
  # Apply custom styles
  gt_table <- gt_table %>%
    tab_header(
      title = title,
      subtitle = str_to_title(str_replace_all(sub_title, "_", " "))
    ) %>%
    opt_stylize(color = "red", style = 5) %>%
    tab_options(
      table.width = pct(100),
      container.overflow.y = TRUE,
      container.height = container_height,
      ihtml.active = activate_html,
      ihtml.use_pagination = TRUE,
      ihtml.use_pagination_info = FALSE,
      ihtml.use_highlight = TRUE,
      ihtml.use_search = TRUE
    )

  return(gt_table)
}

# Customized Data extraction function
extract_data_from_his <- memoise(
  function(con, analytic, org_unit, date_range, output_format = "NAME") {
    response <- con$get_analytics(
      analytic = c(analytic),
      org_unit = c(org_unit),
      period = date_range,
      output_scheme = output_format
    )
  }
)

extract_dx_metadata <- memoise(
  function(his_con) {
    data_elements_df <- his_con$get_metadata(endpoint = "dataElements")
    data_elements_bind_ids <- set_names(data_elements_df$id, data_elements_df$name)

    return(data_elements_bind_ids)
  }
)
