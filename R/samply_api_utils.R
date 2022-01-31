# miRacumDQA - The MIRACUM consortium's data quality assessment tool
# Copyright (C) 2019-2022 Universitätsklinikum Erlangen
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

load_members <- function(base_url,
                         dataelementgroup_id,
                         headless,
                         logfile_dir) {

  # set dataelement-groups url
  groupmember_url <- paste0(
    base_url,
    "dataelementgroups/",
    dataelementgroup_id,
    "/members"
  )
  DIZutils::feedback(
    print_this = paste0("Group-member URL: ", groupmember_url),
                   findme = "c212b28d7e",
    logfile_dir = logfile_dir,
    headless = headless
    )

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
