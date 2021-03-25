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
import { Segment } from 'semantic-ui-react';
import {
  XYPlot,
  XAxis,
  YAxis,
  ChartLabel,
  HorizontalGridLines,
  VerticalGridLines,
  LineSeriesCanvas,
  DiscreteColorLegend
} from 'react-vis';

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

async function statistics(accessKey) {
  const response = await fetch("http://capstone-api.wburklund.com/statistics", {
    headers: {
      'X-API-KEY': accessKey
    },
  }).then(response => response.json());
  return response;
}

const Line = LineSeriesCanvas;

class Report extends React.Component {

  componentDidMount() {
    statistics(this.props.accessKey).then(stats => {
      let causeGroups = groupBy(stats, (x) => x[0].Cause);
      let displayStats = {}

      for (let key of causeGroups.keys()) {
        let groupData = causeGroups.get(key).map(d => ({ x: new Date(d[0].Date), y: d[1]}));
        groupData.sort((a, b) => a.x - b.x)
        displayStats[key] = groupData
      }

      console.log(displayStats)
      
      return this.setState({'stats': displayStats})
    })
  }

  render() {
    return (
      <Segment placeholder style={{ height: '100%', width: '100%', paddingTop: '15px' }}>
        <XYPlot width={800} height={600} xType='time'>
          <HorizontalGridLines />
          <VerticalGridLines />
          <XAxis />
          <YAxis />
          <DiscreteColorLegend items={['Normal', 'Virus', 'Bacteria', 'Smoking']} orientation='horizontal' />
          <ChartLabel
            text="Time"
            className="alt-x-label"
            includeMargin={false}
            xPercent={0.5}
            yPercent={1.01}
          />
          <ChartLabel
            text="Cases"
            className="alt-y-label"
            includeMargin={false}
            xPercent={0.02}
            yPercent={0.5}
            style={{transform: 'rotate(-90)'}}
          />
          <Line
            className="first-series"
            curve={'curveMonotoneX'}
            data={this.state?.stats['Normal']}
          />
          <Line
            className="second-series"
            curve={'curveMonotoneX'}
            data={this.state?.stats['Virus']}
          />
          <Line
            className="third-series"
            curve={'curveMonotoneX'}
            data={this.state?.stats['Bacteria']}
          />
          <Line
            className="fourth-series"
            curve={'curveMonotoneX'}
            data={this.state?.stats['Smoking']}
          />
        </XYPlot>
      </Segment>
    );
  }
}

export default Report;
