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
  Crosshair,
  WhiskerSeries,
  RadialChart
} from 'react-vis';
import { Button } from 'semantic-ui-react';

const initialState = {
  activeDisplay: 0,
  nearestX: null
}

class StatisticsPlot extends React.Component {
  state = initialState;

  mapWeeklySeries(data) {
    let result = []
    let i = 0;
    while (data[i].x.getDay() != 0) {
      i++;
    }

    while (i + 7 < data.length) {
      let week = data[i].x;
      let weekData = data.slice(i, i + 7);

      let mean = weekData.reduce((a, d) => a + d.y, 0) / weekData.length
      let variance = weekData.reduce((a, d) => a + Math.pow(d.y - mean, 2), 0) / (weekData.length - 1) 
      let standardDeviation = Math.sqrt(variance)

      result.push({x: week, y: Math.round(mean * 100) / 100, yVariance: Math.round(standardDeviation * 100) / 100})

      i += 7;
    }

    return result
  }

  mapTotals(data) {
    let result = []

    let normalTotal = data.Normal.reduce((a, d) => a + d.y, 0);
    let virusTotal = data.Virus.reduce((a, d) => a + d.y, 0);
    let bacteriaTotal = data.Bacteria.reduce((a, d) => a + d.y, 0);

    let total = normalTotal + virusTotal + bacteriaTotal;

    result.push({angle: normalTotal, label: 'Normal: ' + Math.round(normalTotal * 100 / total) + '%' })
    result.push({angle: virusTotal, label: 'Viral Pneumonia: ' + Math.round(virusTotal * 100 / total) + '%' })
    result.push({angle: bacteriaTotal, label: 'Bacterial Pneumonia: ' + Math.round(bacteriaTotal * 100 / total) + '%'})
    
    return result;
  }

  render() {
    let { data } = this.props;
    let { nearestX, activeDisplay } = this.state;

    let crosshairItems = [];
    if (nearestX) {
      let nearestTime = nearestX.x.getTime();      
      if (activeDisplay == 0) {
        let normalEntry = data.Normal.find(e => e.x.getTime() === nearestTime);
        let virusEntry = data.Virus.find(e => e.x.getTime() === nearestTime);
        let bacteriaEntry = data.Bacteria.find(e => e.x.getTime() === nearestTime);
  
        crosshairItems.push({ title: 'Date', value: nearestX.x.toDateString(), x: nearestX.x })
        crosshairItems.push({ title: 'Normal', value: normalEntry?.y });
        crosshairItems.push({ title: 'Viral Pneumonia', value: virusEntry?.y });
        crosshairItems.push({ title: 'Bacterial Pneumonia', value: bacteriaEntry?.y });  
      } else {
        let normalEntry = this.mapWeeklySeries(data.Normal).find(e => e.x.getTime() === nearestTime);
        let virusEntry = this.mapWeeklySeries(data.Virus).find(e => e.x.getTime() === nearestTime);
        let bacteriaEntry = this.mapWeeklySeries(data.Bacteria).find(e => e.x.getTime() === nearestTime);
  
        crosshairItems.push({ title: 'Date', value: nearestX.x.toDateString(), x: nearestX.x })
        crosshairItems.push({ title: 'Normal', value: normalEntry?.y + "±" + normalEntry?.yVariance + " cases/day" });
        crosshairItems.push({ title: 'Viral Pneumonia', value: virusEntry?.y + "±" + virusEntry?.yVariance + " cases/day" });
        crosshairItems.push({ title: 'Bacterial Pneumonia', value: bacteriaEntry?.y + "±" + bacteriaEntry?.yVariance + " cases/day" });  
      }
    }

    return (
      <>
        <br />
        <Button.Group>
          <Button onClick={() => this.setState({ "activeDisplay": 0 })} primary={activeDisplay == 0}>Cases Over Time</Button>
          <Button onClick={() => this.setState({ "activeDisplay": 1 })} primary={activeDisplay == 1}>Cases By Week</Button>
          <Button onClick={() => this.setState({ "activeDisplay": 2 })} primary={activeDisplay == 2}>Case Proportions</Button>
        </Button.Group>
        {activeDisplay === 0 &&
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
        }
        {activeDisplay === 1 &&
          <XYPlot width={800} height={600} xType='time' onMouseLeave={() => this.setState({ 'nearestX': null })}>
            <HorizontalGridLines />
            <VerticalGridLines />
            <XAxis hideTicks />
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
            <WhiskerSeries
              data={this.mapWeeklySeries(data.Normal)}
              onNearestX={x => this.setState({ 'nearestX': x })}
            />
            <WhiskerSeries
              data={this.mapWeeklySeries(data.Virus)}
            />
            <WhiskerSeries
              data={this.mapWeeklySeries(data.Bacteria)}
            />
            {nearestX &&
              <Crosshair
                values={crosshairItems}
                titleFormat={items => ({ title: 'Date', value: "Week of " + items[0].value })}
                itemsFormat={items => items.slice(1)} />}
          </XYPlot>
        }
        {activeDisplay === 2 &&
          <RadialChart data={this.mapTotals(data)} width={800} height={600} showLabels />
        }                        
      </>
    )
  }
}

export default StatisticsPlot;
