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
import {
  XYPlot,
  XAxis,
  YAxis,
  ChartLabel,
  HorizontalGridLines,
  VerticalGridLines,
  LineSeriesCanvas,
  DiscreteColorLegend,
  Crosshair
} from 'react-vis';

const initialState = {
  nearestX: null
}

class StatisticsPlot extends React.Component {
  state = initialState;

  render() {
    let { data } = this.props;
    let { nearestX } = this.state;

    let crosshairItems = [];
    if (nearestX) {
      let nearestTime = nearestX.x.getTime();
      crosshairItems.push({ title: 'Date', value: nearestX.x.toDateString(), x: nearestX.x })
      crosshairItems.push({ title: 'Normal', value: data.Normal.find(e => e.x.getTime() === nearestTime)?.y });
      crosshairItems.push({ title: 'Viral Pneumonia', value: data.Virus.find(e => e.x.getTime() === nearestTime)?.y });
      crosshairItems.push({ title: 'Bacterial Pneumonia', value: data.Bacteria.find(e => e.x.getTime() === nearestTime)?.y });
    }

    return (
      <XYPlot width={800} height={600} xType='time' onMouseLeave={() => this.setState({ 'nearestX': null })}>
        <HorizontalGridLines />
        <VerticalGridLines />
        <XAxis />
        <YAxis />
        <DiscreteColorLegend items={['Normal', 'Viral Pneumonia', 'Bacterial Pneumonia']} />
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
          style={{ transform: 'rotate(-90)' }}
        />
        <LineSeriesCanvas
          className="first-series"
          data={data.Normal}
          onNearestX={x => this.setState({ 'nearestX': x })}
        />
        <LineSeriesCanvas
          className="second-series"
          data={data.Virus}
        />
        <LineSeriesCanvas
          className="third-series"
          data={data.Bacteria}
        />
        {nearestX &&
          <Crosshair
            values={crosshairItems}
            titleFormat={items => ({ title: 'Date', value: items[0].value })}
            itemsFormat={items => items.slice(1)} />}
      </XYPlot>
    )
  }
}

export default StatisticsPlot;
