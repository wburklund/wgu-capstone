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
import { Header, Dropdown, MenuItem, List, Grid } from 'semantic-ui-react';

const statisticOptions = [
  {
    text: 'Normal',
    value: 'Normal'
  },
  {
    text: 'Virus',
    value: 'Virus'
  },
  {
    text: 'Bacteria',
    value: 'Bacteria'
  }
]

const initialState = {
  selectedStat: 'Normal'
}

class StatisticalAnalysis extends React.Component {
  state = initialState

  render() {
    let { data } = this.props;
    let { selectedStat } = this.state;
    let selectedData = data[selectedStat];
    if (!selectedData) {
      return <div />
    }
    let mean = selectedData.reduce((a, d) => a + d.y, 0) / selectedData.length

    let sortData = [...selectedData]
    sortData.sort((a, b) => a.y - b.y)
    let isOdd = sortData.length % 2 == 1
    let q1Index = Math.round(sortData.length / 4)
    let midIndex = Math.floor(sortData.length / 2)
    let q3Index = Math.round(sortData.length * 3 / 4)
    let median;
    if (isOdd) {
      median = (sortData[midIndex].y + sortData[midIndex + 1].y) / 2
    } else {
      median = sortData[midIndex].y
    }
    let min = sortData[0].y
    let max = sortData[sortData.length - 1].y
    let q1 = sortData[q1Index].y
    let q3 = sortData[q3Index].y

    return (
      <React.Fragment>
        <br />
        <br />
        <Header>Statistical Analysis</Header>
        <br />
        <Dropdown
          selection
          options={statisticOptions}
          defaultValue={'Normal'}
          onChange={(_, d) => this.setState({ 'selectedStat': d.value })} />
        <br />
        <br />
        <br />

        <Grid columns={2}>
          <Grid.Column style={{ position: 'relative' }}>
            <List celled size="big">
              <List.Item>
                <List.Content>
                  <List.Header>Mean</List.Header>
                  {mean.toFixed(2)} cases/day
                    </List.Content>
              </List.Item>
              <List.Item>
                <List.Content>
                  <List.Header>Median</List.Header>
                  {median.toFixed(2)} cases/day
                    </List.Content>
              </List.Item>
              <List.Item>
                <List.Content>
                  <List.Header>Range</List.Header>
                  {min}-{max} cases/day
                    </List.Content>
              </List.Item>
              <List.Item>
                <List.Content>
                  <List.Header>First Quartile</List.Header>
                  {q1} cases/day
                    </List.Content>
              </List.Item>
              <List.Item>
                <List.Content>
                  <List.Header>Third Quartile</List.Header>
                  {q3} cases/day
                    </List.Content>
              </List.Item>
            </List>
          </Grid.Column>
          <Grid.Column>
            {JSON.stringify(data[selectedStat].slice(0, 20))}
          </Grid.Column>
        </Grid>

      </React.Fragment>
    )
  }
}

export default StatisticalAnalysis;
