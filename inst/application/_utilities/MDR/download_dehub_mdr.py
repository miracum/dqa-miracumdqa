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

#!/usr/bin/python

__author__ = "Lorenz A. Kapsner, Moritz Stengel"
__copyright__ = "Universitätsklinikum Erlangen"

import logging
from dqa_mdr_connector.get_mdr import GetMDR

if __name__ == "__main__":
    logging.basicConfig(level=logging.DEBUG)
    gm = GetMDR(
        output_folder="./",
        output_filename="dehub_mdr_clean.csv",
        api_url="https://dehub-dev.miracum.org/rest/v1/",
        api_auth_url="https://miracum-fas.unimedizin-mainz.de/auth/realms/miracum/protocol/openid-connect/token",
        namespace_designation="miracum-DQA"
    )
    gm()

# https://auth.dev.osse-register.de/auth/realms/dehub-demo/protocol/openid-connect/token
# https://rest.demo.dataelementhub.de/v1/

# curl -X GET https://miracum-fas.unimedizin-mainz.de/auth/realms/miracum/.well-known/uma2-configuration
