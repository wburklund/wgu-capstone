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
import { Header, Segment, Button } from 'semantic-ui-react';
import {
  XYPlot,
  XAxis,
  YAxis,
  ChartLabel,
  HorizontalGridLines,
  VerticalGridLines,
  LineSeriesCanvas
} from 'react-vis';

const Line = LineSeriesCanvas;

class Report extends React.Component {
    render() {
        return (
            <Segment placeholder style={{ height: '100%', width: '100%', paddingTop: '15px' }}>
        <XYPlot width={800} height={600}>
          <HorizontalGridLines />
          <VerticalGridLines />
          <XAxis />
          <YAxis />
          <ChartLabel 
            text="Time"
            className="alt-x-label"
            includeMargin={false}
            xPercent={0.5}
            yPercent={1.01}
            />

          <ChartLabel 
            text="Stock Price"
            className="alt-y-label"
            includeMargin={false}
            xPercent={0.02}
            yPercent={0.5}
            style={{
              transform: 'rotate(-90)',
            }}
            />
          <Line
            className="first-series"
            data={[{x: 1, y: 30}, {x: 2, y: 40}, {x: 3, y: 60}, {x: 4, y: 120}]}
          />
          <Line className="second-series" data={null} />
          <Line
            className="third-series"
            curve={'curveMonotoneX'}
            data={[{x: 1, y: 30}, {x: 2, y: 40}, {x: 3, y: 60}, {x: 4, y: 120}]}
            strokeDasharray={[7, 3]}
          />
        </XYPlot>
            </Segment>
        )
    }
}

export default Report;
