load_members <- function(base_url, dataelementgroup_id) {

  # set dataelement-groups url
  groupmember_url <- paste0(
    base_url,
    "dataelementgroups/",
    dataelementgroup_id,
    "/members"
  )
  message("\nGroup-member URL: ", groupmember_url, "\n")

  # get group members
  response_group <- jsonlite::fromJSON(
    txt = groupmember_url
  )
  # transform results to data.table
  response_group$results <- data.table::as.data.table(
    response_group$results
  )

  if (nrow(response_group$results) > 0) {
    return(
      list(
        "DATAELEMENTS" = response_group$results[
          get("type") == "DATAELEMENT" &
            get("identification.status") == "RELEASED", get("id")
          ],
        "DATAELEMENTGROUPS" = response_group$results[
          get("type") == "DATAELEMENTGROUP" &
            get("identification.status") == "RELEASED", get("id")
          ]
      )
    )
  } else {
    return(list())
  }
}
