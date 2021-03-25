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
import { Segment, Grid, Button, Header, Dropdown } from 'semantic-ui-react';
import StatisticalAnalysis from './StatisticalAnalysis';
import StatisticsPlot from './StatisticsPlot';

// https://stackoverflow.com/questions/14446511/most-efficient-method-to-groupby-on-an-array-of-objects
function groupBy(list, keyGetter) {
  const map = new Map();
  list.forEach((item) => {
    const key = keyGetter(item);
    const collection = map.get(key);
    if (!collection) {
      map.set(key, [item]);
    } else {
      collection.push(item);
    }
  });
  return map;
}

function getDateRange(startDate, endDate) {
  let dateRange = []
  let workingDate = new Date(startDate)

  while (workingDate < endDate) {
    dateRange.push(workingDate)
    let nextDate = new Date(workingDate)
    nextDate.setUTCDate(nextDate.getUTCDate() + 1)
    workingDate = nextDate
  }

  dateRange.push(new Date(endDate))
  return dateRange
}

async function statistics(accessKey) {
  const response = await fetch("http://capstone-api.wburklund.com/statistics", {
    headers: {
      'X-API-KEY': accessKey
    },
  }).then(response => response.json());
  return response;
}

const initialState = {
  stats: {},
  nearestX: null,
}

class Report extends React.Component {
  state = initialState

  componentDidMount() {
    statistics(this.props.accessKey).then(stats => {
      // Parse dates
      for (let stat of stats) {
        stat[0].Date = (new Date(stat[0].Date)).getTime()
      }

      // Create array of default values (0) for dates within our data's date range
      let allDates = [...stats].map(d => d[0].Date)
      let minDate = allDates.reduce((a, b) => a < b ? a : b);
      let maxDate = allDates.reduce((a, b) => a > b ? a : b);
      let dateRange = getDateRange(minDate, maxDate).map(d => d.getTime())
      let defaultValues = dateRange.map(d => [d, 0])

      // Group data by cause
      let causeGroups = groupBy(stats, x => x[0].Cause);
      let displayStats = {}

      for (let key of causeGroups.keys()) {
        // Map this cause group's data to [Date, Count] pairs
        let groupData = causeGroups.get(key).map(d => [d[0].Date, d[1]]);
        // Merge default values with group data
        let fullGroupData = new Map([...defaultValues, ...groupData])
        let groupStats = [...fullGroupData]
        groupStats.sort()
        // Display actual dates
        let displayGroupStats = groupStats.map(d => ({ x: new Date(d[0]), y: d[1] }));
        displayStats[key] = displayGroupStats
      }

      console.log(displayStats)

      return this.setState({ 'stats': displayStats })
    })
  }

  render() {
    const { stats } = this.state;

    return (
      <Segment placeholder style={{ height: '100%', width: '100%', paddingTop: '15px' }}>
        <Grid columns={2} style={{ height: '100%' }}>
          <Grid.Column style={{ position: 'relative' }}>
            <StatisticsPlot data={stats} />
          </Grid.Column>
          <Grid.Column>
            <StatisticalAnalysis data={stats} />
          </Grid.Column>
        </Grid>
      </Segment>
    );
  }
}

export default Report;
