/*
  WGU Capstone Project
  Copyright (C) 2021 Will Burklund

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU Affero General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU Affero General Public License for more details.

  You should have received a copy of the GNU Affero General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

import React from 'react';
import { Header, Dropdown } from 'semantic-ui-react';

const statisticOptions = [
    {
      text: 'Normal',
      value: 'Normal'
    },
    {
      text: 'Virus',
      value: 'Virus'
    },  {
      text: 'Bacteria',
      value: 'Bacteria'
    },  {
      text: 'Smoking',
      value: 'Smoking'
    }
]

const initialState = {
    selectedStat: 'Normal'
}

class StatisticsDisplay extends React.Component {
    state = initialState

    render() {
        let { data } = this.props;
        let { selectedStat } = this.state;

        return (
            <React.Fragment>
                <br />
                <br />
                <Header>Statistical Analysis</Header>
                <Dropdown
                selection
                options={statisticOptions}
                defaultValue={'Normal'}
                onChange={(_, d) => this.setState({ 'selectedStat': d.value })} />
            </React.Fragment>
        )
    }
}

export default StatisticsDisplay;
